import XCTest
@testable import AltKeeper

final class CloudKitMigrationServiceTests: XCTestCase {
    func testAccountsToMigrateSkipsExistingCloudIDs() {
        let sharedID = UUID()
        let localOnlyID = UUID()

        let existingCloud = [
            GameAccount(id: sharedID, platform: .steam, displayName: "Cloud Steam")
        ]
        let local = [
            GameAccount(id: sharedID, platform: .steam, displayName: "Local Steam"),
            GameAccount(id: localOnlyID, platform: .xbox, displayName: "Local Xbox")
        ]

        let result = CloudKitMigrationService.accountsToMigrate(
            local: local,
            existingCloud: existingCloud
        )

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, localOnlyID)
        XCTAssertEqual(result.first?.displayName, "Local Xbox")
    }

    func testAccountsToMigrateReturnsEmptyWhenCloudAlreadyComplete() {
        let id = UUID()
        let account = GameAccount(id: id, platform: .playStation, displayName: "PS")
        let result = CloudKitMigrationService.accountsToMigrate(
            local: [account],
            existingCloud: [account]
        )
        XCTAssertTrue(result.isEmpty)
    }

    func testCopyPreservesAllFields() {
        let original = GameAccount(
            id: UUID(),
            platform: .nintendo,
            displayName: "JP Account",
            username: "player_jp",
            emailAddress: "jp@example.com",
            region: "Japan",
            accountType: "Regionaal",
            notes: "Notitie",
            lastLoginDate: Date(timeIntervalSince1970: 1_700_000_000),
            nextLoginReminderDate: Date(timeIntervalSince1970: 1_800_000_000),
            isPrimaryAccount: true,
            twoFactorEnabled: true,
            recoveryCodesStored: false,
            customLoginURL: "https://example.com",
            reminderInterval: .twoYears
        )

        let copy = GameAccount.copy(from: original)
        XCTAssertEqual(copy.id, original.id)
        XCTAssertEqual(copy.platform, original.platform)
        XCTAssertEqual(copy.displayName, original.displayName)
        XCTAssertEqual(copy.username, original.username)
        XCTAssertEqual(copy.emailAddress, original.emailAddress)
        XCTAssertEqual(copy.reminderInterval, original.reminderInterval)
    }
}
