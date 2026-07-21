import SwiftUI

enum AppTheme {
    static let cornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let rowSpacing: CGFloat = 12

    static let accent = Color("AccentColor")
    static let brandNavy = Color(red: 0.10, green: 0.15, blue: 0.27)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let screenBackground = Color(.systemGroupedBackground)

    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.06
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(AppTheme.shadowOpacity), radius: AppTheme.shadowRadius, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.accent.opacity(configuration.isPressed ? 0.85 : 1), in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle(.primary)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension View {
    func appCard() -> some View {
        modifier(CardStyle())
    }

    func appScreenBackground() -> some View {
        background(AppTheme.screenBackground)
    }
}

struct AppLogoView: View {
    var size: CGFloat = 64
    var showShadow: Bool = true

    var body: some View {
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .shadow(color: showShadow ? .black.opacity(0.15) : .clear, radius: 8, y: 4)
            .accessibilityLabel("AltKeeper logo")
    }
}

struct AppBrandingHeader: View {
    var subtitle: String?

    var body: some View {
        HStack(spacing: 14) {
            AppLogoView(size: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text("AltKeeper")
                    .font(.title2.bold())
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.bottom, 4)
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
