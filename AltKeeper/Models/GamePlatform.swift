import Foundation

enum GamePlatform: String, Codable, CaseIterable, Identifiable, Sendable {
    case playStation = "PlayStation"
    case xbox = "Xbox"
    case steam = "Steam"
    case nintendo = "Nintendo"
    case epicGames = "Epic Games"
    case ea = "EA"
    case ubisoft = "Ubisoft"
    case riotGames = "Riot Games"
    case rockstarGames = "Rockstar Games"
    case battleNet = "Battle.net"
    case gog = "GOG"
    case discord = "Discord"
    case twitch = "Twitch"
    case other = "Overig"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .playStation: return "playstation.logo"
        case .xbox: return "xbox.logo"
        case .steam: return "steam.logo"
        case .nintendo: return "nintendo.logo"
        case .epicGames: return "gamecontroller.fill"
        case .ea: return "e.circle.fill"
        case .ubisoft: return "u.circle.fill"
        case .riotGames: return "bolt.circle.fill"
        case .rockstarGames: return "star.circle.fill"
        case .battleNet: return "b.circle.fill"
        case .gog: return "g.circle.fill"
        case .discord: return "bubble.left.and.bubble.right.fill"
        case .twitch: return "tv.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
