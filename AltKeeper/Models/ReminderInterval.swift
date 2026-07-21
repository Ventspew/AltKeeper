import Foundation

enum ReminderInterval: String, Codable, CaseIterable, Identifiable, Sendable {
    case threeMonths = "3 maanden"
    case sixMonths = "6 maanden"
    case oneYear = "1 jaar"
    case twoYears = "2 jaar"
    case twoAndHalfYears = "2,5 jaar"
    case threeYears = "3 jaar"
    case custom = "Aangepaste datum"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Returns the number of months for preset intervals, nil for custom.
    var months: Int? {
        switch self {
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .oneYear: return 12
        case .twoYears: return 24
        case .twoAndHalfYears: return 30
        case .threeYears: return 36
        case .custom: return nil
        }
    }

    static var defaultInterval: ReminderInterval { .oneYear }
}
