import Foundation
import SwiftData

enum AccountUpdateService {
    @MainActor
    static func markLoggedInToday(
        account: GameAccount,
        notificationService: NotificationService = .shared
    ) async throws {
        let now = Date()
        account.lastLoginDate = now
        account.nextLoginReminderDate = ReminderCalculationService.nextReminderDate(
            from: now,
            interval: account.reminderInterval
        )
        account.updatedAt = now

        if AppSettings.shared.notificationsEnabled {
            notificationService.cancelReminder(for: account.id)
            try await notificationService.scheduleReminder(for: account)
        }
    }

    static func updateReminderDate(
        for account: GameAccount,
        interval: ReminderInterval,
        customDate: Date? = nil,
        baseDate: Date? = nil
    ) {
        let reference = baseDate ?? account.lastLoginDate ?? Date()
        account.reminderInterval = interval
        account.nextLoginReminderDate = ReminderCalculationService.nextReminderDate(
            from: reference,
            interval: interval,
            customDate: customDate
        )
        account.updatedAt = Date()
    }
}

enum SampleDataService {
    static func seedSampleAccounts(into context: ModelContext) {
        #if DEBUG
        let existing = (try? context.fetch(FetchDescriptor<GameAccount>())) ?? []
        guard existing.isEmpty else { return }

        let samples: [GameAccount] = [
            GameAccount(
                platform: .playStation,
                displayName: "Hoofdaccount Nederland",
                username: "nl_gamer_main",
                emailAddress: "nl.gamer@example.com",
                region: "Nederland",
                accountType: "Primair",
                lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -2, to: Date()),
                isPrimaryAccount: true,
                twoFactorEnabled: true,
                recoveryCodesStored: true,
                reminderInterval: .oneYear
            ),
            GameAccount(
                platform: .playStation,
                displayName: "Verenigde Staten",
                username: "us_gamer_alt",
                emailAddress: "us.gamer@example.com",
                region: "Verenigde Staten",
                accountType: "Secundair",
                lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -18, to: Date()),
                twoFactorEnabled: true,
                recoveryCodesStored: false,
                reminderInterval: .twoYears
            ),
            GameAccount(
                platform: .playStation,
                displayName: "Japan",
                username: "jp_gamer",
                emailAddress: "jp.gamer@example.com",
                region: "Japan",
                accountType: "Regionaal",
                lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -22, to: Date()),
                twoFactorEnabled: false,
                recoveryCodesStored: false,
                reminderInterval: .twoAndHalfYears
            ),
            GameAccount(
                platform: .steam,
                displayName: "Hoofdaccount",
                username: "steam_main_user",
                emailAddress: "steam.main@example.com",
                region: "EU",
                accountType: "Primair",
                lastLoginDate: Calendar.appCalendar.date(byAdding: .day, value: -7, to: Date()),
                isPrimaryAccount: true,
                twoFactorEnabled: true,
                recoveryCodesStored: true,
                reminderInterval: .sixMonths
            ),
            GameAccount(
                platform: .xbox,
                displayName: "Testaccount",
                username: "xbox_test",
                emailAddress: "xbox.test@example.com",
                region: "Nederland",
                accountType: "Test",
                lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -8, to: Date()),
                twoFactorEnabled: false,
                recoveryCodesStored: false,
                reminderInterval: .threeMonths
            )
        ]

        for account in samples {
            AccountUpdateService.updateReminderDate(for: account, interval: account.reminderInterval)
            context.insert(account)
        }

        try? context.save()
        #endif
    }
}

enum AccountQueryService {
    static func filterAndSort(
        accounts: [GameAccount],
        filters: AccountListFilters
    ) -> [GameAccount] {
        var result = accounts

        if let platform = filters.selectedPlatform {
            result = result.filter { $0.platform == platform }
        }

        if let region = filters.selectedRegion, !region.isBlank {
            result = result.filter { $0.region.localizedCaseInsensitiveContains(region) }
        }

        if filters.primaryOnly {
            result = result.filter(\.isPrimaryAccount)
        }

        if filters.missingTwoFactorOnly {
            result = result.filter { !$0.twoFactorEnabled }
        }

        if !filters.searchText.isBlank {
            let query = filters.searchText.trimmed.lowercased()
            result = result.filter { account in
                account.displayName.lowercased().contains(query) ||
                account.username.lowercased().contains(query) ||
                account.emailAddress.lowercased().contains(query) ||
                account.platform.displayName.lowercased().contains(query) ||
                account.region.lowercased().contains(query) ||
                account.accountType.lowercased().contains(query)
            }
        }

        result.sort { lhs, rhs in
            let comparison: Bool
            switch filters.sortOption {
            case .lastLogin:
                let lhsDate = lhs.lastLoginDate ?? .distantPast
                let rhsDate = rhs.lastLoginDate ?? .distantPast
                comparison = lhsDate < rhsDate
            case .name:
                comparison = lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
            case .platform:
                let platformCompare = lhs.platform.displayName.localizedCaseInsensitiveCompare(rhs.platform.displayName)
                if platformCompare == .orderedSame {
                    comparison = lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
                } else {
                    comparison = platformCompare == .orderedAscending
                }
            }
            return filters.sortAscending ? comparison : !comparison
        }

        return result
    }

    static func groupedByPlatform(_ accounts: [GameAccount]) -> [(platform: GamePlatform, accounts: [GameAccount])] {
        let grouped = Dictionary(grouping: accounts, by: \.platform)
        return GamePlatform.allCases.compactMap { platform in
            guard let platformAccounts = grouped[platform], !platformAccounts.isEmpty else { return nil }
            let sorted = platformAccounts.sorted {
                $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
            }
            return (platform, sorted)
        }
    }

    static func uniqueRegions(from accounts: [GameAccount]) -> [String] {
        Array(Set(accounts.map(\.region).filter { !$0.isBlank })).sorted()
    }
}
