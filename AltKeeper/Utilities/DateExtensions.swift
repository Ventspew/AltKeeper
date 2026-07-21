import Foundation

extension Calendar {
    static let appCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "nl_NL")
        return calendar
    }()
}

extension Date {
    var startOfDay: Date {
        Calendar.appCalendar.startOfDay(for: self)
    }

    func adding(months: Int) -> Date? {
        Calendar.appCalendar.date(byAdding: .month, value: months, to: self)
    }

    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter.string(from: self)
    }

    func relativeDescription(from reference: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: reference)
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }
}
