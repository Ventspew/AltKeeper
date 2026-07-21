import Foundation

enum DuplicateDetectionService {
    /// Returns true if another account with the same platform, username and email exists.
    static func isDuplicate(
        platform: GamePlatform,
        username: String,
        emailAddress: String,
        excludingID: UUID? = nil,
        among accounts: [GameAccount]
    ) -> Bool {
        let normalizedUsername = username.trimmed.lowercased()
        let normalizedEmail = emailAddress.trimmed.lowercased()
        guard !normalizedUsername.isEmpty || !normalizedEmail.isEmpty else {
            return false
        }

        let candidateKey = duplicateKey(
            platform: platform,
            username: username,
            emailAddress: emailAddress
        )

        return accounts.contains { account in
            guard account.id != excludingID else { return false }
            return account.duplicateKey == candidateKey
        }
    }

    static func duplicateKey(
        platform: GamePlatform,
        username: String,
        emailAddress: String
    ) -> String {
        let normalizedUsername = username.trimmed.lowercased()
        let normalizedEmail = emailAddress.trimmed.lowercased()
        return "\(platform.rawValue)|\(normalizedUsername)|\(normalizedEmail)"
    }
}
