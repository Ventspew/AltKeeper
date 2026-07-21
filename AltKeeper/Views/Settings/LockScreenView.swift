import SwiftUI

struct LockScreenView: View {
    @ObservedObject private var authService = AuthenticationService.shared
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            AppLogoView(size: 88)

            VStack(spacing: 8) {
                Text("AltKeeper")
                    .font(.title.bold())
                Text("AltKeeper is vergrendeld")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Text("Ontgrendel met \(authService.biometryLabel) of je toegangscode om je accounts te bekijken.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button("Ontgrendelen") {
                Task {
                    await authService.authenticate()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 32)
            .padding(.top, 8)

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            if settings.appLockEnabled {
                Task {
                    await authService.authenticate()
                }
            }
        }
    }
}
