import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddAccount = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(showAddAccount: $showAddAccount)
                .tabItem {
                    Label("Overzicht", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            AccountListView(showAddAccount: $showAddAccount)
                .tabItem {
                    Label("Accounts", systemImage: "person.2.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Instellingen", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(AppTheme.accent)
        .sheet(isPresented: $showAddAccount) {
            AccountFormView(mode: .add)
        }
    }
}
