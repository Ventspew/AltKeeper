import SwiftUI
import SwiftData

@main
struct AltKeeperApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var authService = AuthenticationService.shared
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var cloudKitSync = CloudKitSyncService.shared

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainerFactory.makeContainer()
            SampleDataService.seedSampleAccounts(into: modelContainer.mainContext)
        } catch {
            // Last-resort in-memory store so the app still launches if disk/CloudKit setup fails.
            let schema = Schema([GameAccount.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch {
                fatalError("Kon ModelContainer niet initialiseren: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .blur(radius: shouldShowLockScreen ? 12 : 0)
                    .disabled(shouldShowLockScreen)

                if shouldShowLockScreen {
                    LockScreenView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: shouldShowLockScreen)
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
            .task {
                if settings.appLockEnabled {
                    authService.lockIfNeeded(appLockEnabled: true)
                    _ = await authService.authenticate()
                }
                await NotificationService.shared.refreshAuthorizationStatus()
                if settings.notificationsEnabled {
                    _ = try? await NotificationService.shared.requestAuthorization()
                }
                if settings.iCloudSyncEnabled {
                    await cloudKitSync.refreshAccountStatus()
                }
            }
        }
        .modelContainer(modelContainer)
    }

    private var shouldShowLockScreen: Bool {
        settings.appLockEnabled && !authService.isUnlocked
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            if settings.appLockEnabled && settings.autoLockEnabled {
                authService.lockIfNeeded(appLockEnabled: true)
            }
        case .active:
            if settings.appLockEnabled && !authService.isUnlocked {
                Task {
                    await authService.authenticate()
                }
            }
            if settings.iCloudSyncEnabled {
                Task {
                    await cloudKitSync.refreshAccountStatus()
                }
            }
        @unknown default:
            break
        }
    }
}
