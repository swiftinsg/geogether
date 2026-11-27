import SwiftUI

struct SettlementPlannerView: View {
    @StateObject private var model = SettlementPlannerModel()
    @Environment(\.dismiss) private var dismiss

    private let background = Color(red: 0.96, green: 0.98, blue: 0.95)
    private let ink = Color(red: 0.16, green: 0.28, blue: 0.24)
    private let accent = Color(red: 0.20, green: 0.48, blue: 0.34)
    private let warning = Color(red: 0.72, green: 0.42, blue: 0.18)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    MissionHeader(progress: progress, stepTitle: stepTitle)

                    CatGuideCard(
                        message: model.catMessage,
                        hintLabel: model.hintLabel,
                        canShowHint: model.canShowHint,
                        onHint: { model.nextHint() }
                    )

                    mapSection

                    phasePanel

                    if model.phase != .report {
                        PlannerCard {
                            MapKeyCard()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 30)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "globe.badge.chevron.backward")
                        .font(.body)
                }
                .accessibilityLabel("Back")
            }
        }
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
        case .brief, .placing:
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
                    BriefPoint(symbol: "hand.draw.fill", text: "Drag the three homes onto a dashed site, or tap a site.")
                    BriefPoint(symbol: "circle.grid.2x2.fill", text: "Predict the settlement pattern the homes will make.")
                    BriefPoint(symbol: "map.fill", text: "Test all three sites and compare the map evidence.")
                    BriefPoint(symbol: "text.quote", text: "Recommend one site with at least two pieces of evidence.")
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
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(accent.opacity(0.10), in: Capsule())
                    }
                }

                Text("Drag the homes onto a dashed site. You can also tap a site to place them.")
                    .font(.caption)
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
                    .font(.caption)
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
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
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
                    PlannerPrimaryButton(title: "Test another site", symbol: "plus.circle.fill") {
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
                    .font(.caption)
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
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(model.selectedEvidence.count) selected")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(model.selectedEvidence.count >= 2 ? accent : warning)
                    }

                    EvidenceChipRow(model: model)

                    RecommendationSentenceCard(
                        sentence: model.recommendationSentence,
                        count: model.selectedEvidence.count
                    )
                }

                PlannerPrimaryButton(
                    title: "Continue to event",
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
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("You recommended \(model.recommendationSite?.id.title ?? "a site")")
                                .font(.headline)
                                .foregroundStyle(ink)
                            Text(model.recommendationSite?.name ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer(minLength: 0)
                    }

                    Text(model.recommendationSentence)
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.24, green: 0.32, blue: 0.26))
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
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                                .fixedSize(horizontal: false, vertical: true)

                            Label("Trade-off", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(warning)
                                .padding(.top, 2)
                            Text(site.tradeoff)
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.96, green: 0.97, blue: 0.92), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
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
        case .brief: 0.06
        case .placing: 0.14
        case .predicting: 0.32
        case .results: 0.50
        case .comparing: 0.68
        case .event: 0.85
        case .report: 1.0
        }
    }

    private var stepTitle: String {
        switch model.phase {
        case .brief: "Brief"
        case .placing: "Choose a site"
        case .predicting: "Predict"
        case .results: "Test"
        case .comparing: "Compare"
        case .event: "Event"
        case .report: "Report"
        }
    }
}

// MARK: - Header

private struct MissionHeader: View {
    let progress: Double
    let stepTitle: String

    private let ink = Color(red: 0.16, green: 0.28, blue: 0.24)
    private let accent = Color(red: 0.20, green: 0.48, blue: 0.34)

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 10) {
                Image(systemName: "building.2.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.19, green: 0.43, blue: 0.76), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 1) {
                    Text("MISSION")
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("Where should new homes go?")
                        .font(.headline)
                        .foregroundStyle(ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 4)

                Text(stepTitle)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.10), in: Capsule())
            }

            ProgressView(value: progress)
                .tint(accent)
        }
        .padding(12)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(red: 0.80, green: 0.85, blue: 0.76), lineWidth: 1)
        }
        .shadow(color: Color(red: 0.24, green: 0.36, blue: 0.25).opacity(0.07), radius: 10, y: 4)
    }
}

// MARK: - Small helpers

private struct PhaseLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))
    }
}

private struct BriefPoint: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(red: 0.30, green: 0.48, blue: 0.34))
                .frame(width: 15)
                .padding(.top, 1)

            Text(text)
                .font(.caption)
                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
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
                .foregroundStyle(Color(red: 0.20, green: 0.48, blue: 0.34))
            Text(label)
                .font(.system(size: 8, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(red: 0.94, green: 0.96, blue: 0.91), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        SettlementPlannerView()
    }
    .environmentObject(TouchGlobeState())
}
