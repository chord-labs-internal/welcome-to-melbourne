import SwiftUI

/// A small, tracked, uppercase eyebrow label pill — e.g. "CAFÉ", "HIRING",
/// "VINYL" — rendered as on-color text over a tinted fill.
struct Badge: View {
    let text: String
    let tint: Color

    init(_ text: String, tint: Color) {
        self.text = text
        self.tint = tint
    }

    /// Normalizes badge text to the tracked-uppercase form shown in the UI:
    /// trims surrounding whitespace, then uppercases. Extracted as a pure,
    /// `nonisolated` function so the transform is unit-testable off the main actor.
    nonisolated static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var body: some View {
        Text(Self.normalized(text))
            .font(Theme.Typography.eyebrow)
            .tracking(0.8)
            .foregroundStyle(Theme.Color.onColor)
            .padding(.horizontal, Theme.Spacing.small)
            .padding(.vertical, Theme.Spacing.xSmall)
            .background(tint, in: .capsule)
            .accessibilityIdentifier("badge.\(Self.normalized(text))")
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.small) {
        Badge("Café", tint: Theme.Color.terracotta)
        Badge("Hiring", tint: Theme.Color.green)
        Badge("Vinyl", tint: Theme.Color.plum)
    }
    .padding(Theme.Spacing.screen)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Color.cream)
}
