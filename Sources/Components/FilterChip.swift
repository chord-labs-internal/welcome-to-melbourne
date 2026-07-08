import SwiftUI

/// The resolved visual style for a ``FilterChip`` in a given selection state.
///
/// Extracted as a pure, `Equatable` value type so selection styling can be
/// unit-tested without a running UI. All colors come from ``Theme`` — never
/// ad-hoc values.
struct FilterChipStyle: Equatable {
    let fill: Color
    let foreground: Color
    let border: Color
    let borderWidth: CGFloat

    /// Selected chips read as an ink pill with on-color text; unselected chips
    /// are a white surface with a soft border and body text.
    static func resolve(isSelected: Bool) -> FilterChipStyle {
        if isSelected {
            FilterChipStyle(
                fill: Theme.Color.ink,
                foreground: Theme.Color.onColor,
                border: .clear,
                borderWidth: 0
            )
        } else {
            FilterChipStyle(
                fill: Theme.Color.surfaceWhite,
                foreground: Theme.Color.body,
                border: Theme.Color.borderSoft,
                borderWidth: 1
            )
        }
    }
}

/// A pill-shaped filter chip for the category-screen filter rows
/// (e.g. All / Espresso / Filter / Brunch).
///
/// Two states — selected (ink fill) and unselected (white surface + soft
/// border) — resolved through ``FilterChipStyle``.
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    /// Fixed pill height per the Figma filter row.
    private static let height: CGFloat = 39

    init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        let style = FilterChipStyle.resolve(isSelected: isSelected)
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundStyle(style.foreground)
                .padding(.horizontal, Theme.Spacing.cardPadding)
                .frame(height: Self.height)
                .background(style.fill, in: .capsule)
                .overlay {
                    Capsule().strokeBorder(style.border, lineWidth: style.borderWidth)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("chip.\(title)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
        HStack(spacing: Theme.Spacing.small) {
            FilterChip(title: "All", isSelected: true) {}
            FilterChip(title: "Espresso", isSelected: false) {}
            FilterChip(title: "Filter", isSelected: false) {}
        }
        HStack(spacing: Theme.Spacing.small) {
            FilterChip(title: "Brunch", isSelected: false) {}
            FilterChip(title: "Roasters", isSelected: true) {}
        }
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Color.cream)
}
