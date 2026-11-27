import SwiftUI

// MARK: - Shared containers

struct PlannerCard<Content: View>: View {
    var padding: CGFloat = 14
    private let content: Content

    init(padding: CGFloat = 14, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color(red: 0.80, green: 0.85, blue: 0.76), lineWidth: 1)
            }
            .shadow(color: Color(red: 0.24, green: 0.36, blue: 0.25).opacity(0.07), radius: 10, y: 4)
    }
}

struct PlannerPrimaryButton: View {
    let title: String
    var symbol: String?
    var color = Color(red: 0.20, green: 0.48, blue: 0.34)
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol)
                }
                Text(title)
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(color.opacity(isEnabled ? 1 : 0.38), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PlannerPressStyle())
        .disabled(!isEnabled)
    }
}

struct PlannerSecondaryButton: View {
    let title: String
    var symbol: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol)
                }
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color(red: 0.22, green: 0.36, blue: 0.28))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color(red: 0.75, green: 0.82, blue: 0.72), lineWidth: 1)
            }
        }
        .buttonStyle(PlannerPressStyle())
    }
}

private struct PlannerPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

// MARK: - Cat guide

struct CatGuideCard: View {
    let message: String
    let hintLabel: String
    let canShowHint: Bool
    let onHint: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            PlannerCat()
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text("Pip the planner")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(red: 0.34, green: 0.48, blue: 0.36))

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Color(red: 0.20, green: 0.28, blue: 0.22))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)

            Button(action: onHint) {
                VStack(spacing: 2) {
                    Image(systemName: canShowHint ? "lightbulb.fill" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                    Text(canShowHint ? hintLabel : "Done")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                }
                .foregroundStyle(canShowHint ? Color(red: 0.55, green: 0.40, blue: 0.10) : Color(red: 0.40, green: 0.52, blue: 0.40))
                .frame(width: 46, height: 38)
                .background(
                    (canShowHint ? Color(red: 0.98, green: 0.92, blue: 0.72) : Color(red: 0.90, green: 0.94, blue: 0.88)),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }
            .buttonStyle(PlannerPressStyle())
            .disabled(!canShowHint)
            .accessibilityLabel("Show hint")
        }
        .padding(10)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(red: 0.80, green: 0.85, blue: 0.76), lineWidth: 1)
        }
    }
}

// MARK: - Site summaries

struct SiteSummaryCard: View {
    let site: SettlementSite
    var isTested = false
    var pattern: SettlementPattern?

    var body: some View {
        HStack(spacing: 10) {
            Text(site.id.letter)
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(site.color, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(site.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))
                Text(site.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 2)

            if let pattern {
                Text(pattern.title)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(pattern.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(pattern.color.opacity(0.12), in: Capsule())
            } else if isTested {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(site.color)
            }
        }
        .padding(9)
        .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(site.color.opacity(0.22), lineWidth: 1)
        }
    }
}

// MARK: - Prediction

struct PatternOptionCard: View {
    let pattern: SettlementPattern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                PatternGlyph(pattern: pattern, size: 34)

                VStack(alignment: .leading, spacing: 1) {
                    Text(pattern.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))
                    Text(pattern.shortHint)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 2)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? pattern.color : Color(red: 0.70, green: 0.75, blue: 0.68))
            }
            .padding(9)
            .background(
                isSelected ? pattern.color.opacity(0.12) : Color.white,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? pattern.color : Color(red: 0.80, green: 0.85, blue: 0.76),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(PlannerPressStyle())
    }
}

struct PredictionFeedbackCard: View {
    let result: SiteResult

    private var site: SettlementSite {
        SettlementMapData.site(for: result.site)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: result.predictionCorrect ? "checkmark.seal.fill" : "arrow.triangle.branch")
                .font(.title3)
                .foregroundStyle(result.predictionCorrect ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.75, green: 0.48, blue: 0.16))

            VStack(alignment: .leading, spacing: 3) {
                Text(result.predictionCorrect ? "Prediction correct" : "Prediction check")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))

                if result.predictionCorrect {
                    Text("You predicted \(result.prediction.title.lowercased()). \(site.id.title) creates a \(site.pattern.title.lowercased()) pattern.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("You predicted \(result.prediction.title.lowercased()), but \(site.id.title) creates a \(site.pattern.title.lowercased()) pattern.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(site.pattern.definition)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.32, green: 0.40, blue: 0.33))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Results

struct PatternRevealCard: View {
    let site: SettlementSite
    let pattern: SettlementPattern

    var body: some View {
        HStack(spacing: 12) {
            PatternGlyph(pattern: pattern, size: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(site.id.title) is \(pattern.title.lowercased())")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))
                Text(pattern.definition)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let note: String
    let symbol: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Label(title, systemImage: symbol)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)

            Text(value)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(note)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .frame(maxWidth: .infinity, minHeight: 68, alignment: .topLeading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

struct MapEvidenceCard: View {
    let assessment: SiteAssessment
    let site: SettlementSite

    private var items: [(symbol: String, text: String)] {
        [
            ("circle.grid.2x2.fill", "The homes at \(site.cellLabels) form a \(site.pattern.title.lowercased()) pattern."),
            ("road.lanes", "\(assessment.roadAccess). \(assessment.serviceSummary)."),
            ("figure.walk", "\(assessment.servicesWithinWalk) of 3 local services are within 4 cells, about a 10-minute walk."),
            ("leaf.fill", assessment.farmlandLost == 0 ? "No farmland is lost." : "\(assessment.farmlandLost) farmland cells are lost."),
            ("drop.fill", "Flood risk is \(assessment.floodRisk.title.lowercased()).")
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Map evidence", systemImage: "map.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: item.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 0.30, green: 0.48, blue: 0.34))
                        .frame(width: 14)
                        .padding(.top, 1)

                    Text(item.text)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Comparison

struct ComparisonGrid: View {
    @ObservedObject var model: SettlementPlannerModel

    private let sites = SettlementMapData.sites

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 5, verticalSpacing: 7) {
            GridRow {
                Text("")
                ForEach(sites) { site in
                    VStack(spacing: 1) {
                        Text(site.id.title)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(site.color)
                        Text(model.tested[site.id]?.assessment.pattern.title ?? "Not tested")
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Divider()
                .gridCellColumns(4)

            row("Pattern") { site in
                model.tested[site.id]?.assessment.pattern.title ?? "—"
            }
            row("Road") { site in
                switch site.id {
                case .a: "Main road"
                case .b: "Riverside lane"
                case .c: "Farm lane"
                }
            }
            row("Services") { site in
                guard let result = model.tested[site.id] else { return "—" }
                return "\(result.assessment.servicesWithinWalk) of 3"
            }
            row("Farmland") { site in
                guard let result = model.tested[site.id] else { return "—" }
                return result.assessment.farmlandLost == 0 ? "None" : "\(result.assessment.farmlandLost) cells"
            }
            row("Flood") { site in
                model.tested[site.id]?.assessment.floodRisk.title ?? "—"
            }
        }
    }

    private func row(_ label: String, value: @escaping (SettlementSite) -> String) -> some View {
        GridRow {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.34, green: 0.42, blue: 0.35))

            ForEach(sites) { site in
                Text(value(site))
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.25))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct RecommendationPicker: View {
    @ObservedObject var model: SettlementPlannerModel

    var body: some View {
        HStack(spacing: 6) {
            ForEach(SettlementMapData.sites) { site in
                let isSelected = model.recommendation == site.id

                Button {
                    model.recommend(site.id)
                } label: {
                    VStack(spacing: 3) {
                        Text(site.id.title)
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(site.color)
                        PatternGlyph(pattern: site.pattern, size: 22)
                        Text(site.name)
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        isSelected ? site.color.opacity(0.14) : Color.white,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                isSelected ? site.color : Color(red: 0.80, green: 0.85, blue: 0.76),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
                }
                .buttonStyle(PlannerPressStyle())
            }
        }
    }
}

struct EvidenceChipRow: View {
    @ObservedObject var model: SettlementPlannerModel

    var body: some View {
        VStack(spacing: 6) {
            ForEach(model.evidenceChips) { chip in
                let isSelected = model.selectedEvidence.contains(chip.id)

                Button {
                    model.toggleEvidence(chip.id)
                } label: {
                    HStack(alignment: .top, spacing: 7) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(isSelected ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.70, green: 0.75, blue: 0.68))

                        Image(systemName: chip.symbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))
                            .frame(width: 14)
                            .padding(.top, 1)

                        Text(chip.text)
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.25))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)

                        Spacer(minLength: 0)
                    }
                    .padding(8)
                    .background(
                        isSelected ? Color(red: 0.24, green: 0.55, blue: 0.35).opacity(0.09) : Color.white,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.82, green: 0.86, blue: 0.79),
                                lineWidth: isSelected ? 1.6 : 1
                            )
                    }
                }
                .buttonStyle(PlannerPressStyle())
            }
        }
    }
}

struct RecommendationSentenceCard: View {
    let sentence: String
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label("Your explanation", systemImage: "text.quote")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))
                Spacer()
                Text("\(count)/2+ evidence")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(count >= 2 ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.70, green: 0.48, blue: 0.18))
            }

            Text(sentence)
                .font(.caption)
                .italic()
                .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .background(Color(red: 0.96, green: 0.97, blue: 0.92), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Event

struct EventCardView: View {
    @ObservedObject var model: SettlementPlannerModel

    var body: some View {
        if let event = model.event {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: event.symbol)
                        .font(.title3)
                        .foregroundStyle(Color(red: 0.72, green: 0.40, blue: 0.22))
                        .frame(width: 34, height: 34)
                        .background(Color(red: 0.98, green: 0.90, blue: 0.78), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Event card")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.72, green: 0.40, blue: 0.22))
                        Text(event.title)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color(red: 0.18, green: 0.26, blue: 0.20))
                    }
                }

                Text(event.prompt)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 6) {
                    ForEach(event.options) { option in
                        let isSelected = model.eventChoice == option.id
                        let isCorrect = option.id == event.correctOptionID

                        Button {
                            model.selectEventOption(option.id)
                        } label: {
                            HStack(alignment: .top, spacing: 7) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(
                                        isSelected
                                            ? (model.eventRevealed && !isCorrect ? Color(red: 0.72, green: 0.25, blue: 0.22) : Color(red: 0.24, green: 0.55, blue: 0.35))
                                            : Color(red: 0.70, green: 0.75, blue: 0.68)
                                    )

                                Text(option.text)
                                    .font(.caption)
                                    .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.25))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)

                                Spacer(minLength: 0)
                            }
                            .padding(8)
                            .background(
                                isSelected ? Color(red: 0.96, green: 0.94, blue: 0.84) : Color.white,
                                in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .strokeBorder(
                                        isSelected ? Color(red: 0.72, green: 0.55, blue: 0.24) : Color(red: 0.82, green: 0.86, blue: 0.79),
                                        lineWidth: 1
                                    )
                            }
                        }
                        .buttonStyle(PlannerPressStyle())
                        .disabled(model.eventRevealed)
                    }
                }

                if model.eventRevealed {
                    VStack(alignment: .leading, spacing: 5) {
                        Label(
                            model.eventCorrect ? "Good prediction" : "Check the map evidence",
                            systemImage: model.eventCorrect ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                        )
                        .font(.caption.weight(.bold))
                        .foregroundStyle(model.eventCorrect ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.72, green: 0.40, blue: 0.22))

                        Text(event.reveal)
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(event.evidence)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(9)
                    .background(Color(red: 0.96, green: 0.97, blue: 0.92), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Report

struct HierarchyLadder: View {
    let current: SettlementHierarchyLevel
    let homes: Int
    let population: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label("Settlement hierarchy", systemImage: "building.2.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))
                Spacer()
                Text("Simulated")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.92, green: 0.94, blue: 0.89), in: Capsule())
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(SettlementMapData.hierarchyLevels) { level in
                        let isCurrent = level == current

                        VStack(spacing: 2) {
                            Image(systemName: level.symbol)
                                .font(.system(size: 12, weight: .semibold))
                            Text(level.title)
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            Text(level.populationLabel)
                                .font(.system(size: 7))
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                        .foregroundStyle(isCurrent ? .white : Color(red: 0.38, green: 0.45, blue: 0.38))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minWidth: 64)
                        .background(
                            isCurrent ? Color(red: 0.20, green: 0.48, blue: 0.34) : Color(red: 0.94, green: 0.96, blue: 0.91),
                            in: RoundedRectangle(cornerRadius: 11, style: .continuous)
                        )
                    }
                }
            }

            Text("\(homes) homes, about \(population) people. A village needs more homes and services.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FunctionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label("Functions on this map", systemImage: "briefcase.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))

            ForEach(SettlementMapData.sectors) { sector in
                HStack(spacing: 8) {
                    Image(systemName: sector.symbol)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(sector.color)
                        .frame(width: 20, height: 20)
                        .background(sector.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

                    Text(sector.title)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.25))
                        .frame(width: 62, alignment: .leading)

                    Text(sector.examples)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct ServicesCard: View {
    private let local = SettlementMapData.localServices
    private let town = SettlementMapData.townServices

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Services and travel", systemImage: "figure.walk")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))

            Text("Low-order services are close together. High-order services are farther away.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 6) {
                ForEach(local) { service in
                    ServiceBadge(service: service)
                }
            }

            HStack(spacing: 6) {
                ForEach(town) { service in
                    ServiceBadge(service: service)
                }
            }
        }
    }
}

private struct ServiceBadge: View {
    let service: SettlementService

    var body: some View {
        VStack(spacing: 3) {
            Group {
                if let imageName = service.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: service.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.28, green: 0.46, blue: 0.34))
                }
            }
            .frame(height: 30)

            Text(service.title)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.24, green: 0.31, blue: 0.25))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(service.isTown ? "Town" : "Village")
                .font(.system(size: 7, weight: .semibold, design: .rounded))
                .foregroundStyle(service.isTown ? Color(red: 0.72, green: 0.40, blue: 0.22) : Color(red: 0.30, green: 0.50, blue: 0.34))
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(.white, in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .strokeBorder(Color(red: 0.82, green: 0.86, blue: 0.79), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(service.title). \(service.note)")
    }
}

struct ReportChecklist: View {
    let checks: [(title: String, passed: Bool)]

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(Array(checks.enumerated()), id: \.offset) { _, check in
                HStack(spacing: 7) {
                    Image(systemName: check.passed ? "checkmark.circle.fill" : "circle.dashed")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(check.passed ? Color(red: 0.24, green: 0.55, blue: 0.35) : Color(red: 0.65, green: 0.70, blue: 0.63))

                    Text(check.title)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))

                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Map key

struct MapKeyCard: View {
    private let items: [(SettlementTerrain, String)] = [
        (.river, "River"),
        (.road, "Main road"),
        (.lane, "Lane"),
        (.steep, "Steep land"),
        (.farmland, "Farmland"),
        (.woods, "Woods")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Map key", systemImage: "square.grid.3x3.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.32, green: 0.46, blue: 0.34))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 5) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 5) {
                        TerrainSwatch(terrain: item.0, size: CGSize(width: 24, height: 16))
                        Text(item.1)
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.28, green: 0.35, blue: 0.29))
                    }
                }
            }

            HStack(spacing: 5) {
                Image(systemName: "square.dashed")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 0.30, green: 0.48, blue: 0.34))
                Text("Dashed outline = possible site")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DropToast: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "hand.draw.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.72, green: 0.32, blue: 0.22), in: Capsule())
            .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
