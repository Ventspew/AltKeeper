import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
final class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published private(set) var isUnlocked = true
    @Published private(set) var isAvailable = false
    @Published private(set) var biometryType: LABiometryType = .none

    private init() {
        refreshAvailability()
    }

    func refreshAvailability() {
        let context = LAContext()
        var error: NSError?
        isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        biometryType = context.biometryType
    }

    var biometryLabel: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Toegangscode"
        }
    }

    func lockIfNeeded(appLockEnabled: Bool) {
        guard appLockEnabled else {
            isUnlocked = true
            return
        }
        isUnlocked = false
    }

    func authenticate(reason: String = "Ontgrendel AltKeeper") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Annuleer"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            isUnlocked = success
            return success
        } catch {
            isUnlocked = false
            return false
        }
    }
}
