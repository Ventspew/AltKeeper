import Foundation
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    struct DashboardStats {
        let totalAccounts: Int
        let platformCount: Int
        let upcomingReminders: [GameAccount]
        let accountsWithoutTwoFactor: [GameAccount]
        let recentlyUpdated: [GameAccount]
    }

    func stats(from accounts: [GameAccount]) -> DashboardStats {
        let platforms = Set(accounts.map(\.platform))
        let referenceDate = Date()

        let upcoming = accounts
            .filter {
                ReminderCalculationService.isReminderSoon(
                    reminderDate: $0.nextLoginReminderDate,
                    withinDays: 60,
                    referenceDate: referenceDate
                ) || ReminderCalculationService.isReminderOverdue(
                    reminderDate: $0.nextLoginReminderDate,
                    referenceDate: referenceDate
                )
            }
            .sorted {
                ($0.nextLoginReminderDate ?? .distantFuture) < ($1.nextLoginReminderDate ?? .distantFuture)
            }

        let withoutTwoFactor = accounts
            .filter { !$0.twoFactorEnabled }
            .sorted { $0.displayName < $1.displayName }

        let recentlyUpdated = accounts
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
            .map { $0 }

        return DashboardStats(
            totalAccounts: accounts.count,
            platformCount: platforms.count,
            upcomingReminders: upcoming,
            accountsWithoutTwoFactor: withoutTwoFactor,
            recentlyUpdated: recentlyUpdated
        )
    }
}
