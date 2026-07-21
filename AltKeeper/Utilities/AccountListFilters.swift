import Foundation

enum AccountSortOption: String, CaseIterable, Identifiable {
    case lastLogin = "Laatste login"
    case name = "Naam"
    case platform = "Platform"

    var id: String { rawValue }
}

struct AccountListFilters: Equatable {
    var searchText: String = ""
    var selectedPlatform: GamePlatform?
    var selectedRegion: String?
    var primaryOnly: Bool = false
    var missingTwoFactorOnly: Bool = false
    var sortOption: AccountSortOption = .lastLogin
    var sortAscending: Bool = false

    var hasActiveFilters: Bool {
        selectedPlatform != nil ||
        selectedRegion != nil ||
        primaryOnly ||
        missingTwoFactorOnly ||
        !searchText.isBlank
    }
}
