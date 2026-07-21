import SwiftUI

struct PlatformConfiguration {
    struct PlatformInfo {
        let platform: GamePlatform
        let loginURL: URL?
        let appURLScheme: String?
        let brandColor: Color
        let fallbackSymbol: String
    }

    static let allPlatforms: [PlatformInfo] = [
        PlatformInfo(
            platform: .playStation,
            loginURL: URL(string: "https://www.playstation.com/nl-nl/playstation-network/"),
            appURLScheme: "playstation://",
            brandColor: Color(red: 0.0, green: 0.27, blue: 0.67),
            fallbackSymbol: "playstation.logo"
        ),
        PlatformInfo(
            platform: .xbox,
            loginURL: URL(string: "https://www.xbox.com/nl-NL/live"),
            appURLScheme: "xbox://",
            brandColor: Color(red: 0.09, green: 0.55, blue: 0.09),
            fallbackSymbol: "xbox.logo"
        ),
        PlatformInfo(
            platform: .steam,
            loginURL: URL(string: "https://store.steampowered.com/login/"),
            appURLScheme: "steam://",
            brandColor: Color(red: 0.11, green: 0.18, blue: 0.29),
            fallbackSymbol: "steam.logo"
        ),
        PlatformInfo(
            platform: .nintendo,
            loginURL: URL(string: "https://accounts.nintendo.com/login"),
            appURLScheme: nil,
            brandColor: Color(red: 0.88, green: 0.0, blue: 0.13),
            fallbackSymbol: "nintendo.logo"
        ),
        PlatformInfo(
            platform: .epicGames,
            loginURL: URL(string: "https://www.epicgames.com/id/login"),
            appURLScheme: "epicgames://",
            brandColor: Color(red: 0.2, green: 0.2, blue: 0.2),
            fallbackSymbol: "gamecontroller.fill"
        ),
        PlatformInfo(
            platform: .ea,
            loginURL: URL(string: "https://www.ea.com/login"),
            appURLScheme: "origin://",
            brandColor: Color(red: 0.0, green: 0.45, blue: 0.85),
            fallbackSymbol: "e.circle.fill"
        ),
        PlatformInfo(
            platform: .ubisoft,
            loginURL: URL(string: "https://connect.ubisoft.com/login"),
            appURLScheme: "ubisoftconnect://",
            brandColor: Color(red: 0.0, green: 0.47, blue: 0.75),
            fallbackSymbol: "u.circle.fill"
        ),
        PlatformInfo(
            platform: .riotGames,
            loginURL: URL(string: "https://auth.riotgames.com/login"),
            appURLScheme: "riotclient://",
            brandColor: Color(red: 0.85, green: 0.0, blue: 0.0),
            fallbackSymbol: "bolt.circle.fill"
        ),
        PlatformInfo(
            platform: .rockstarGames,
            loginURL: URL(string: "https://socialclub.rockstargames.com/signin"),
            appURLScheme: "rockstar://",
            brandColor: Color(red: 0.95, green: 0.72, blue: 0.0),
            fallbackSymbol: "star.circle.fill"
        ),
        PlatformInfo(
            platform: .battleNet,
            loginURL: URL(string: "https://account.battle.net/login"),
            appURLScheme: "battlenet://",
            brandColor: Color(red: 0.0, green: 0.55, blue: 0.85),
            fallbackSymbol: "b.circle.fill"
        ),
        PlatformInfo(
            platform: .gog,
            loginURL: URL(string: "https://login.gog.com/auth"),
            appURLScheme: "gog://",
            brandColor: Color(red: 0.45, green: 0.15, blue: 0.75),
            fallbackSymbol: "g.circle.fill"
        ),
        PlatformInfo(
            platform: .discord,
            loginURL: URL(string: "https://discord.com/login"),
            appURLScheme: "discord://",
            brandColor: Color(red: 0.34, green: 0.40, blue: 0.95),
            fallbackSymbol: "bubble.left.and.bubble.right.fill"
        ),
        PlatformInfo(
            platform: .twitch,
            loginURL: URL(string: "https://www.twitch.tv/login"),
            appURLScheme: "twitch://",
            brandColor: Color(red: 0.57, green: 0.27, blue: 0.95),
            fallbackSymbol: "tv.fill"
        ),
        PlatformInfo(
            platform: .other,
            loginURL: nil,
            appURLScheme: nil,
            brandColor: .secondary,
            fallbackSymbol: "ellipsis.circle.fill"
        )
    ]

    static func info(for platform: GamePlatform) -> PlatformInfo {
        allPlatforms.first { $0.platform == platform } ?? allPlatforms.last!
    }

    static func loginURL(for platform: GamePlatform) -> URL? {
        info(for: platform).loginURL
    }

    static func appURL(for platform: GamePlatform) -> URL? {
        guard let scheme = info(for: platform).appURLScheme else { return nil }
        return URL(string: scheme)
    }

    static func brandColor(for platform: GamePlatform) -> Color {
        info(for: platform).brandColor
    }

    static func symbolName(for platform: GamePlatform) -> String {
        info(for: platform).fallbackSymbol
    }
}
