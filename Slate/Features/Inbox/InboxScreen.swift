import SwiftUI
import SwiftData
import SlateCore

struct InboxScreen: View {
    @Query(sort: \IdeaNote.capturedAt, order: .reverse) private var ideas: [IdeaNote]

    var body: some View {
        NavigationStack {
            Group {
                if ideas.isEmpty {
                    ContentUnavailableView(
                        String(localized: "Inbox empty"),
                        systemImage: "tray",
                        description: Text(String(localized: "Ideas captured from Watch or Siri land here."))
                    )
                } else {
                    List(ideas) { idea in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(idea.text)
                            Text(idea.capturedAt, format: .relative(presentation: .named))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Inbox"))
        }
    }
}

#Preview {
    InboxScreen()
        .modelContainer(PreviewData.container())
}
