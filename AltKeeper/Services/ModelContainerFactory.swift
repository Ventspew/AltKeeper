import Foundation
import SwiftData

enum ModelContainerFactory {
    static let cloudKitContainerIdentifier = "iCloud.com.altkeeper.app"
    static let localConfigurationName = "AltKeeperLocal"
    static let cloudConfigurationName = "AltKeeperCloud"

    static var isCloudKitEnabled: Bool {
        UserDefaults.standard.bool(forKey: AppSettings.Keys.iCloudSyncEnabled)
    }

    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([GameAccount.self])

        if isCloudKitEnabled {
            if UserDefaults.standard.bool(forKey: AppSettings.Keys.pendingCloudKitMigration) {
                try CloudKitMigrationService.migrateLocalStoreToCloud()
                UserDefaults.standard.set(false, forKey: AppSettings.Keys.pendingCloudKitMigration)
            }
            return try makeCloudContainer(schema: schema)
        }

        return try makeLocalContainer(schema: schema)
    }

    static func makeLocalContainer(schema: Schema = Schema([GameAccount.self])) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            localConfigurationName,
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func makeCloudContainer(schema: Schema = Schema([GameAccount.self])) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            cloudConfigurationName,
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private(cloudKitContainerIdentifier)
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func scheduleCloudKitMigration() {
        UserDefaults.standard.set(true, forKey: AppSettings.Keys.pendingCloudKitMigration)
    }
}
