import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        await refreshAuthorizationStatus()
        return granted
    }

    func scheduleReminder(for account: GameAccount) async throws {
        guard let reminderDate = account.nextLoginReminderDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Loginherinnering"
        content.body = notificationBody(for: account)
        content.sound = .default
        content.userInfo = ["accountID": account.id.uuidString]

        let components = Calendar.appCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: account.id),
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }

    func cancelReminder(for accountID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier(for: accountID)])
    }

    func rescheduleAllReminders(for accounts: [GameAccount]) async {
        center.removeAllPendingNotificationRequests()
        for account in accounts where account.nextLoginReminderDate != nil {
            try? await scheduleReminder(for: account)
        }
    }

    func snoozeReminder(for account: GameAccount, days: Int = 7) async throws {
        guard let current = account.nextLoginReminderDate else { return }
        guard let snoozed = Calendar.appCalendar.date(byAdding: .day, value: days, to: current) else {
            return
        }
        account.nextLoginReminderDate = snoozed
        account.updatedAt = Date()
        try await scheduleReminder(for: account)
    }

    func markReminderCompleted(for account: GameAccount) async throws {
        account.lastLoginDate = Date()
        account.nextLoginReminderDate = ReminderCalculationService.nextReminderDate(
            from: Date(),
            interval: account.reminderInterval
        )
        account.updatedAt = Date()
        try await scheduleReminder(for: account)
    }

    func pendingReminders() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    private func notificationIdentifier(for accountID: UUID) -> String {
        "altkeeper.reminder.\(accountID.uuidString)"
    }

    private func notificationBody(for account: GameAccount) -> String {
        let platformName = account.platform.displayName
        let accountName = account.displayName

        if let lastLogin = account.lastLoginDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = Locale(identifier: "nl_NL")
            formatter.unitsStyle = .full
            let relative = formatter.localizedString(for: lastLogin, relativeTo: Date())
            return "Je bent \(relative) niet ingelogd op je \(accountName) (\(platformName))-account. Controleer je account voordat het inactief raakt."
        }

        return "Het is tijd om je \(accountName) (\(platformName))-account te controleren."
    }
}
