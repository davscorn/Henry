import SwiftUI

enum AppTab: Hashable {
    case discover, plan, list, settings
}

struct RootView: View {
    @EnvironmentObject var model: AppModel
    @State var tab: AppTab = .discover

    var body: some View {
        TabView(selection: $tab) {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "fork.knife") }
                .tag(AppTab.discover)

            PlanView(goToList: { tab = .list }, goToDiscover: { tab = .discover })
                .tabItem { Label("This Week", systemImage: "calendar") }
                .badge(model.planned.count)
                .tag(AppTab.plan)

            ShoppingListView(goToDiscover: { tab = .discover })
                .tabItem { Label("List", systemImage: "cart") }
                .badge(model.remainingCount)
                .tag(AppTab.list)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
    }
}

#Preview {
    RootView().environmentObject(AppModel())
}
