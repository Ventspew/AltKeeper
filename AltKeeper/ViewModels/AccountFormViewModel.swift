import Foundation
import SwiftUI

@MainActor
final class AccountFormViewModel: ObservableObject {
    enum FormMode {
        case add
        case edit(GameAccount)
    }

    @Published var platform: GamePlatform = .playStation
    @Published var displayName = ""
    @Published var username = ""
    @Published var emailAddress = ""
    @Published var region = ""
    @Published var accountType = ""
    @Published var notes = ""
    @Published var lastLoginDate = Date()
    @Published var hasLastLoginDate = false
    @Published var reminderInterval: ReminderInterval = .oneYear
    @Published var customReminderDate = Date()
    @Published var isPrimaryAccount = false
    @Published var twoFactorEnabled = false
    @Published var recoveryCodesStored = false
    @Published var customLoginURL = ""
    @Published var profileImageData: Data?
    @Published var validationMessage: String?

    let mode: FormMode

    init(mode: FormMode) {
        self.mode = mode
        if case .edit(let account) = mode {
            load(from: account)
        } else {
            reminderInterval = AppSettings.shared.defaultReminderInterval
        }
    }

    var navigationTitle: String {
        switch mode {
        case .add: return "Account toevoegen"
        case .edit: return "Account bewerken"
        }
    }

    var isValid: Bool {
        validate() == nil
    }

    func validate(against accounts: [GameAccount] = []) -> String? {
        guard !displayName.trimmed.isEmpty else {
            return "Voer een accountnaam in."
        }

        let excludingID: UUID? = {
            if case .edit(let account) = mode { return account.id }
            return nil
        }()

        if DuplicateDetectionService.isDuplicate(
            platform: platform,
            username: username,
            emailAddress: emailAddress,
            excludingID: excludingID,
            among: accounts
        ) {
            return "Dit account bestaat al met hetzelfde platform, gebruikersnaam en e-mailadres."
        }

        if reminderInterval == .custom && customReminderDate <= Date() {
            return "Kies een herinneringsdatum in de toekomst."
        }

        if !customLoginURL.isBlank, URL(string: customLoginURL.trimmed) == nil {
            return "De aangepaste login-URL is ongeldig."
        }

        return nil
    }

    func apply(to account: GameAccount) {
        account.platform = platform
        account.displayName = displayName.trimmed
        account.username = username.trimmed
        account.emailAddress = emailAddress.trimmed
        account.region = region.trimmed
        account.accountType = accountType.trimmed
        account.notes = notes.trimmed
        account.lastLoginDate = hasLastLoginDate ? lastLoginDate : nil
        account.isPrimaryAccount = isPrimaryAccount
        account.twoFactorEnabled = twoFactorEnabled
        account.recoveryCodesStored = recoveryCodesStored
        account.profileImageData = profileImageData
        account.customLoginURL = customLoginURL.isBlank ? nil : customLoginURL.trimmed
        account.updatedAt = Date()

        AccountUpdateService.updateReminderDate(
            for: account,
            interval: reminderInterval,
            customDate: reminderInterval == .custom ? customReminderDate : nil,
            baseDate: hasLastLoginDate ? lastLoginDate : Date()
        )
    }

    func makeAccount() -> GameAccount {
        let account = GameAccount(
            platform: platform,
            displayName: displayName.trimmed,
            username: username.trimmed,
            emailAddress: emailAddress.trimmed,
            region: region.trimmed,
            accountType: accountType.trimmed,
            notes: notes.trimmed,
            lastLoginDate: hasLastLoginDate ? lastLoginDate : nil,
            isPrimaryAccount: isPrimaryAccount,
            twoFactorEnabled: twoFactorEnabled,
            recoveryCodesStored: recoveryCodesStored,
            profileImageData: profileImageData,
            customLoginURL: customLoginURL.isBlank ? nil : customLoginURL.trimmed,
            reminderInterval: reminderInterval
        )

        AccountUpdateService.updateReminderDate(
            for: account,
            interval: reminderInterval,
            customDate: reminderInterval == .custom ? customReminderDate : nil,
            baseDate: hasLastLoginDate ? lastLoginDate : Date()
        )

        return account
    }

    private func load(from account: GameAccount) {
        platform = account.platform
        displayName = account.displayName
        username = account.username
        emailAddress = account.emailAddress
        region = account.region
        accountType = account.accountType
        notes = account.notes
        if let lastLogin = account.lastLoginDate {
            hasLastLoginDate = true
            lastLoginDate = lastLogin
        }
        reminderInterval = account.reminderInterval
        customReminderDate = account.nextLoginReminderDate ?? Date().adding(months: 12) ?? Date()
        isPrimaryAccount = account.isPrimaryAccount
        twoFactorEnabled = account.twoFactorEnabled
        recoveryCodesStored = account.recoveryCodesStored
        customLoginURL = account.customLoginURL ?? ""
        profileImageData = account.profileImageData
    }
}
