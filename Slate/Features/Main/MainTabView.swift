import SwiftUI
import SlateCore

/// Root tab navigation (§5.5.1).
struct MainTabView: View {
    var body: some View {
        TabView {
            TodayScreen()
                .tabItem {
                    Label(String(localized: "Today"), systemImage: "sun.max")
                }

            ProjectsScreen()
                .tabItem {
                    Label(String(localized: "Projects"), systemImage: "film.stack")
                }

            InboxScreen()
                .tabItem {
                    Label(String(localized: "Inbox"), systemImage: "tray.and.arrow.down")
                }

            YouScreen()
                .tabItem {
                    Label(String(localized: "You"), systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container())
}
