import SwiftUI

struct DashboardCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.rowSpacing) {
            SectionHeader(title: title, systemImage: systemImage)
            content
        }
        .appCard()
        .accessibilityElement(children: .contain)
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                Text(value)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            AppLogoView(size: 80, showShadow: false)
                .opacity(0.9)

            ContentUnavailableView {
                Text(title)
                    .font(.title3.bold())
            } description: {
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            } actions: {
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 24)
                }
            }
        }
        .padding(24)
    }
}

struct AccountStatusBadge: View {
    let status: AccountStatus

    var body: some View {
        Label(status.rawValue, systemImage: status.iconName)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.14), in: Capsule())
            .foregroundStyle(backgroundColor)
            .accessibilityLabel(status.accessibilityDescription)
    }

    private var backgroundColor: Color {
        switch status {
        case .healthy: return .green
        case .checkSoon: return .orange
        case .longUnused: return .red
        case .missingTwoFactor: return .yellow
        case .missingRecovery: return .yellow
        case .loginRequired: return .red
        }
    }
}

struct PlatformIconView: View {
    let platform: GamePlatform
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(PlatformConfiguration.brandColor(for: platform).opacity(0.14))
            Image(systemName: PlatformConfiguration.symbolName(for: platform))
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(PlatformConfiguration.brandColor(for: platform))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct AccountAvatarView: View {
    let account: GameAccount
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let data = account.profileImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                PlatformIconView(platform: account.platform, size: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle().strokeBorder(Color(.separator).opacity(0.3), lineWidth: 0.5)
        }
        .accessibilityLabel("Profielfoto voor \(account.displayName)")
    }
}

struct AccountRowView: View {
    let account: GameAccount
    var hideEmail: Bool = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            AccountAvatarView(account: account, size: compact ? 40 : 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(account.displayName)
                        .font(compact ? .subheadline.weight(.semibold) : .headline)
                        .lineLimit(1)
                    if account.isPrimaryAccount {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                            .accessibilityLabel("Primair account")
                    }
                }

                if !account.username.isBlank {
                    Text(account.username)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if !hideEmail, !account.emailAddress.isBlank {
                    Text(account.emailAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                AccountStatusBadge(status: AccountStatusService.status(for: account))
                if let lastLogin = account.lastLoginDate {
                    Text(lastLogin.formatted(style: .short))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, compact ? 2 : 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [account.displayName, account.platform.displayName]
        parts.append(AccountStatusService.status(for: account).rawValue)
        if let lastLogin = account.lastLoginDate {
            parts.append("Laatste login \(lastLogin.formatted())")
        }
        return parts.joined(separator: ", ")
    }
}

struct DashboardAccountLink: View {
    let account: GameAccount

    var body: some View {
        NavigationLink {
            AccountDetailView(account: account)
        } label: {
            AccountRowView(account: account, compact: true)
        }
        .buttonStyle(.plain)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? AppTheme.accent.opacity(0.18) : Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? AppTheme.accent : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct DetailInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        if !value.isBlank {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 2)
        }
    }
}
