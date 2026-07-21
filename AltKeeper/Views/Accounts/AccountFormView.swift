import PhotosUI
import SwiftUI
import SwiftData

struct AccountFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allAccounts: [GameAccount]
    @StateObject private var viewModel: AccountFormViewModel

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showValidationAlert = false

    init(mode: AccountFormViewModel.FormMode) {
        _viewModel = StateObject(wrappedValue: AccountFormViewModel(mode: mode))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Platform") {
                    Picker("Platform", selection: $viewModel.platform) {
                        ForEach(GamePlatform.allCases) { platform in
                            Label(platform.displayName, systemImage: PlatformConfiguration.symbolName(for: platform))
                                .tag(platform)
                        }
                    }
                }

                Section("Account") {
                    TextField("Accountnaam", text: $viewModel.displayName)
                        .textInputAutocapitalization(.words)
                    TextField("Gebruikersnaam", text: $viewModel.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("E-mailadres", text: $viewModel.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    TextField("Regio", text: $viewModel.region)
                    TextField("Accounttype", text: $viewModel.accountType)
                }

                Section("Login") {
                    Toggle("Laatste logindatum bekend", isOn: $viewModel.hasLastLoginDate)
                    if viewModel.hasLastLoginDate {
                        DatePicker(
                            "Laatste login",
                            selection: $viewModel.lastLoginDate,
                            displayedComponents: .date
                        )
                    }

                    Picker("Herinneringsinterval", selection: $viewModel.reminderInterval) {
                        ForEach(ReminderInterval.allCases) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }

                    if viewModel.reminderInterval == .custom {
                        DatePicker(
                            "Aangepaste herinneringsdatum",
                            selection: $viewModel.customReminderDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Beveiliging") {
                    Toggle("2FA actief", isOn: $viewModel.twoFactorEnabled)
                    Toggle("Herstelcodes opgeslagen", isOn: $viewModel.recoveryCodesStored)
                    Toggle("Primair account", isOn: $viewModel.isPrimaryAccount)
                }

                Section("Profielfoto") {
                    HStack {
                        if let data = viewModel.profileImageData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                        } else {
                            PlatformIconView(platform: viewModel.platform, size: 56)
                        }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Kies foto")
                        }

                        if viewModel.profileImageData != nil {
                            Button("Verwijder", role: .destructive) {
                                viewModel.profileImageData = nil
                            }
                        }
                    }
                }

                Section("Overig") {
                    TextField("Aangepaste login-URL", text: $viewModel.customLoginURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    TextField("Notities", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Opslaan") {
                        save()
                    }
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.profileImageData = data
                    }
                }
            }
            .alert("Controleer invoer", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationMessage ?? "Onbekende fout")
            }
        }
    }

    private func save() {
        if let message = viewModel.validate(against: allAccounts) {
            viewModel.validationMessage = message
            showValidationAlert = true
            HapticFeedback.warning()
            return
        }

        switch viewModel.mode {
        case .add:
            let account = viewModel.makeAccount()
            modelContext.insert(account)
            Task {
                if AppSettings.shared.notificationsEnabled {
                    try? await NotificationService.shared.scheduleReminder(for: account)
                }
            }
        case .edit(let account):
            viewModel.apply(to: account)
            Task {
                if AppSettings.shared.notificationsEnabled {
                    NotificationService.shared.cancelReminder(for: account.id)
                    try? await NotificationService.shared.scheduleReminder(for: account)
                }
            }
        }

        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            viewModel.validationMessage = "Opslaan mislukt: \(error.localizedDescription)"
            showValidationAlert = true
            HapticFeedback.error()
        }
    }
}
