import Foundation
import SwiftData

@Model
final class GameAccount {
    @Attribute(.unique) var id: UUID
    var platformRawValue: String
    var displayName: String
    var username: String
    var emailAddress: String
    var region: String
    var accountType: String
    var notes: String
    var lastLoginDate: Date?
    var nextLoginReminderDate: Date?
    var createdAt: Date
    var updatedAt: Date
    var isPrimaryAccount: Bool
    var twoFactorEnabled: Bool
    var recoveryCodesStored: Bool
    @Attribute(.externalStorage) var profileImageData: Data?
    var customLoginURL: String?
    var reminderIntervalRawValue: String

    var platform: GamePlatform {
        get { GamePlatform(rawValue: platformRawValue) ?? .other }
        set { platformRawValue = newValue.rawValue }
    }

    var reminderInterval: ReminderInterval {
        get { ReminderInterval(rawValue: reminderIntervalRawValue) ?? .oneYear }
        set { reminderIntervalRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        platform: GamePlatform,
        displayName: String,
        username: String = "",
        emailAddress: String = "",
        region: String = "",
        accountType: String = "",
        notes: String = "",
        lastLoginDate: Date? = nil,
        nextLoginReminderDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPrimaryAccount: Bool = false,
        twoFactorEnabled: Bool = false,
        recoveryCodesStored: Bool = false,
        profileImageData: Data? = nil,
        customLoginURL: String? = nil,
        reminderInterval: ReminderInterval = .oneYear
    ) {
        self.id = id
        self.platformRawValue = platform.rawValue
        self.displayName = displayName
        self.username = username
        self.emailAddress = emailAddress
        self.region = region
        self.accountType = accountType
        self.notes = notes
        self.lastLoginDate = lastLoginDate
        self.nextLoginReminderDate = nextLoginReminderDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPrimaryAccount = isPrimaryAccount
        self.twoFactorEnabled = twoFactorEnabled
        self.recoveryCodesStored = recoveryCodesStored
        self.profileImageData = profileImageData
        self.customLoginURL = customLoginURL
        self.reminderIntervalRawValue = reminderInterval.rawValue
    }

    var duplicateKey: String {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(platformRawValue)|\(normalizedUsername)|\(normalizedEmail)"
    }

    var effectiveLoginURL: URL? {
        if let custom = customLoginURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           !custom.isEmpty,
           let url = URL(string: custom) {
            return url
        }
        return PlatformConfiguration.loginURL(for: platform)
    }

    var effectiveAppURL: URL? {
        PlatformConfiguration.appURL(for: platform)
    }

    /// Creates a detached copy for CloudKit migration or import.
    static func copy(from source: GameAccount) -> GameAccount {
        GameAccount(
            id: source.id,
            platform: source.platform,
            displayName: source.displayName,
            username: source.username,
            emailAddress: source.emailAddress,
            region: source.region,
            accountType: source.accountType,
            notes: source.notes,
            lastLoginDate: source.lastLoginDate,
            nextLoginReminderDate: source.nextLoginReminderDate,
            createdAt: source.createdAt,
            updatedAt: source.updatedAt,
            isPrimaryAccount: source.isPrimaryAccount,
            twoFactorEnabled: source.twoFactorEnabled,
            recoveryCodesStored: source.recoveryCodesStored,
            profileImageData: source.profileImageData,
            customLoginURL: source.customLoginURL,
            reminderInterval: source.reminderInterval
        )
    }
}
