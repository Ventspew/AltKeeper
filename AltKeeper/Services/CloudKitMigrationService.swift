import Foundation
import SwiftData

enum CloudKitMigrationService {
    enum MigrationError: LocalizedError {
        case saveFailed(String)

        var errorDescription: String? {
            switch self {
            case .saveFailed(let message):
                return "CloudKit-migratie mislukt: \(message)"
            }
        }
    }

    /// Copies local accounts into the CloudKit-backed store, skipping IDs already present.
    @MainActor
    static func migrateLocalStoreToCloud() throws {
        let localContainer = try ModelContainerFactory.makeLocalContainer()
        let cloudContainer = try ModelContainerFactory.makeCloudContainer()

        let localAccounts = try localContainer.mainContext.fetch(FetchDescriptor<GameAccount>())
        let cloudAccounts = try cloudContainer.mainContext.fetch(FetchDescriptor<GameAccount>())

        let accountsToInsert = accountsToMigrate(local: localAccounts, existingCloud: cloudAccounts)
        guard !accountsToInsert.isEmpty else { return }

        for account in accountsToInsert {
            cloudContainer.mainContext.insert(account)
        }

        do {
            try cloudContainer.mainContext.save()
        } catch {
            throw MigrationError.saveFailed(error.localizedDescription)
        }
    }

    static func accountsToMigrate(
        local: [GameAccount],
        existingCloud: [GameAccount]
    ) -> [GameAccount] {
        let existingIDs = Set(existingCloud.map(\.id))
        return local
            .filter { !existingIDs.contains($0.id) }
            .map { GameAccount.copy(from: $0) }
    }
}
