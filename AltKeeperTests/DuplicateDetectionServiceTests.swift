import XCTest
@testable import AltKeeper

final class DuplicateDetectionServiceTests: XCTestCase {
    func testDetectsDuplicateAccount() {
        let existing = GameAccount(
            platform: .playStation,
            displayName: "Hoofd",
            username: "Gamer123",
            emailAddress: "test@example.com"
        )

        let isDuplicate = DuplicateDetectionService.isDuplicate(
            platform: .playStation,
            username: "gamer123",
            emailAddress: "TEST@example.com",
            among: [existing]
        )

        XCTAssertTrue(isDuplicate)
    }

    func testDoesNotDetectDuplicateForDifferentPlatform() {
        let existing = GameAccount(
            platform: .playStation,
            displayName: "Hoofd",
            username: "Gamer123",
            emailAddress: "test@example.com"
        )

        let isDuplicate = DuplicateDetectionService.isDuplicate(
            platform: .xbox,
            username: "Gamer123",
            emailAddress: "test@example.com",
            among: [existing]
        )

        XCTAssertFalse(isDuplicate)
    }

    func testExcludesCurrentAccountWhenEditing() {
        let existing = GameAccount(
            platform: .steam,
            displayName: "Steam",
            username: "player",
            emailAddress: "player@example.com"
        )

        let isDuplicate = DuplicateDetectionService.isDuplicate(
            platform: .steam,
            username: "player",
            emailAddress: "player@example.com",
            excludingID: existing.id,
            among: [existing]
        )

        XCTAssertFalse(isDuplicate)
    }

    func testEmptyUsernameAndEmailDoesNotDuplicate() {
        let existing = GameAccount(platform: .gog, displayName: "Leeg")

        let isDuplicate = DuplicateDetectionService.isDuplicate(
            platform: .gog,
            username: "",
            emailAddress: "",
            among: [existing]
        )

        XCTAssertFalse(isDuplicate)
    }
}
