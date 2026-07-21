import XCTest
@testable import AltKeeper

final class PlatformConfigurationTests: XCTestCase {
    func testAllPlatformsHaveDisplayNames() {
        for platform in GamePlatform.allCases {
            XCTAssertFalse(platform.displayName.isBlank)
        }
    }

    func testOfficialLoginURLsUseHTTPS() {
        let platformsWithLogin: [GamePlatform] = [
            .playStation, .xbox, .steam, .nintendo, .epicGames,
            .ea, .ubisoft, .riotGames, .rockstarGames, .battleNet,
            .gog, .discord, .twitch
        ]

        for platform in platformsWithLogin {
            let url = PlatformConfiguration.loginURL(for: platform)
            XCTAssertNotNil(url, "Login-URL ontbreekt voor \(platform.displayName)")
            XCTAssertEqual(url?.scheme, "https")
        }
    }

    func testOtherPlatformHasNoDefaultLoginURL() {
        XCTAssertNil(PlatformConfiguration.loginURL(for: .other))
    }

    func testSteamLoginURL() {
        XCTAssertEqual(
            PlatformConfiguration.loginURL(for: .steam)?.absoluteString,
            "https://store.steampowered.com/login/"
        )
    }

    func testPlayStationAppScheme() {
        XCTAssertEqual(
            PlatformConfiguration.appURL(for: .playStation)?.absoluteString,
            "playstation://"
        )
    }
}
