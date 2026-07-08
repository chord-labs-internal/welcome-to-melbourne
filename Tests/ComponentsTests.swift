import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for the shared UI primitives (issue #4). These exercise the pure,
/// UI-free logic each component exposes — style resolution, text normalization,
/// and default sizing — so styling can't drift from ``Theme`` unnoticed.
///
/// Marked `@MainActor` because a few checks read defaults off `@MainActor`
/// SwiftUI `View` values; no running UI is required.
@MainActor
struct ComponentsTests {

    // MARK: - FilterChip style resolution

    @Test func selectedChipUsesInkFillAndOnColorText() {
        let style = FilterChipStyle.resolve(isSelected: true)
        #expect(style.fill == Theme.Color.ink)
        #expect(style.foreground == Theme.Color.onColor)
        #expect(style.borderWidth == 0)
    }

    @Test func unselectedChipUsesSurfaceFillBodyTextAndSoftBorder() {
        let style = FilterChipStyle.resolve(isSelected: false)
        #expect(style.fill == Theme.Color.surfaceWhite)
        #expect(style.foreground == Theme.Color.body)
        #expect(style.border == Theme.Color.borderSoft)
        #expect(style.borderWidth == 1)
    }

    @Test func selectedAndUnselectedStylesDiffer() {
        #expect(FilterChipStyle.resolve(isSelected: true) != FilterChipStyle.resolve(isSelected: false))
    }

    // MARK: - Badge text normalization

    @Test func badgeNormalizesToUppercase() {
        #expect(Badge.normalized("café") == "CAFÉ")
        #expect(Badge.normalized("Hiring") == "HIRING")
        #expect(Badge.normalized("vinyl") == "VINYL")
    }

    @Test func badgeTrimsSurroundingWhitespace() {
        #expect(Badge.normalized("  vinyl  ") == "VINYL")
        #expect(Badge.normalized("\nnew\n") == "NEW")
    }

    @Test func badgeNormalizationIsIdempotent() {
        let once = Badge.normalized("  café ")
        #expect(Badge.normalized(once) == once)
    }

    // MARK: - IconBadge sizing

    @Test func iconBadgeExposesStandardSizes() {
        #expect(IconBadge.guideCardSize == 46)
        #expect(IconBadge.headerButtonSize == 40)
    }

    @Test func iconBadgeDefaultsToGuideSizeAndSmallRadius() {
        let badge = IconBadge(systemName: "cup.and.saucer.fill")
        #expect(badge.size == IconBadge.guideCardSize)
        #expect(badge.cornerRadius == Theme.Radius.small)
        #expect(badge.foreground == Theme.Color.onColor)
    }

    @Test func iconBadgeHonorsExplicitSize() {
        let badge = IconBadge(systemName: "magnifyingglass", size: IconBadge.headerButtonSize)
        #expect(badge.size == 40)
    }

    // MARK: - CardSurface defaults

    @Test func cardSurfaceModifierDefaultsToCardRadius() {
        #expect(CardSurfaceModifier().cornerRadius == Theme.Radius.card)
    }

    @Test func cardSurfaceContainerDefaultsToCardRadiusAndPadding() {
        let surface = CardSurface { EmptyView() }
        #expect(surface.cornerRadius == Theme.Radius.card)
        #expect(surface.padding == Theme.Spacing.cardPadding)
    }
}
