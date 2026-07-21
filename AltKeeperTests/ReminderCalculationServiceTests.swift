import XCTest
@testable import AltKeeper

final class ReminderCalculationServiceTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar.appCalendar
    }

    func testNextReminderDateThreeMonths() {
        let lastLogin = makeDate(year: 2026, month: 1, day: 15)
        let result = ReminderCalculationService.nextReminderDate(
            from: lastLogin,
            interval: .threeMonths
        )
        let expected = makeDate(year: 2026, month: 4, day: 15)
        XCTAssertEqual(result, expected)
    }

    func testNextReminderDateTwoAndHalfYears() {
        let lastLogin = makeDate(year: 2024, month: 1, day: 1)
        let result = ReminderCalculationService.nextReminderDate(
            from: lastLogin,
            interval: .twoAndHalfYears
        )
        let expected = makeDate(year: 2026, month: 7, day: 1)
        XCTAssertEqual(result, expected)
    }

    func testCustomReminderDate() {
        let lastLogin = makeDate(year: 2026, month: 1, day: 1)
        let custom = makeDate(year: 2027, month: 5, day: 20)
        let result = ReminderCalculationService.nextReminderDate(
            from: lastLogin,
            interval: .custom,
            customDate: custom
        )
        XCTAssertEqual(result, custom)
    }

    func testIsReminderSoonWithinWindow() {
        let reference = makeDate(year: 2026, month: 7, day: 1)
        let reminder = makeDate(year: 2026, month: 7, day: 20)
        XCTAssertTrue(
            ReminderCalculationService.isReminderSoon(
                reminderDate: reminder,
                withinDays: 30,
                referenceDate: reference
            )
        )
    }

    func testIsReminderOverdue() {
        let reference = makeDate(year: 2026, month: 7, day: 1)
        let reminder = makeDate(year: 2026, month: 6, day: 1)
        XCTAssertTrue(
            ReminderCalculationService.isReminderOverdue(
                reminderDate: reminder,
                referenceDate: reference
            )
        )
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
