import SwiftUI
import SwiftData
import SlateCore

struct TodayScreen: View {
    @Query(sort: \Milestone.deadline) private var milestones: [Milestone]
    @Query(filter: #Predicate<FeedbackNote> { $0.statusRaw == "open" })
    private var openNotes: [FeedbackNote]
    @Query(sort: \TimeBlock.start) private var blocks: [TimeBlock]

    private var nextDeadline: Milestone? {
        milestones.first { !$0.isCompleted && $0.deadline != nil }
    }

    var body: some View {
        NavigationStack {
            List {
                if let milestone = nextDeadline, let deadline = milestone.deadline {
                    Section(String(localized: "Next deadline")) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(milestone.title)
                                .font(.headline)
                            Text(deadline, format: .relative(presentation: .named))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }

                Section(String(localized: "Your plan")) {
                    if blocks.isEmpty {
                        ContentUnavailableView(
                            String(localized: "No blocks yet"),
                            systemImage: "calendar.badge.clock",
                            description: Text(String(localized: "Pull to refresh once the scheduler is wired."))
                        )
                    } else {
                        ForEach(blocks) { block in
                            TimeBlockRow(block: block)
                        }
                    }
                }

                if !openNotes.isEmpty {
                    Section(String(localized: "Feedback inbox")) {
                        NavigationLink {
                            Text(String(localized: "Feedback dashboard coming soon"))
                        } label: {
                            Label(
                                String(localized: "\(openNotes.count) unresolved notes"),
                                systemImage: "bubble.left.and.text.bubble.right"
                            )
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Today"))
        }
    }
}

private struct TimeBlockRow: View {
    let block: TimeBlock

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(block.start, format: .dateTime.hour().minute())
                    .font(.caption.monospacedDigit())
                Text(block.state.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 56, alignment: .leading)

            Text(String(localized: "Work block"))
                .font(.body)

            Spacer()

            Text("\(block.plannedMinutes)m")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TodayScreen()
        .modelContainer(PreviewData.container())
}
