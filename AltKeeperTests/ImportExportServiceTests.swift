import XCTest
@testable import AltKeeper

final class ImportExportServiceTests: XCTestCase {
    func testExportAndImportRoundTrip() throws {
        let original = GameAccount(
            id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
            platform: .playStation,
            displayName: "Hoofdaccount Nederland",
            username: "nl_gamer",
            emailAddress: "nl@example.com",
            region: "Nederland",
            accountType: "Primair",
            notes: "Testnotitie",
            lastLoginDate: Date(timeIntervalSince1970: 1_700_000_000),
            nextLoginReminderDate: Date(timeIntervalSince1970: 1_800_000_000),
            createdAt: Date(timeIntervalSince1970: 1_600_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            isPrimaryAccount: true,
            twoFactorEnabled: true,
            recoveryCodesStored: true,
            customLoginURL: "https://example.com/login",
            reminderInterval: .oneYear
        )

        let data = try ImportExportService.exportAccounts([original])
        let imported = try ImportExportService.importAccounts(from: data)

        XCTAssertEqual(imported.count, 1)
        let account = try XCTUnwrap(imported.first)
        XCTAssertEqual(account.id, original.id)
        XCTAssertEqual(account.platform, .playStation)
        XCTAssertEqual(account.displayName, "Hoofdaccount Nederland")
        XCTAssertEqual(account.username, "nl_gamer")
        XCTAssertEqual(account.emailAddress, "nl@example.com")
        XCTAssertEqual(account.reminderInterval, .oneYear)
    }

    func testExportContainsSchemaVersion() throws {
        let account = GameAccount(platform: .steam, displayName: "Steam")
        let data = try ImportExportService.exportAccounts([account])
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertEqual(json?["schemaVersion"] as? Int, ExportDocument.currentSchemaVersion)
        XCTAssertNotNil(json?["exportDate"])
        XCTAssertNotNil(json?["accounts"])
    }
}
