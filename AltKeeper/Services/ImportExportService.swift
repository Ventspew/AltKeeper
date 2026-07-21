import Foundation

struct ExportDocument: Codable, Sendable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let exportDate: Date
    let accounts: [ExportAccount]

    struct ExportAccount: Codable, Sendable {
        let id: UUID
        let platform: String
        let displayName: String
        let username: String
        let emailAddress: String
        let region: String
        let accountType: String
        let notes: String
        let lastLoginDate: Date?
        let nextLoginReminderDate: Date?
        let createdAt: Date
        let updatedAt: Date
        let isPrimaryAccount: Bool
        let twoFactorEnabled: Bool
        let recoveryCodesStored: Bool
        let customLoginURL: String?
        let reminderInterval: String
    }
}

enum ImportExportService {
    enum ImportExportError: LocalizedError {
        case unsupportedSchemaVersion(Int)
        case invalidData
        case duplicateAccountsFound

        var errorDescription: String? {
            switch self {
            case .unsupportedSchemaVersion(let version):
                return "Niet-ondersteunde schemaversie: \(version)."
            case .invalidData:
                return "Het importbestand kon niet worden gelezen."
            case .duplicateAccountsFound:
                return "Het importbestand bevat dubbele accounts."
            }
        }
    }

    static func exportAccounts(_ accounts: [GameAccount]) throws -> Data {
        let exportAccounts = accounts.map { account in
            ExportDocument.ExportAccount(
                id: account.id,
                platform: account.platformRawValue,
                displayName: account.displayName,
                username: account.username,
                emailAddress: account.emailAddress,
                region: account.region,
                accountType: account.accountType,
                notes: account.notes,
                lastLoginDate: account.lastLoginDate,
                nextLoginReminderDate: account.nextLoginReminderDate,
                createdAt: account.createdAt,
                updatedAt: account.updatedAt,
                isPrimaryAccount: account.isPrimaryAccount,
                twoFactorEnabled: account.twoFactorEnabled,
                recoveryCodesStored: account.recoveryCodesStored,
                customLoginURL: account.customLoginURL,
                reminderInterval: account.reminderIntervalRawValue
            )
        }

        let document = ExportDocument(
            schemaVersion: ExportDocument.currentSchemaVersion,
            exportDate: Date(),
            accounts: exportAccounts
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(document)
    }

    static func importAccounts(from data: Data) throws -> [GameAccount] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let document = try decoder.decode(ExportDocument.self, from: data)

        guard document.schemaVersion <= ExportDocument.currentSchemaVersion else {
            throw ImportExportError.unsupportedSchemaVersion(document.schemaVersion)
        }

        return document.accounts.map { exported in
            GameAccount(
                id: exported.id,
                platform: GamePlatform(rawValue: exported.platform) ?? .other,
                displayName: exported.displayName,
                username: exported.username,
                emailAddress: exported.emailAddress,
                region: exported.region,
                accountType: exported.accountType,
                notes: exported.notes,
                lastLoginDate: exported.lastLoginDate,
                nextLoginReminderDate: exported.nextLoginReminderDate,
                createdAt: exported.createdAt,
                updatedAt: exported.updatedAt,
                isPrimaryAccount: exported.isPrimaryAccount,
                twoFactorEnabled: exported.twoFactorEnabled,
                recoveryCodesStored: exported.recoveryCodesStored,
                profileImageData: nil,
                customLoginURL: exported.customLoginURL,
                reminderInterval: ReminderInterval(rawValue: exported.reminderInterval) ?? .oneYear
            )
        }
    }
}
