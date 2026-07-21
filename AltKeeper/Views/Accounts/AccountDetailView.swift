import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = AppSettings.shared

    @Bindable var account: GameAccount

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showLoginFlow = false
    @State private var showReminderSheet = false
    @State private var copiedMessage: String?

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    AccountAvatarView(account: account, size: 80)

                    VStack(spacing: 6) {
                        Text(account.displayName)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        Text(account.platform.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        AccountStatusBadge(status: AccountStatusService.status(for: account))
                    }

                    HStack(spacing: 12) {
                        Button {
                            showLoginFlow = true
                        } label: {
                            Label("Inloggen", systemImage: "arrow.right.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)

                        Button {
                            Task { await markLoggedInToday() }
                        } label: {
                            Label("Vandaag", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Accountgegevens") {
                DetailInfoRow(icon: "person", title: "Gebruikersnaam", value: account.username)
                DetailInfoRow(
                    icon: "envelope",
                    title: "E-mailadres",
                    value: settings.hideEmailAddresses ? maskedEmail(account.emailAddress) : account.emailAddress
                )
                DetailInfoRow(icon: "globe", title: "Regio", value: account.region)
                DetailInfoRow(icon: "tag", title: "Accounttype", value: account.accountType)
                DetailInfoRow(
                    icon: "lock.shield",
                    title: "2FA",
                    value: account.twoFactorEnabled ? "Actief" : "Niet actief"
                )
                DetailInfoRow(
                    icon: "key",
                    title: "Herstelcodes",
                    value: account.recoveryCodesStored ? "Opgeslagen" : "Niet opgeslagen"
                )
            }

            Section("Loginactiviteit") {
                DetailInfoRow(
                    icon: "clock",
                    title: "Laatste login",
                    value: account.lastLoginDate?.formatted() ?? "Onbekend"
                )
                DetailInfoRow(
                    icon: "bell",
                    title: "Volgende herinnering",
                    value: account.nextLoginReminderDate?.formatted() ?? "Niet ingesteld"
                )
            }

            if !account.notes.isBlank {
                Section("Notities") {
                    Text(account.notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Meer acties") {
                if !account.emailAddress.isBlank {
                    actionButton("Kopieer e-mailadres", icon: "doc.on.doc") {
                        copy(account.emailAddress, label: "E-mailadres")
                    }
                }

                if !account.username.isBlank {
                    actionButton("Kopieer gebruikersnaam", icon: "doc.on.doc") {
                        copy(account.username, label: "Gebruikersnaam")
                    }
                }

                if account.effectiveAppURL != nil {
                    actionButton("Open platform-app", icon: "app.badge") {
                        if let url = account.effectiveAppURL {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                actionButton("Stel loginherinnering in", icon: "bell.badge") {
                    showReminderSheet = true
                }

                actionButton("Bewerk account", icon: "pencil") {
                    showEditSheet = true
                }

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Verwijder account", systemImage: "trash")
                }
            }

            Section {
                Text("De accountstatus is gebaseerd op door jou ingevoerde gegevens. AltKeeper slaat geen wachtwoorden op.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AccountFormView(mode: .edit(account))
        }
        .sheet(isPresented: $showLoginFlow) {
            LoginFlowSheet(account: account) {
                Task { await markLoggedInToday() }
            }
        }
        .sheet(isPresented: $showReminderSheet) {
            ReminderSettingsSheet(account: account)
        }
        .alert("Account verwijderen?", isPresented: $showDeleteConfirmation) {
            Button("Verwijderen", role: .destructive) {
                deleteAccount()
            }
            Button("Annuleer", role: .cancel) {}
        } message: {
            Text("Weet je zeker dat je \(account.displayName) wilt verwijderen?")
        }
        .alert("Gekopieerd", isPresented: Binding(
            get: { copiedMessage != nil },
            set: { if !$0 { copiedMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let copiedMessage {
                Text("\(copiedMessage) is gekopieerd naar het klembord.")
            }
        }
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
    }

    private func maskedEmail(_ email: String) -> String {
        guard let atIndex = email.firstIndex(of: "@") else { return "••••••" }
        let prefix = email[..<atIndex]
        let domain = email[atIndex...]
        let visible = prefix.prefix(min(2, prefix.count))
        return "\(visible)•••\(domain)"
    }

    private func copy(_ value: String, label: String) {
        UIPasteboard.general.string = value
        copiedMessage = label
        HapticFeedback.lightImpact()
    }

    private func markLoggedInToday() async {
        do {
            try await AccountUpdateService.markLoggedInToday(account: account)
            try? await NotificationService.shared.scheduleReminder(for: account)
            try? modelContext.save()
            HapticFeedback.success()
        } catch {
            HapticFeedback.error()
        }
    }

    private func deleteAccount() {
        NotificationService.shared.cancelReminder(for: account.id)
        modelContext.delete(account)
        try? modelContext.save()
        dismiss()
    }
}

private struct ReminderSettingsSheet: View {
    @Bindable var account: GameAccount
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var interval: ReminderInterval
    @State private var customDate: Date

    init(account: GameAccount) {
        self.account = account
        _interval = State(initialValue: account.reminderInterval)
        _customDate = State(initialValue: account.nextLoginReminderDate ?? Date().adding(months: 12) ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Herinneringsinterval", selection: $interval) {
                    ForEach(ReminderInterval.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }

                if interval == .custom {
                    DatePicker(
                        "Aangepaste datum",
                        selection: $customDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }

                Section {
                    Button("Melding 1 week uitstellen") {
                        Task {
                            try? await NotificationService.shared.snoozeReminder(for: account, days: 7)
                            try? modelContext.save()
                            dismiss()
                        }
                    }

                    Button("Markeer herinnering als voltooid") {
                        Task {
                            try? await NotificationService.shared.markReminderCompleted(for: account)
                            try? modelContext.save()
                            HapticFeedback.success()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Herinnering")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Opslaan") {
                        AccountUpdateService.updateReminderDate(
                            for: account,
                            interval: interval,
                            customDate: interval == .custom ? customDate : nil
                        )
                        Task {
                            try? await NotificationService.shared.scheduleReminder(for: account)
                            try? modelContext.save()
                        }
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
