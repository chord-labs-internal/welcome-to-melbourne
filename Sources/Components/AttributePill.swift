import SwiftUI

// MARK: - AttributePillStyle

/// The resolved visual style for an ``AttributePill`` — the small rounded tags used
/// on list cards to surface discrete attributes (salary, employment type, location…).
///
/// Extracted as a pure, `Equatable` value type so pill styling can be unit-tested
/// without a running UI. Colors come from ``Theme`` (or an explicit accent) — never
/// ad-hoc values scattered through views.
struct AttributePillStyle: Equatable {
    let background: Color
    let foreground: Color
    /// Emphasized pills use a semibold weight (e.g. a highlighted salary); neutral
    /// pills use medium.
    let isEmphasized: Bool

    /// Neutral tag: a warm sand fill behind body-color text.
    static let neutral = AttributePillStyle(
        background: Color(hex: AttributePill.neutralBackgroundHex),
        foreground: Theme.Color.body,
        isEmphasized: false
    )

    /// Accent tag: the given color tinted at 12% behind full-strength colored,
    /// emphasized text (e.g. a green salary chip).
    static func accent(_ color: Color) -> AttributePillStyle {
        AttributePillStyle(
            background: color.opacity(0.12),
            foreground: color,
            isEmphasized: true
        )
    }
}

// MARK: - AttributePill

/// A small rounded attribute tag, e.g. `$130–160k` / `Full-time` / `Hybrid`.
///
/// Two looks — ``AttributePillStyle/neutral`` (warm sand) and
/// ``AttributePillStyle/accent(_:)`` (a tinted accent chip) — resolved through the
/// pure ``AttributePillStyle`` so styling can't drift unnoticed.
struct AttributePill: View {
    let text: String
    var style: AttributePillStyle

    /// Warm-sand neutral background from the Figma source of truth. Exposed so
    /// tests can catch drift. `nonisolated` so the pure ``AttributePillStyle`` can
    /// reference it off the main actor.
    nonisolated static let neutralBackgroundHex = "#f4e9d8"

    private static let fontSize: CGFloat = 11.5
    private static let cornerRadius: CGFloat = 10
    private static let horizontalPadding: CGFloat = 11
    private static let verticalPadding: CGFloat = 6

    init(_ text: String, style: AttributePillStyle = .neutral) {
        self.text = text
        self.style = style
    }

    var body: some View {
        Text(text)
            .font(.system(size: Self.fontSize, weight: style.isEmphasized ? .semibold : .medium))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
            .background(style.background, in: .rect(cornerRadius: Self.cornerRadius))
            .accessibilityIdentifier("pill.\(text)")
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.small) {
        AttributePill("$130–160k", style: .accent(Theme.Color.green))
        AttributePill("Full-time")
        AttributePill("Hybrid")
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Color.cream)
}
