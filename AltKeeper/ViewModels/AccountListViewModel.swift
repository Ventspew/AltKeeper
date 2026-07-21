import Foundation

@MainActor
final class AccountListViewModel: ObservableObject {
    @Published var filters = AccountListFilters()

    func filteredAccounts(from accounts: [GameAccount]) -> [GameAccount] {
        AccountQueryService.filterAndSort(accounts: accounts, filters: filters)
    }

    func groupedAccounts(from accounts: [GameAccount]) -> [(platform: GamePlatform, accounts: [GameAccount])] {
        AccountQueryService.groupedByPlatform(filteredAccounts(from: accounts))
    }

    func availableRegions(from accounts: [GameAccount]) -> [String] {
        AccountQueryService.uniqueRegions(from: accounts)
    }

    func resetFilters() {
        filters = AccountListFilters()
    }
}
