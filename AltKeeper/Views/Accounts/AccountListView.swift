import SwiftUI
import SwiftData

struct AccountListView: View {
    @Query(sort: \GameAccount.displayName) private var accounts: [GameAccount]
    @StateObject private var viewModel = AccountListViewModel()
    @ObservedObject private var settings = AppSettings.shared
    @Binding var showAddAccount: Bool

    @State private var showFilterSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if accounts.isEmpty {
                    EmptyStateView(
                        title: "Nog geen accounts toegevoegd",
                        message: "Voeg je eerste game-account toe om je logins bij te houden.",
                        systemImage: "tray",
                        actionTitle: "Account toevoegen"
                    ) {
                        showAddAccount = true
                    }
                } else {
                    let groups = viewModel.groupedAccounts(from: accounts)
                    let filteredCount = viewModel.filteredAccounts(from: accounts).count

                    if groups.isEmpty {
                        EmptyStateView(
                            title: "Geen accounts gevonden",
                            message: "Geen accounts gevonden voor dit filter.",
                            systemImage: "magnifyingglass",
                            actionTitle: "Filters wissen"
                        ) {
                            viewModel.resetFilters()
                        }
                    } else {
                        List {
                            if viewModel.filters.hasActiveFilters {
                                Section {
                                    activeFilterSummary(count: filteredCount)
                                }
                            }

                            ForEach(groups, id: \.platform) { group in
                                Section {
                                    ForEach(group.accounts, id: \.id) { account in
                                        NavigationLink {
                                            AccountDetailView(account: account)
                                        } label: {
                                            AccountRowView(
                                                account: account,
                                                hideEmail: settings.hideEmailAddresses
                                            )
                                        }
                                    }
                                } header: {
                                    HStack(spacing: 8) {
                                        PlatformIconView(platform: group.platform, size: 22)
                                        Text(group.platform.displayName)
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Text("\(group.accounts.count)")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.filters.searchText,
                prompt: "Zoek op naam, e-mail of platform"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Label("Filter", systemImage: viewModel.filters.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filters")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Label("Toevoegen", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                AccountFilterSheet(
                    filters: $viewModel.filters,
                    regions: viewModel.availableRegions(from: accounts)
                )
            }
            .appScreenBackground()
        }
    }

    @ViewBuilder
    private func activeFilterSummary(count: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(count) resultaten")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if let platform = viewModel.filters.selectedPlatform {
                        FilterChip(title: platform.displayName, isSelected: true) {
                            viewModel.filters.selectedPlatform = nil
                        }
                    }
                    if let region = viewModel.filters.selectedRegion {
                        FilterChip(title: region, isSelected: true) {
                            viewModel.filters.selectedRegion = nil
                        }
                    }
                    if viewModel.filters.primaryOnly {
                        FilterChip(title: "Primair", isSelected: true) {
                            viewModel.filters.primaryOnly = false
                        }
                    }
                    if viewModel.filters.missingTwoFactorOnly {
                        FilterChip(title: "Zonder 2FA", isSelected: true) {
                            viewModel.filters.missingTwoFactorOnly = false
                        }
                    }
                    FilterChip(title: "Alles wissen", isSelected: false) {
                        viewModel.resetFilters()
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

private struct AccountFilterSheet: View {
    @Binding var filters: AccountListFilters
    let regions: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Platform") {
                    Picker("Platform", selection: $filters.selectedPlatform) {
                        Text("Alle platforms").tag(GamePlatform?.none)
                        ForEach(GamePlatform.allCases) { platform in
                            Text(platform.displayName).tag(GamePlatform?.some(platform))
                        }
                    }
                }

                Section("Regio") {
                    Picker("Regio", selection: $filters.selectedRegion) {
                        Text("Alle regio's").tag(String?.none)
                        ForEach(regions, id: \.self) { region in
                            Text(region).tag(String?.some(region))
                        }
                    }
                }

                Section("Filters") {
                    Toggle("Alleen primaire accounts", isOn: $filters.primaryOnly)
                    Toggle("Zonder 2FA", isOn: $filters.missingTwoFactorOnly)
                }

                Section("Sorteren") {
                    Picker("Sorteer op", selection: $filters.sortOption) {
                        ForEach(AccountSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Toggle("Oplopend", isOn: $filters.sortAscending)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filters = AccountListFilters(searchText: filters.searchText)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gereed") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
