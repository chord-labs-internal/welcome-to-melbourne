import Testing
import SwiftUI
import UIKit
@testable import WelcomeToMelbourne

/// Verifies the design tokens resolve to the exact Figma values.
///
/// Colors are checked two ways so drift is genuinely caught:
///  1. Each `Theme.Color` token is resolved back to sRGB components via `UIColor`
///     and compared against the expected hex bytes.
///  2. The `Color(hex:)` parser is asserted directly against known components.
struct ThemeTests {

    /// Allow one 8-bit quantization step of slack (1/255 ≈ 0.0039) plus a hair.
    private let tolerance = 0.006

    /// Resolves a SwiftUI `Color` to sRGB (red, green, blue) components in 0...1.
    private func components(_ color: Color) -> (red: Double, green: Double, blue: Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }

    /// Asserts a color matches the RGB decoded from `hex`.
    private func expectColor(
        _ color: Color,
        matchesHex hex: String,
        _ label: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let actual = components(color)
        let expected = Color.rgbComponents(fromHex: hex)
        #expect(
            abs(actual.red - expected.red) < tolerance,
            "\(label): red \(actual.red) != \(expected.red)",
            sourceLocation: sourceLocation
        )
        #expect(
            abs(actual.green - expected.green) < tolerance,
            "\(label): green \(actual.green) != \(expected.green)",
            sourceLocation: sourceLocation
        )
        #expect(
            abs(actual.blue - expected.blue) < tolerance,
            "\(label): blue \(actual.blue) != \(expected.blue)",
            sourceLocation: sourceLocation
        )
    }

    // MARK: - Semantic color tokens (11)

    @Test func semanticTokensResolveToExactHex() {
        expectColor(Theme.Color.cream, matchesHex: "#fbf5ec", "bg/cream")
        expectColor(Theme.Color.ink, matchesHex: "#2a2320", "text/ink")
        expectColor(Theme.Color.body, matchesHex: "#5a5049", "text/body")
        expectColor(Theme.Color.muted, matchesHex: "#8a7f76", "text/muted")
        expectColor(Theme.Color.terracotta, matchesHex: "#c75d3c", "primary/terracotta")
        expectColor(Theme.Color.green, matchesHex: "#2e5d46", "accent/green")
        expectColor(Theme.Color.gold, matchesHex: "#f0c05a", "accent/gold")
        expectColor(Theme.Color.plum, matchesHex: "#6e3b5c", "accent/plum")
        expectColor(Theme.Color.surfaceWhite, matchesHex: "#ffffff", "surface/white")
        expectColor(Theme.Color.borderSoft, matchesHex: "#ebe0cf", "border/soft")
        expectColor(Theme.Color.onColor, matchesHex: "#ffffff", "text/on-color")
    }

    @Test func semanticSourceHexStringsAreExact() {
        #expect(Theme.Color.bgCreamHex == "#fbf5ec")
        #expect(Theme.Color.textInkHex == "#2a2320")
        #expect(Theme.Color.textBodyHex == "#5a5049")
        #expect(Theme.Color.textMutedHex == "#8a7f76")
        #expect(Theme.Color.primaryTerracottaHex == "#c75d3c")
        #expect(Theme.Color.accentGreenHex == "#2e5d46")
        #expect(Theme.Color.accentGoldHex == "#f0c05a")
        #expect(Theme.Color.accentPlumHex == "#6e3b5c")
        #expect(Theme.Color.surfaceWhiteHex == "#ffffff")
        #expect(Theme.Color.borderSoftHex == "#ebe0cf")
        #expect(Theme.Color.textOnColorHex == "#ffffff")
    }

    // MARK: - Guide card colors (4)

    @Test func guideColorsResolveToExactHex() {
        expectColor(Theme.GuideColor.coffee, matchesHex: "#B4573C", "guide/coffee")
        expectColor(Theme.GuideColor.jobs, matchesHex: "#2F4C3A", "guide/jobs")
        expectColor(Theme.GuideColor.meetups, matchesHex: "#E0B44A", "guide/meetups")
        expectColor(Theme.GuideColor.records, matchesHex: "#6E3D5B", "guide/records")
    }

    @Test func guideColorResolvesBySlug() {
        #expect(Theme.GuideColor.hex(forSlug: "coffee") == "#B4573C")
        #expect(Theme.GuideColor.hex(forSlug: "jobs") == "#2F4C3A")
        #expect(Theme.GuideColor.hex(forSlug: "meetups") == "#E0B44A")
        #expect(Theme.GuideColor.hex(forSlug: "records") == "#6E3D5B")
        // Case-insensitive.
        #expect(Theme.GuideColor.hex(forSlug: "COFFEE") == "#B4573C")
        // Unknown slug -> nil.
        #expect(Theme.GuideColor.hex(forSlug: "unknown") == nil)
        #expect(Theme.GuideColor.color(forSlug: "unknown") == nil)
        #expect(Theme.GuideColor.color(forSlug: "records") != nil)
    }

    // MARK: - Hex parser

    @Test func hexParserDecodesKnownValues() {
        let white = Color.rgbComponents(fromHex: "#ffffff")
        #expect(white == (1.0, 1.0, 1.0))

        let black = Color.rgbComponents(fromHex: "#000000")
        #expect(black == (0.0, 0.0, 0.0))

        // #c75d3c -> (199, 93, 60)
        let terracotta = Color.rgbComponents(fromHex: "c75d3c")
        #expect(abs(terracotta.red - 199.0 / 255.0) < 0.0001)
        #expect(abs(terracotta.green - 93.0 / 255.0) < 0.0001)
        #expect(abs(terracotta.blue - 60.0 / 255.0) < 0.0001)
    }

    @Test func hexParserToleratesHashAndWhitespaceAndCase() {
        let a = Color.rgbComponents(fromHex: "#FBF5EC")
        let b = Color.rgbComponents(fromHex: "  fbf5ec ")
        #expect(a == b)
    }

    @Test func hexParserFallsBackToBlackOnBadInput() {
        #expect(Color.rgbComponents(fromHex: "zzz") == (0, 0, 0))
        #expect(Color.rgbComponents(fromHex: "#12345") == (0, 0, 0))
    }

    // MARK: - Typography ramp

    @Test func typographyPointSizesAreExact() {
        #expect(Theme.Typography.heroTitleSize == 40)
        #expect(Theme.Typography.greetingSize == 26)
        #expect(Theme.Typography.sectionTitleSize == 22)
        #expect(Theme.Typography.cardTitleSize == 18)
        #expect(Theme.Typography.bodySize == 15)
        #expect(Theme.Typography.countLabelSize == 13)
        #expect(Theme.Typography.eyebrowSize == 12)
        #expect(Theme.Typography.tabLabelSize == 11)
    }

    // MARK: - Spacing & radius

    @Test func spacingConstantsAreExact() {
        #expect(Theme.Spacing.screen == 28)
        #expect(Theme.Spacing.cardPadding == 16)
        #expect(Theme.Spacing.cardPaddingLarge == 18)
        #expect(Theme.Spacing.section == 24)
        #expect(Theme.Spacing.medium == 12)
        #expect(Theme.Spacing.small == 8)
        #expect(Theme.Spacing.xSmall == 4)
    }

    @Test func radiusConstantsAreExact() {
        #expect(Theme.Radius.card == 20)
        #expect(Theme.Radius.cardLarge == 24)
        #expect(Theme.Radius.chip == 12)
        #expect(Theme.Radius.small == 14)
    }
}
