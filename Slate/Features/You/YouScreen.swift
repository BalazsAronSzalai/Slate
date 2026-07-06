import SwiftUI
import SlateCore

struct YouScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "Settings")) {
                    LabeledContent(String(localized: "Morning briefing"), value: "07:30")
                    LabeledContent(String(localized: "Work hours"), value: "09:00 – 21:00")
                }

                Section(String(localized: "About")) {
                    LabeledContent(String(localized: "Version"), value: "0.1.0")
                    Text(String(localized: "SLATE — film-school command center + SLATE Write screenplay editor."))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(localized: "You"))
        }
    }
}

#Preview {
    YouScreen()
}
