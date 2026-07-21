import Foundation

enum AccountStatus: String, CaseIterable, Identifiable, Sendable {
    case healthy = "Gezond"
    case checkSoon = "Binnenkort controleren"
    case longUnused = "Lang niet gebruikt"
    case missingTwoFactor = "2FA ontbreekt"
    case missingRecovery = "Herstelgegevens ontbreken"
    case loginRequired = "Login vereist"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .checkSoon: return "clock.badge.exclamationmark.fill"
        case .longUnused: return "exclamationmark.triangle.fill"
        case .missingTwoFactor: return "lock.slash.fill"
        case .missingRecovery: return "key.slash.fill"
        case .loginRequired: return "arrow.right.circle.fill"
        }
    }

    var accessibilityDescription: String {
        "Accountstatus: \(rawValue)"
    }
}
