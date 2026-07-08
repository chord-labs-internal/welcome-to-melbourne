import SwiftUI

/// The standard card chrome: a white surface with a soft border, card corner
/// radius, and a subtle shadow. Applied via the ``SwiftUI/View/cardSurface(cornerRadius:)``
/// modifier so any content can adopt the standard look.
struct CardSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.card

    func body(content: Content) -> some View {
        content
            .background(Theme.Color.surfaceWhite, in: .rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Theme.Color.borderSoft, lineWidth: 1)
            }
            // Shadow geometry is chrome, not a design token; the color is themed.
            .shadow(color: Theme.Color.ink.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

extension View {
    /// Wraps the view in the standard card chrome (surface fill, soft border,
    /// card radius, subtle shadow).
    func cardSurface(cornerRadius: CGFloat = Theme.Radius.card) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius))
    }
}

/// A reusable rounded-rectangle card container. Pads its content with the
/// standard card padding and applies ``cardSurface(cornerRadius:)`` chrome, so
/// any screen can drop content into standard card styling.
struct CardSurface<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder var content: () -> Content

    init(
        cornerRadius: CGFloat = Theme.Radius.card,
        padding: CGFloat = Theme.Spacing.cardPadding,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(cornerRadius: cornerRadius)
    }
}

#Preview {
    VStack(spacing: Theme.Spacing.section) {
        CardSurface {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text("Card surface")
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Color.ink)
                Text("Standard chrome via the container view.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Color.body)
            }
        }

        Text("Chrome via modifier")
            .font(Theme.Typography.body)
            .foregroundStyle(Theme.Color.body)
            .padding(Theme.Spacing.cardPadding)
            .cardSurface()
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Color.cream)
}
