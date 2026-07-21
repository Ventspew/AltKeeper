import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var authService = AuthenticationService.shared
    @ObservedObject private var cloudKitSync = CloudKitSyncService.shared
    @Query private var accounts: [GameAccount]

    @State private var showExportWarning = false
    @State private var showImportPicker = false
    @State private var exportDocument: ExportFileDocument?
    @State private var showExportSheet = false
    @State private var importError: String?
    @State private var importSuccess = false
    @State private var showEnableCloudKitAlert = false
    @State private var showDisableCloudKitAlert = false
    @State private var showRestartReminder = false

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section("Beveiliging") {
                    Toggle("Appvergrendeling", isOn: $settings.appLockEnabled)
                    Toggle("Automatisch vergrendelen", isOn: $settings.autoLockEnabled)
                        .disabled(!settings.appLockEnabled)
                    Toggle("E-mailadressen verbergen", isOn: $settings.hideEmailAddresses)

                    if settings.appLockEnabled {
                        LabeledContent("Ontgrendelen via", value: authService.biometryLabel)
                    }
                }

                Section("Synchronisatie") {
                    Toggle("iCloud-synchronisatie", isOn: Binding(
                        get: { settings.iCloudSyncEnabled },
                        set: { newValue in
                            if newValue {
                                showEnableCloudKitAlert = true
                            } else {
                                showDisableCloudKitAlert = true
                            }
                        }
                    ))

                    if settings.iCloudSyncEnabled {
                        LabeledContent("Status") {
                            if cloudKitSync.isSyncing {
                                ProgressView()
                            } else {
                                Text(cloudKitSync.statusDescription)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        if let error = cloudKitSync.lastErrorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    Text("Wijzigingen aan iCloud-synchronisatie worden actief na het volledig afsluiten en opnieuw openen van de app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Meldingen") {
                    Toggle("Loginherinneringen", isOn: $settings.notificationsEnabled)
                        .onChange(of: settings.notificationsEnabled) { _, enabled in
                            Task {
                                if enabled {
                                    _ = try? await NotificationService.shared.requestAuthorization()
                                    await NotificationService.shared.rescheduleAllReminders(for: accounts)
                                }
                            }
                        }

                    Picker("Standaardinterval", selection: Binding(
                        get: { settings.defaultReminderInterval },
                        set: { settings.defaultReminderInterval = $0 }
                    )) {
                        ForEach(ReminderInterval.allCases.filter { $0 != .custom }) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }

                    NavigationLink {
                        UpcomingRemindersView()
                    } label: {
                        Label("Aankomende herinneringen", systemImage: "bell")
                    }
                }

                Section("Gegevens") {
                    Button {
                        showExportWarning = true
                    } label: {
                        Label("Exporteer accounts", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImportPicker = true
                    } label: {
                        Label("Importeer accounts", systemImage: "square.and.arrow.down")
                    }
                }

                Section {
                    VStack(spacing: 16) {
                        AppLogoView(size: 72, showShadow: false)

                        VStack(spacing: 4) {
                            Text("AltKeeper")
                                .font(.title2.bold())
                            Text("Versie 1.0.0")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)

                    Text("AltKeeper bewaart accountmetadata, geen wachtwoorden. Gebruik Apple Wachtwoorden of een externe wachtwoordmanager.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Over AltKeeper")
                }
            }
            .navigationTitle("Instellingen")
            .navigationBarTitleDisplayMode(.large)
            .appScreenBackground()
            .alert("Exportwaarschuwing", isPresented: $showExportWarning) {
                Button("Exporteer") {
                    prepareExport()
                }
                Button("Annuleer", role: .cancel) {}
            } message: {
                Text("Exportbestanden kunnen gevoelige accountmetadata bevatten, zoals e-mailadressen en gebruikersnamen. Bewaar het bestand veilig.")
            }
            .fileExporter(
                isPresented: $showExportSheet,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "AltKeeper-export"
            ) { result in
                if case .failure(let error) = result {
                    importError = error.localizedDescription
                }
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.json]
            ) { result in
                handleImport(result)
            }
            .alert("Import mislukt", isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError ?? "")
            }
            .alert("Import voltooid", isPresented: $importSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Accounts zijn geïmporteerd.")
            }
            .alert("iCloud-synchronisatie inschakelen?", isPresented: $showEnableCloudKitAlert) {
                Button("Inschakelen") {
                    settings.iCloudSyncEnabled = true
                    ModelContainerFactory.scheduleCloudKitMigration()
                    showRestartReminder = true
                }
                Button("Annuleer", role: .cancel) {}
            } message: {
                Text("iCloud-sync vereist een build met CloudKit-entitlement (betaald Developer-account). Op unsigned/sideload-builds blijft sync uitgeschakeld of beperkt. Lokale accounts worden anders bij de volgende start gekopieerd. AltKeeper slaat geen wachtwoorden op.")
            }
            .alert("iCloud-synchronisatie uitschakelen?", isPresented: $showDisableCloudKitAlert) {
                Button("Uitschakelen", role: .destructive) {
                    settings.iCloudSyncEnabled = false
                    showRestartReminder = true
                }
                Button("Annuleer", role: .cancel) {}
            } message: {
                Text("Accounts blijven in iCloud staan, maar dit apparaat gebruikt daarna weer alleen lokale opslag. Herstart de app om de wijziging door te voeren.")
            }
            .alert("Herstart vereist", isPresented: $showRestartReminder) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Sluit AltKeeper volledig af via de app-switcher en open de app opnieuw om synchronisatie toe te passen.")
            }
            .task {
                if settings.iCloudSyncEnabled {
                    await cloudKitSync.refreshAccountStatus()
                }
            }
        }
    }

    private func prepareExport() {
        do {
            let data = try ImportExportService.exportAccounts(accounts)
            exportDocument = ExportFileDocument(data: data)
            showExportSheet = true
        } catch {
            importError = error.localizedDescription
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Geen toegang tot het bestand."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                let imported = try ImportExportService.importAccounts(from: data)
                for account in imported {
                    modelContext.insert(account)
                }
                try modelContext.save()
                Task {
                    await NotificationService.shared.rescheduleAllReminders(for: accounts + imported)
                }
                importSuccess = true
            } catch {
                importError = error.localizedDescription
            }

        case .failure(let error):
            importError = error.localizedDescription
        }
    }
}

struct ExportFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

struct UpcomingRemindersView: View {
    @Query(sort: \GameAccount.nextLoginReminderDate) private var accounts: [GameAccount]

    private var upcoming: [GameAccount] {
        accounts
            .filter { $0.nextLoginReminderDate != nil }
            .sorted {
                ($0.nextLoginReminderDate ?? .distantFuture) < ($1.nextLoginReminderDate ?? .distantFuture)
            }
    }

    var body: some View {
        List {
            if upcoming.isEmpty {
                EmptyStateView(
                    title: "Geen herinneringen",
                    message: "Er zijn nog geen loginherinneringen gepland.",
                    systemImage: "bell.slash"
                )
            } else {
                ForEach(upcoming, id: \.id) { account in
                    NavigationLink {
                        AccountDetailView(account: account)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.displayName)
                                .font(.headline)
                            Text(account.platform.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if let date = account.nextLoginReminderDate {
                                Text(date.formatted())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Herinneringen")
    }
}
