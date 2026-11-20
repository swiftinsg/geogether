import SwiftUI

struct FieldGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var curriculum: GeographyCurriculum

    var body: some View {
        NavigationStack {
            List {
                Section("Level \(curriculum.playerLevel) · Geography guide") {
                    ForEach(curriculum.quests) { quest in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(quest.topic)
                                    .font(.headline)
                                Spacer()
                                Text(quest.isCompleted ? "Mastered" : quest.zoneName)
                                    .font(.caption.bold())
                                    .foregroundStyle(quest.isCompleted ? .green : .blue)
                            }

                            ForEach(quest.fieldNotes, id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Field Guide")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(.blue)
    }
}
