import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "timeline")
                }

            TagsView()
                .tabItem {
                    Label("Tags", systemImage: "tag")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
