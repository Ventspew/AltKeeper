import CloudKit
import CoreData
import Foundation

@MainActor
final class CloudKitSyncService: ObservableObject {
    static let shared = CloudKitSyncService()

    @Published private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var lastErrorMessage: String?

    private let container = CKContainer(identifier: ModelContainerFactory.cloudKitContainerIdentifier)

    private init() {
        NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleSyncEvent(notification)
            }
        }
    }

    func refreshAccountStatus() async {
        do {
            accountStatus = try await container.accountStatus()
            if accountStatus != .available {
                lastErrorMessage = message(for: accountStatus)
            } else {
                lastErrorMessage = nil
            }
        } catch {
            accountStatus = .couldNotDetermine
            lastErrorMessage = error.localizedDescription
        }
    }

    var statusDescription: String {
        guard AppSettings.shared.iCloudSyncEnabled else {
            return "Uitgeschakeld"
        }

        if isSyncing {
            return "Synchroniseren…"
        }

        switch accountStatus {
        case .available:
            if let lastSyncDate {
                return "Gesynchroniseerd \(lastSyncDate.relativeDescription())"
            }
            return "iCloud actief"
        case .noAccount:
            return "Geen iCloud-account"
        case .restricted:
            return "iCloud beperkt"
        case .couldNotDetermine:
            return "Status onbekend"
        case .temporarilyUnavailable:
            return "Tijdelijk niet beschikbaar"
        @unknown default:
            return "Onbekende status"
        }
    }

    private func handleSyncEvent(_ notification: Notification) {
        guard AppSettings.shared.iCloudSyncEnabled else { return }

        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
            as? NSPersistentCloudKitContainer.Event else {
            return
        }

        if let endDate = event.endDate {
            isSyncing = false
            if let error = event.error {
                lastErrorMessage = error.localizedDescription
            } else {
                lastSyncDate = endDate
                lastErrorMessage = nil
            }
        } else {
            isSyncing = true
        }
    }

    private func message(for status: CKAccountStatus) -> String {
        switch status {
        case .noAccount:
            return "Log in met je Apple ID in Instellingen om iCloud-sync te gebruiken."
        case .restricted:
            return "iCloud is beperkt op dit apparaat."
        case .temporarilyUnavailable:
            return "iCloud is tijdelijk niet beschikbaar."
        default:
            return "iCloud-status kon niet worden bepaald."
        }
    }
}
