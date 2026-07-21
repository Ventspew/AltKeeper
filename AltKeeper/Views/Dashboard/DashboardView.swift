import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \GameAccount.updatedAt, order: .reverse) private var accounts: [GameAccount]
    @StateObject private var viewModel = DashboardViewModel()
    @Binding var showAddAccount: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.sectionSpacing) {
                    AppBrandingHeader(subtitle: "Houd al je game-accounts bij")

                    if accounts.isEmpty {
                        EmptyStateView(
                            title: "Nog geen accounts toegevoegd",
                            message: "Voeg je eerste game-account toe om je logins bij te houden.",
                            systemImage: "gamecontroller",
                            actionTitle: "Account toevoegen"
                        ) {
                            showAddAccount = true
                        }
                        .frame(minHeight: 360)
                    } else {
                        let stats = viewModel.stats(from: accounts)

                        statsGrid(stats: stats)

                        Button {
                            showAddAccount = true
                        } label: {
                            Label("Account toevoegen", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityHint("Opent het formulier om een nieuw game-account toe te voegen")

                        if !stats.upcomingReminders.isEmpty {
                            DashboardCard(title: "Binnenkort controleren", systemImage: "bell.badge.fill") {
                                VStack(spacing: 0) {
                                    ForEach(Array(stats.upcomingReminders.prefix(5).enumerated()), id: \.element.id) { index, account in
                                        DashboardAccountLink(account: account)
                                        if index < min(stats.upcomingReminders.count, 5) - 1 {
                                            Divider().padding(.leading, 52)
                                        }
                                    }
                                }
                            }
                        }

                        if !stats.accountsWithoutTwoFactor.isEmpty {
                            DashboardCard(title: "Zonder 2FA", systemImage: "lock.slash.fill") {
                                VStack(spacing: 0) {
                                    ForEach(Array(stats.accountsWithoutTwoFactor.prefix(5).enumerated()), id: \.element.id) { index, account in
                                        DashboardAccountLink(account: account)
                                        if index < min(stats.accountsWithoutTwoFactor.count, 5) - 1 {
                                            Divider().padding(.leading, 52)
                                        }
                                    }
                                }
                            }
                        }

                        if !stats.recentlyUpdated.isEmpty {
                            DashboardCard(title: "Recent bijgewerkt", systemImage: "clock.arrow.circlepath") {
                                VStack(spacing: 0) {
                                    ForEach(Array(stats.recentlyUpdated.enumerated()), id: \.element.id) { index, account in
                                        DashboardAccountLink(account: account)
                                        if index < stats.recentlyUpdated.count - 1 {
                                            Divider().padding(.leading, 52)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .navigationTitle("Overzicht")
            .navigationBarTitleDisplayMode(.inline)
            .appScreenBackground()
        }
    }

    @ViewBuilder
    private func statsGrid(stats: DashboardViewModel.DashboardStats) -> some View {
        HStack(spacing: 12) {
            DashboardCard(title: "Accounts", systemImage: "person.2.fill") {
                StatBadge(
                    value: "\(stats.totalAccounts)",
                    label: "Totaal",
                    systemImage: "number"
                )
            }

            DashboardCard(title: "Platforms", systemImage: "square.grid.2x2.fill") {
                StatBadge(
                    value: "\(stats.platformCount)",
                    label: "Actief",
                    systemImage: "gamecontroller.fill"
                )
            }
        }
    }
}
