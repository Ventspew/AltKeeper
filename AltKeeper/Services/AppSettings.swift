import Foundation
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    enum Keys {
        static let appLockEnabled = "appLockEnabled"
        static let autoLockEnabled = "autoLockEnabled"
        static let hideEmailAddresses = "hideEmailAddresses"
        static let iCloudSyncEnabled = "iCloudSyncEnabled"
        static let pendingCloudKitMigration = "pendingCloudKitMigration"
        static let notificationsEnabled = "notificationsEnabled"
        static let defaultReminderInterval = "defaultReminderInterval"
    }

    @AppStorage(Keys.appLockEnabled) var appLockEnabled = false
    @AppStorage(Keys.autoLockEnabled) var autoLockEnabled = true
    @AppStorage(Keys.hideEmailAddresses) var hideEmailAddresses = false
    @AppStorage(Keys.iCloudSyncEnabled) var iCloudSyncEnabled = false
    @AppStorage(Keys.notificationsEnabled) var notificationsEnabled = true
    @AppStorage(Keys.defaultReminderInterval) private var defaultReminderIntervalRaw = ReminderInterval.oneYear.rawValue

    var defaultReminderInterval: ReminderInterval {
        get { ReminderInterval(rawValue: defaultReminderIntervalRaw) ?? .oneYear }
        set { defaultReminderIntervalRaw = newValue.rawValue }
    }

    private init() {}
}
