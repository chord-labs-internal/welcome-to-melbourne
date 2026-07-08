import SwiftUI

/// A rounded-square container holding a single SF Symbol, used for guide-card
/// icons (46×46) and header buttons (40×40). Renders a translucent white fill
/// so it reads over a colored card; the symbol uses on-color by default.
struct IconBadge: View {
    let systemName: String
    var size: CGFloat
    var cornerRadius: CGFloat
    var foreground: Color

    /// Standard guide-card icon size.
    nonisolated static let guideCardSize: CGFloat = 46
    /// Standard header-button size.
    nonisolated static let headerButtonSize: CGFloat = 40

    /// The symbol occupies this fraction of the container's side length.
    private static let symbolScale: CGFloat = 0.42

    init(
        systemName: String,
        size: CGFloat = IconBadge.guideCardSize,
        cornerRadius: CGFloat = Theme.Radius.small,
        foreground: Color = Theme.Color.onColor
    ) {
        self.systemName = systemName
        self.size = size
        self.cornerRadius = cornerRadius
        self.foreground = foreground
    }

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * Self.symbolScale, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(Theme.Color.onColor.opacity(0.18), in: .rect(cornerRadius: cornerRadius))
            .accessibilityIdentifier("iconBadge.\(systemName)")
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.medium) {
        IconBadge(systemName: "cup.and.saucer.fill")
        IconBadge(systemName: "briefcase.fill")
        IconBadge(systemName: "magnifyingglass", size: IconBadge.headerButtonSize)
    }
    .padding(Theme.Spacing.section)
    .background(Theme.Color.terracotta, in: .rect(cornerRadius: Theme.Radius.card))
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Color.cream)
}
