import Combine
import SwiftUI

struct SiteResult: Identifiable {
    let site: SettlementSiteID
    let prediction: SettlementPattern
    let assessment: SiteAssessment

    var id: SettlementSiteID { site }
    var predictionCorrect: Bool { prediction == assessment.pattern }
}

struct PlannerEvidence: Identifiable, Hashable {
    let id: String
    let category: String
    let text: String
    let symbol: String
}

@MainActor
final class SettlementPlannerModel: ObservableObject {
    enum Phase: Equatable {
        case brief
        case placing
        case predicting
        case results
        case comparing
        case event
        case report
    }

    @Published private(set) var phase: Phase = .brief
    @Published private(set) var placedSite: SettlementSiteID?
    @Published private(set) var prediction: SettlementPattern?
    @Published private(set) var tested: [SettlementSiteID: SiteResult] = [:]
    @Published var hoveredSite: SettlementSiteID?
    @Published private(set) var recommendation: SettlementSiteID?
    @Published private(set) var selectedEvidence: Set<String> = []
    @Published private(set) var eventChoice: String?
    @Published private(set) var eventRevealed = false
    @Published private(set) var hintIndex = 0
    @Published private(set) var dropMessage: String?
    @Published private(set) var successSignal = 0
    @Published private(set) var warningSignal = 0

    // MARK: Navigation through the mission

    func beginPlacing() {
        guard phase == .brief else { return }
        phase = .placing
        hintIndex = 0
    }

    func placeHomes(at siteID: SettlementSiteID) {
        guard phase == .brief || phase == .placing || phase == .results else { return }
        placedSite = siteID
        prediction = nil
        phase = .predicting
        hintIndex = 0
        dropMessage = nil
        successSignal += 1
    }

    func selectPrediction(_ pattern: SettlementPattern) {
        guard phase == .predicting else { return }
        prediction = pattern
    }

    func testPlan() {
        guard phase == .predicting,
              let siteID = placedSite,
              let prediction else { return }

        let site = SettlementMapData.site(for: siteID)
        tested[siteID] = SiteResult(
            site: siteID,
            prediction: prediction,
            assessment: SettlementMapData.assessment(for: site)
        )
        phase = .results
        hintIndex = 0
        successSignal += 1
    }

    func testAnother() {
        placedSite = nil
        prediction = nil
        phase = .placing
        hintIndex = 0
    }

    func startComparison() {
        guard tested.count == SettlementMapData.sites.count else { return }
        phase = .comparing
        recommendation = nil
        selectedEvidence = []
        hintIndex = 0
    }

    func recommend(_ siteID: SettlementSiteID) {
        guard phase == .comparing else { return }
        recommendation = siteID
        placedSite = siteID
        prediction = tested[siteID]?.prediction
        selectedEvidence = []
        hintIndex = 0
        successSignal += 1
    }

    func toggleEvidence(_ evidenceID: String) {
        guard phase == .comparing else { return }
        if selectedEvidence.contains(evidenceID) {
            selectedEvidence.remove(evidenceID)
        } else {
            selectedEvidence.insert(evidenceID)
        }
    }

    func continueToEvent() {
        guard phase == .comparing, recommendation != nil, selectedEvidence.count >= 2 else { return }
        phase = .event
        eventChoice = nil
        eventRevealed = false
        hintIndex = 0
    }

    func selectEventOption(_ optionID: String) {
        guard phase == .event, !eventRevealed else { return }
        eventChoice = optionID
    }

    func revealEvent() {
        guard phase == .event, eventChoice != nil else { return }
        eventRevealed = true
        successSignal += 1
    }

    func finish() {
        guard phase == .event, eventRevealed else { return }
        phase = .report
        hintIndex = 0
    }

    func reset() {
        phase = .brief
        placedSite = nil
        prediction = nil
        tested = [:]
        hoveredSite = nil
        recommendation = nil
        selectedEvidence = []
        eventChoice = nil
        eventRevealed = false
        hintIndex = 0
        dropMessage = nil
    }

    func showDropMessage() {
        dropMessage = "Drop the homes on Site A, B or C."
        warningSignal += 1
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if dropMessage == "Drop the homes on Site A, B or C." {
                dropMessage = nil
            }
        }
    }

    // MARK: Derived values

    var placedSiteData: SettlementSite? {
        placedSite.map { SettlementMapData.site(for: $0) }
    }

    var currentResult: SiteResult? {
        placedSite.flatMap { tested[$0] }
    }

    var currentAssessment: SiteAssessment? {
        placedSiteData.map { SettlementMapData.assessment(for: $0) }
    }

    var testedCount: Int { tested.count }

    var canCompare: Bool { tested.count == SettlementMapData.sites.count }

    var untestedSites: [SettlementSiteID] {
        SettlementSiteID.allCases.filter { tested[$0] == nil }
    }

    var testedSitesInOrder: [SettlementSiteID] {
        SettlementSiteID.allCases.filter { tested[$0] != nil }
    }

    var homes: Int {
        SettlementMapData.existingHomes + (placedSite == nil ? 0 : SettlementMapData.newHomes)
    }

    var population: Int {
        homes * SettlementMapData.householdSize
    }

    var hierarchy: SettlementHierarchyLevel {
        SettlementMapData.hierarchy(for: homes)
    }

    var recommendationSite: SettlementSite? {
        recommendation.map { SettlementMapData.site(for: $0) }
    }

    var recommendationResult: SiteResult? {
        recommendation.flatMap { tested[$0] }
    }

    var event: PlannerEvent? {
        recommendationSite?.event
    }

    var eventCorrect: Bool {
        guard let event else { return false }
        return eventChoice == event.correctOptionID
    }

    var predictionScore: Int {
        tested.values.filter(\.predictionCorrect).count
    }

    var evidenceChips: [PlannerEvidence] {
        guard let site = recommendationSite else { return [] }
        let assessment = SettlementMapData.assessment(for: site)

        return [
            PlannerEvidence(
                id: "\(site.id.rawValue)-pattern",
                category: "Pattern",
                text: "The homes at \(site.cellLabels) form a \(site.pattern.title.lowercased()) pattern.",
                symbol: "circle.grid.2x2.fill"
            ),
            PlannerEvidence(
                id: "\(site.id.rawValue)-access",
                category: "Access",
                text: "\(assessment.roadAccess).",
                symbol: "road.lanes"
            ),
            PlannerEvidence(
                id: "\(site.id.rawValue)-services",
                category: "Services",
                text: "\(assessment.servicesWithinWalk) of 3 local services are within 4 cells.",
                symbol: "figure.walk"
            ),
            PlannerEvidence(
                id: "\(site.id.rawValue)-farmland",
                category: "Farmland",
                text: assessment.farmlandLost == 0
                    ? "No farmland is lost."
                    : "\(assessment.farmlandLost) farmland cells are lost.",
                symbol: "leaf.fill"
            ),
            PlannerEvidence(
                id: "\(site.id.rawValue)-risk",
                category: "Risk",
                text: "Flood risk is \(assessment.floodRisk.title.lowercased()).",
                symbol: assessment.floodRisk.symbol
            )
        ]
    }

    var canContinueToEvent: Bool {
        recommendation != nil && selectedEvidence.count >= 2
    }

    var recommendationSentence: String {
        guard let site = recommendationSite else {
            return "Choose a site, then select two pieces of map evidence."
        }

        let selected = evidenceChips.filter { selectedEvidence.contains($0.id) }
        guard !selected.isEmpty else {
            return "I recommend \(site.id.title) because..."
        }

        let phrases = selected.map { evidence -> String in
            let text = evidence.text
            guard let first = text.first else { return text }
            return first.lowercased() + text.dropFirst()
        }

        let joined: String
        switch phrases.count {
        case 1:
            joined = phrases[0]
        case 2:
            joined = "\(phrases[0]) and \(phrases[1])"
        default:
            joined = phrases.dropLast().joined(separator: ", ") + " and " + (phrases.last ?? "")
        }

        return "I recommend \(site.id.title) because \(joined)"
    }

    // MARK: Guide text and hints

    var defaultCatMessage: String {
        switch phase {
        case .brief:
            "Three families need new homes. Read the map, then drag the homes onto one of the three sites."
        case .placing:
            "Look at the roads, river, steep land, farmland, school and market. Which site gives the best access?"
        case .predicting:
            "Before you test, predict the pattern. Will the homes form a line, a cluster or a scatter?"
        case .results:
            "Check the evidence. Then test another site so you can compare all three."
        case .comparing:
            "Compare access, farmland and flood risk. Recommend one site and choose at least two pieces of map evidence."
        case .event:
            "Predict what the event will do to your chosen site."
        case .report:
            "A good planner explains the trade-offs, not just the choice."
        }
    }

    var hints: [String] {
        switch phase {
        case .brief, .placing:
            [
                "Site A is near the school. Site B is beside the river. Site C is on farmland.",
                "The grid letters run across. The numbers run down. Use them as map evidence."
            ]
        case .predicting:
            [
                "A line follows a road or river. A cluster grows around a central building. A scatter has gaps between homes.",
                "Look at the shape the three homes will make, not just the site name."
            ]
        case .results:
            [
                "Four cells is about a 10-minute walk. Count the cells from the homes to the school and market.",
                "A low flood risk is not the same as no flood risk. Check the distance to the river."
            ]
        case .comparing:
            [
                "There is no perfect site. A good recommendation explains what is gained and what is lost.",
                "Use grid references in your evidence, such as D3 for the school or H5 for the market."
            ]
        case .event:
            [
                "Think about the site's pattern and its distance from the river, road and services.",
                "An event can make a good site less suitable. Explain why."
            ]
        case .report:
            [
                "Try another site and compare how the trade-offs change."
            ]
        }
    }

    var activeHint: String? {
        guard hintIndex > 0, hintIndex <= hints.count else { return nil }
        return hints[hintIndex - 1]
    }

    var catMessage: String {
        activeHint ?? defaultCatMessage
    }

    var canShowHint: Bool {
        hintIndex < hints.count
    }

    func nextHint() {
        guard canShowHint else { return }
        hintIndex += 1
    }

    var hintLabel: String {
        "Hint \(min(hintIndex + 1, hints.count)) of \(hints.count)"
    }

    // MARK: Report

    var reportChecks: [(title: String, passed: Bool)] {
        [
            ("Tested all three sites", tested.count == SettlementMapData.sites.count),
            ("Predicted at least two patterns correctly", predictionScore >= 2),
            ("Used two pieces of map evidence", selectedEvidence.count >= 2),
            ("Predicted the event correctly", eventRevealed && eventCorrect)
        ]
    }
}
