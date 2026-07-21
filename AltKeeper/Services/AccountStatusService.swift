import Foundation

enum AccountStatusService {
    /// Determines account health status based on user-provided metadata only.
    static func status(
        for account: GameAccount,
        referenceDate: Date = Date()
    ) -> AccountStatus {
        if ReminderCalculationService.isReminderOverdue(
            reminderDate: account.nextLoginReminderDate,
            referenceDate: referenceDate
        ) {
            return .loginRequired
        }

        if ReminderCalculationService.isReminderSoon(
            reminderDate: account.nextLoginReminderDate,
            withinDays: 30,
            referenceDate: referenceDate
        ) {
            return .checkSoon
        }

        if let lastLogin = account.lastLoginDate {
            if let twoYearsAgo = referenceDate.adding(months: -24),
               lastLogin < twoYearsAgo {
                return .longUnused
            }
        } else {
            return .longUnused
        }

        if !account.twoFactorEnabled {
            return .missingTwoFactor
        }

        if !account.recoveryCodesStored {
            return .missingRecovery
        }

        return .healthy
    }

    static func statusColorName(for status: AccountStatus) -> String {
        switch status {
        case .healthy: return "green"
        case .checkSoon: return "orange"
        case .longUnused: return "red"
        case .missingTwoFactor: return "yellow"
        case .missingRecovery: return "yellow"
        case .loginRequired: return "red"
        }
    }
}
