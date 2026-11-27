import SwiftUI

struct SettlementPlannerView: View {
    @StateObject private var model: SettlementPlannerModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsMapKey = false

    private let background = PlannerTheme.background
    private let ink = PlannerTheme.ink
    private let accent = PlannerTheme.accent
    private let warning = Color(red: 0.72, green: 0.42, blue: 0.18)

    @MainActor
    init(model: SettlementPlannerModel? = nil) {
        _model = StateObject(wrappedValue: model ?? SettlementPlannerModel())
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 20) {
                        MissionHeader(progress: progress, stepTitle: stepTitle)
                            .id("mission")

                        CatGuideCard(
                            message: model.catMessage,
                            hintLabel: model.hintLabel,
                            canShowHint: model.canShowHint,
                            onHint: { model.nextHint() }
                        )

                        if model.phase == .brief {
                            briefCard
                        } else {
                            PlannerMapHeading(testedCount: model.testedCount)
                            mapSection
                                .frame(maxWidth: 480)
                                .frame(maxWidth: .infinity)

                            PlannerCard {
                                DisclosureGroup("Map key & how to read the grid", isExpanded: $showsMapKey) {
                                    MapKeyCard()
                                        .padding(.top, 12)
                                }
                                .font(.subheadline.weight(.semibold))
                                .tint(accent)
                            }

                            phasePanel
                                .id("task")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: model.phase) { _, phase in
                    // Bring the new task into view after an action taken farther down the page.
                    let target = phase == .predicting || phase == .results ? "task" : "mission"
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        scrollProxy.scrollTo(target, anchor: .top)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if model.phase == .brief {
                        dismiss()
                    } else {
                        model.goBack()
                    }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .accessibilityLabel(model.backButtonTitle)
            }
        }
        .tint(accent)
        .navigationTitle("Settlements")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Map

    private var mapSection: some View {
        ZStack(alignment: .bottom) {
            SettlementMapView(model: model) { siteID in
                handleSiteTap(siteID)
            }

            if let message = model.dropMessage {
                DropToast(message: message)
                    .padding(.bottom, 12)
            }
        }
        .animation(.easeOut(duration: 0.2), value: model.dropMessage)
    }

    private func handleSiteTap(_ siteID: SettlementSiteID) {
        switch model.phase {
        case .placing, .results:
            model.placeHomes(at: siteID)
        default:
            break
        }
    }

    // MARK: Phase panels

    @ViewBuilder
    private var phasePanel: some View {
        switch model.phase {
        case .brief:
            briefCard
        case .placing:
            placingCard
        case .predicting:
            predictingCard
        case .results:
            resultsCard
        case .comparing:
            comparingCard
        case .event:
            eventCard
        case .report:
            reportCards
        }
    }

    private var briefCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 11) {
                PhaseLabel(title: "Your brief", symbol: "doc.text.fill")

                Text("The council has space for three new homes. Where should they go?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 6) {
                    BriefPoint(symbol: "hand.draw.fill", text: "1. Choose Site A, B or C. Tap a site card or drag the homes on the map.")
                    BriefPoint(symbol: "circle.grid.2x2.fill", text: "2. Predict the pattern, then test your choice. Every prediction helps you learn.")
                    BriefPoint(symbol: "map.fill", text: "3. Test all three sites. Compare services, farmland and flood risk.")
                    BriefPoint(symbol: "text.quote", text: "4. Recommend a site with two pieces of evidence, then predict an event.")
                }

                PlannerPrimaryButton(title: "Start planning", symbol: "arrow.right") {
                    model.beginPlacing()
                }
                .padding(.top, 2)
            }
        }
    }

    private var placingCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    PhaseLabel(title: "Choose a site", symbol: "mappin.and.ellipse")
                    Spacer()
                    if model.testedCount > 0 {
                        Text("Tested \(model.testedCount) of 3")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(accent.opacity(0.10), in: Capsule())
                    }
                }

                if model.canCompare {
                    PlannerPrimaryButton(title: "Continue to recommendation", symbol: "arrow.right") {
                        model.startComparison()
                    }
                }

                Text("Tap an untested site below, or drag the homes onto its dashed spaces on the map. Tested sites open their results.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(SettlementMapData.sites) { site in
                    Button {
                        model.placeHomes(at: site.id)
                    } label: {
                        SiteSummaryCard(
                            site: site,
                            isTested: model.tested[site.id] != nil,
                            pattern: model.tested[site.id]?.assessment.pattern
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var predictingCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 10) {
                PhaseLabel(title: "Predict the pattern", symbol: "circle.grid.2x2.fill")

                if let site = model.placedSiteData {
                    SiteSummaryCard(site: site)
                }

                Text("If the three homes are built here, what pattern will they make?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(SettlementPattern.allCases) { pattern in
                    PatternOptionCard(
                        pattern: pattern,
                        isSelected: model.prediction == pattern
                    ) {
                        model.selectPrediction(pattern)
                    }
                }

                if model.prediction == nil {
                    Text("Select one pattern to enable the test.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                PlannerPrimaryButton(
                    title: "Test this site",
                    symbol: "checkmark.circle.fill",
                    isEnabled: model.prediction != nil
                ) {
                    model.testPlan()
                }

                PlannerSecondaryButton(title: "Choose a different site", symbol: "arrow.uturn.backward") {
                    model.testAnother()
                }
            }
        }
    }

    private var resultsCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 12) {
                PhaseLabel(title: "Test result", symbol: "checkmark.seal.fill")

                if let result = model.currentResult {
                    let site = SettlementMapData.site(for: result.site)
                    let assessment = result.assessment

                    PatternRevealCard(site: site, pattern: assessment.pattern)

                    Divider()

                    PredictionFeedbackCard(result: result)

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                        spacing: 8
                    ) {
                        MetricTile(
                            title: "Services",
                            value: "\(assessment.servicesWithinWalk) of 3",
                            note: "within 4 cells",
                            symbol: "figure.walk",
                            color: accent
                        )
                        MetricTile(
                            title: "Farmland",
                            value: assessment.farmlandLost == 0 ? "None" : "\(assessment.farmlandLost) cells",
                            note: "lost to homes",
                            symbol: "leaf.fill",
                            color: warning
                        )
                        MetricTile(
                            title: "Flood risk",
                            value: assessment.floodRisk.title,
                            note: "nearest river cell",
                            symbol: assessment.floodRisk.symbol,
                            color: assessment.floodRisk.color
                        )
                        MetricTile(
                            title: "Pattern",
                            value: assessment.pattern.title,
                            note: assessment.pattern.shortHint,
                            symbol: "circle.grid.2x2.fill",
                            color: assessment.pattern.color
                        )
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "road.lanes")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(accent)
                        Text(assessment.roadAccess)
                            .font(.subheadline)
                            .foregroundStyle(PlannerTheme.ink)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 11, style: .continuous))

                    Divider()

                    MapEvidenceCard(assessment: assessment, site: site)
                }

                if model.canCompare {
                    PlannerPrimaryButton(title: "Compare all three sites", symbol: "arrow.left.arrow.right") {
                        model.startComparison()
                    }
                } else {
                    PlannerPrimaryButton(title: "Choose next site (\(3 - model.testedCount) left)", symbol: "plus.circle.fill") {
                        model.testAnother()
                    }
                }
            }
        }
    }

    private var comparingCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 12) {
                PhaseLabel(title: "Compare and recommend", symbol: "scale.3d")

                Text("Weigh up access, services, farmland and flood risk. There is no perfect site.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ComparisonGrid(model: model)

                Divider()

                Text("Which site do you recommend?")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ink)

                RecommendationPicker(model: model)

                if model.recommendation != nil {
                    Divider()

                    HStack {
                        Text("Choose at least two pieces of map evidence.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(model.selectedEvidence.count) selected")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(model.selectedEvidence.count >= 2 ? accent : warning)
                    }

                    EvidenceChipRow(model: model)

                    RecommendationSentenceCard(
                        sentence: model.recommendationSentence,
                        count: model.selectedEvidence.count
                    )
                }

                if !model.canContinueToEvent {
                    Text(model.recommendation == nil
                         ? "Choose a site to see the evidence you can use."
                         : "Select at least two pieces of evidence to continue.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                PlannerPrimaryButton(
                    title: "Predict an event",
                    symbol: "arrow.right",
                    isEnabled: model.canContinueToEvent
                ) {
                    model.continueToEvent()
                }
            }
        }
    }

    private var eventCard: some View {
        PlannerCard {
            VStack(alignment: .leading, spacing: 12) {
                PhaseLabel(title: "Event", symbol: "bolt.fill")

                if let site = model.recommendationSite {
                    SiteSummaryCard(
                        site: site,
                        isTested: true,
                        pattern: model.recommendationResult?.assessment.pattern
                    )
                }

                EventCardView(model: model)

                if model.eventRevealed {
                    PlannerPrimaryButton(title: "See planner report", symbol: "doc.text.magnifyingglass") {
                        model.finish()
                    }
                } else {
                    if model.eventChoice == nil {
                        Text("Select an answer before checking your prediction.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    PlannerPrimaryButton(
                        title: "Check my prediction",
                        symbol: "sparkles",
                        isEnabled: model.eventChoice != nil
                    ) {
                        model.revealEvent()
                    }
                }
            }
        }
    }

    private var reportCards: some View {
        VStack(spacing: 14) {
            PlannerCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Text(model.recommendationSite?.id.letter ?? "?")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(model.recommendationSite?.color ?? accent, in: Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Planner report")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("You recommended \(model.recommendationSite?.id.title ?? "a site")")
                                .font(.headline)
                                .foregroundStyle(ink)
                            Text(model.recommendationSite?.name ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }

                    Text(model.recommendationSentence)
                        .font(.subheadline)
                        .foregroundStyle(PlannerTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        ReportStat(value: "\(model.testedCount)/3", label: "sites tested")
                        ReportStat(value: "\(model.predictionScore)/3", label: "patterns")
                        ReportStat(value: "\(model.selectedEvidence.count)", label: "evidence")
                        ReportStat(
                            value: model.eventCorrect ? "Yes" : "No",
                            label: "event"
                        )
                    }

                    if let site = model.recommendationSite {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Why it works", systemImage: "checkmark.circle.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(accent)
                            Text(site.bestFor)
                                .font(.subheadline)
                                .foregroundStyle(PlannerTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)

                            Label("Trade-off", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(warning)
                                .padding(.top, 2)
                            Text(site.tradeoff)
                                .font(.subheadline)
                                .foregroundStyle(PlannerTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(PlannerTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                }
            }

            PlannerCard {
                HierarchyLadder(
                    current: model.hierarchy,
                    homes: model.homes,
                    population: model.population
                )
            }

            PlannerCard {
                FunctionsCard()
            }

            PlannerCard {
                ServicesCard()
            }

            PlannerCard {
                VStack(alignment: .leading, spacing: 8) {
                    PhaseLabel(title: "Planner checks", symbol: "checklist")
                    ReportChecklist(checks: model.reportChecks)
                }
            }

            PlannerSecondaryButton(title: "Start again", symbol: "arrow.counterclockwise") {
                model.reset()
            }
        }
    }

    // MARK: Progress

    private var progress: Double {
        switch model.phase {
        case .brief: 0
        case .placing: 0.1 + Double(model.testedCount) * 0.18
        case .predicting: 0.14 + Double(model.testedCount) * 0.18
        case .results: 0.1 + Double(model.testedCount) * 0.18
        case .comparing: 0.7
        case .event: 0.85
        case .report: 1
        }
    }

    private var stepTitle: String {
        switch model.phase {
        case .brief: "Your mission"
        case .placing: "1 of 3 · Explore"
        case .predicting: "1 of 3 · Predict"
        case .results: "1 of 3 · Results"
        case .comparing: "2 of 3 · Recommend"
        case .event: "3 of 3 · Event"
        case .report: "Mission complete"
        }
    }
}

// MARK: - Header

private struct MissionHeader: View {
    let progress: Double
    let stepTitle: String

    private let ink = PlannerTheme.ink
    private let accent = PlannerTheme.accent

    var body: some View {
        PlannerCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Label("SETTLEMENT PLANNER", systemImage: "building.2.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)

                Text("Where should new homes go?")
                    .font(.title2.bold())
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                Text(stepTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)

                ProgressView(value: progress)
                    .tint(accent)
                    .accessibilityLabel("Mission progress")
            }
        }
    }
}

// MARK: - Small helpers

private struct PhaseLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.headline)
            .foregroundStyle(PlannerTheme.accent)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct BriefPoint: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(PlannerTheme.accent)
                .frame(width: 15)
                .padding(.top, 1)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(PlannerTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ReportStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(PlannerTheme.accent)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(PlannerTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SettlementPlannerView()
    }
    .environmentObject(TouchGlobeState())
}


private struct PlannerMapHeading: View {
    let testedCount: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                Label("Explore the map", systemImage: "map")
                Spacer()
                Text("\(testedCount) of 3 sites tested")
            }
            VStack(alignment: .leading, spacing: 6) {
                Label("Explore the map", systemImage: "map")
                Text("\(testedCount) of 3 sites tested")
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(PlannerTheme.accent)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Choose a site") {
    let model = SettlementPlannerModel()
    model.beginPlacing()
    return NavigationStack {
        SettlementPlannerView(model: model)
    }
    .environmentObject(TouchGlobeState())
}

#Preview("Compare sites") {
    let model = SettlementPlannerModel()
    for site in SettlementMapData.sites {
        model.placeHomes(at: site.id)
        model.selectPrediction(site.pattern)
        model.testPlan()
        model.testAnother()
    }
    model.startComparison()
    return NavigationStack {
        SettlementPlannerView(model: model)
    }
    .environmentObject(TouchGlobeState())
}
