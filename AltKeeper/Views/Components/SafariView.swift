import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor.tintColor
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct LoginFlowSheet: View {
    let account: GameAccount
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var showSafari = false
    @State private var showLoginSuccessPrompt = false
    @State private var copiedField: String?

    var onLoginConfirmed: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        AccountAvatarView(account: account, size: 52)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.displayName)
                                .font(.title3.bold())
                            Text(account.platform.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Gegevens kopiëren") {
                    if !account.emailAddress.isBlank {
                        Button {
                            copy(account.emailAddress, label: "E-mailadres")
                        } label: {
                            Label("Kopieer e-mailadres", systemImage: "envelope")
                        }
                    }

                    if !account.username.isBlank {
                        Button {
                            copy(account.username, label: "Gebruikersnaam")
                        } label: {
                            Label("Kopieer gebruikersnaam", systemImage: "person")
                        }
                    }
                }

                Section("Inloggen") {
                    if account.effectiveLoginURL != nil {
                        Button {
                            showSafari = true
                        } label: {
                            Label("Open officiële loginpagina", systemImage: "safari")
                        }
                    }

                    if let appURL = account.effectiveAppURL {
                        Button {
                            openURL(appURL)
                        } label: {
                            Label("Open platform-app", systemImage: "app.badge")
                        }
                    }

                    Button {
                        openPasswordsSettings()
                    } label: {
                        Label("Open Apple Wachtwoorden", systemImage: "key.fill")
                    }
                }

                Section {
                    Text("AltKeeper slaat geen wachtwoorden op. Gebruik Apple Wachtwoorden, iCloud Keychain of een externe wachtwoordmanager.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Inloggen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") { dismiss() }
                }
            }
            .sheet(isPresented: $showSafari, onDismiss: {
                showLoginSuccessPrompt = true
            }) {
                if let url = account.effectiveLoginURL {
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
            .alert("Is het inloggen gelukt?", isPresented: $showLoginSuccessPrompt) {
                Button("Ja, markeer als ingelogd") {
                    onLoginConfirmed()
                    dismiss()
                }
                Button("Nee", role: .cancel) {}
            } message: {
                Text("Bevestig alleen als je succesvol bent ingelogd op \(account.displayName).")
            }
            .alert("Gekopieerd", isPresented: Binding(
                get: { copiedField != nil },
                set: { if !$0 { copiedField = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let copiedField {
                    Text("\(copiedField) is gekopieerd naar het klembord.")
                }
            }
        }
    }

    private func copy(_ value: String, label: String) {
        UIPasteboard.general.string = value
        copiedField = label
        HapticFeedback.lightImpact()
    }

    private func openPasswordsSettings() {
        if let url = URL(string: "App-prefs:root=PASSWORDS") {
            openURL(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}
