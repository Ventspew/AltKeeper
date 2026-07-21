import XCTest
@testable import AltKeeper

final class AccountStatusServiceTests: XCTestCase {
    private let referenceDate = Calendar.appCalendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!

    func testHealthyStatus() {
        let account = GameAccount(
            platform: .steam,
            displayName: "Hoofdaccount",
            lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -1, to: referenceDate),
            nextLoginReminderDate: Calendar.appCalendar.date(byAdding: .month, value: 6, to: referenceDate),
            twoFactorEnabled: true,
            recoveryCodesStored: true
        )

        XCTAssertEqual(
            AccountStatusService.status(for: account, referenceDate: referenceDate),
            .healthy
        )
    }

    func testLoginRequiredWhenOverdue() {
        let account = GameAccount(
            platform: .playStation,
            displayName: "Japan",
            lastLoginDate: Calendar.appCalendar.date(byAdding: .year, value: -3, to: referenceDate),
            nextLoginReminderDate: Calendar.appCalendar.date(byAdding: .day, value: -1, to: referenceDate)
        )

        XCTAssertEqual(
            AccountStatusService.status(for: account, referenceDate: referenceDate),
            .loginRequired
        )
    }

    func testMissingTwoFactorStatus() {
        let account = GameAccount(
            platform: .xbox,
            displayName: "Test",
            lastLoginDate: Calendar.appCalendar.date(byAdding: .month, value: -1, to: referenceDate),
            nextLoginReminderDate: Calendar.appCalendar.date(byAdding: .year, value: 1, to: referenceDate),
            twoFactorEnabled: false,
            recoveryCodesStored: true
        )

        XCTAssertEqual(
            AccountStatusService.status(for: account, referenceDate: referenceDate),
            .missingTwoFactor
        )
    }

    func testLongUnusedWithoutLastLogin() {
        let account = GameAccount(
            platform: .nintendo,
            displayName: "Onbekend",
            lastLoginDate: nil
        )

        XCTAssertEqual(
            AccountStatusService.status(for: account, referenceDate: referenceDate),
            .longUnused
        )
    }
}
