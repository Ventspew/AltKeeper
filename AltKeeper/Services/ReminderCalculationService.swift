import Foundation

enum ReminderCalculationService {
    /// Calculates the next reminder date based on last login and interval.
    static func nextReminderDate(
        from lastLogin: Date,
        interval: ReminderInterval,
        customDate: Date? = nil
    ) -> Date? {
        if interval == .custom {
            return customDate
        }
        guard let months = interval.months else {
            return customDate
        }
        return lastLogin.adding(months: months)
    }

    /// Returns true when the reminder date is within the given number of days.
    static func isReminderSoon(
        reminderDate: Date?,
        withinDays days: Int = 30,
        referenceDate: Date = Date()
    ) -> Bool {
        guard let reminderDate else { return false }
        let start = referenceDate.startOfDay
        guard let threshold = Calendar.appCalendar.date(byAdding: .day, value: days, to: start) else {
            return false
        }
        return reminderDate <= threshold
    }

    /// Returns true when the reminder date has passed.
    static func isReminderOverdue(
        reminderDate: Date?,
        referenceDate: Date = Date()
    ) -> Bool {
        guard let reminderDate else { return false }
        return reminderDate.startOfDay < referenceDate.startOfDay
    }

    /// Days until reminder, negative if overdue.
    static func daysUntilReminder(
        reminderDate: Date?,
        referenceDate: Date = Date()
    ) -> Int? {
        guard let reminderDate else { return nil }
        let components = Calendar.appCalendar.dateComponents(
            [.day],
            from: referenceDate.startOfDay,
            to: reminderDate.startOfDay
        )
        return components.day
    }
}
