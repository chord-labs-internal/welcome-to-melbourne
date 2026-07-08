import SwiftUI

/// Design tokens for Welcome to Melbourne, mirrored from the Figma source of truth.
///
/// Everything is a pure value type / static namespace: no singletons, no global
/// state, and nothing that needs a running UI. This keeps every token unit-testable.
public enum Theme {

    // MARK: - Colors

    /// Semantic color tokens. Each maps to an exact hex from the Figma file.
    public enum Color {
        // Background & surface
        public static let cream = SwiftUI.Color(hex: bgCreamHex)
        public static let surfaceWhite = SwiftUI.Color(hex: surfaceWhiteHex)

        // Text
        public static let ink = SwiftUI.Color(hex: textInkHex)
        public static let body = SwiftUI.Color(hex: textBodyHex)
        public static let muted = SwiftUI.Color(hex: textMutedHex)
        public static let onColor = SwiftUI.Color(hex: textOnColorHex)

        // Brand & accents
        public static let terracotta = SwiftUI.Color(hex: primaryTerracottaHex)
        public static let green = SwiftUI.Color(hex: accentGreenHex)
        public static let gold = SwiftUI.Color(hex: accentGoldHex)
        public static let plum = SwiftUI.Color(hex: accentPlumHex)

        // Borders
        public static let borderSoft = SwiftUI.Color(hex: borderSoftHex)

        // MARK: Source hex strings (exposed so tests can catch drift)

        public static let bgCreamHex = "#fbf5ec"
        public static let textInkHex = "#2a2320"
        public static let textBodyHex = "#5a5049"
        public static let textMutedHex = "#8a7f76"
        public static let primaryTerracottaHex = "#c75d3c"
        public static let accentGreenHex = "#2e5d46"
        public static let accentGoldHex = "#f0c05a"
        public static let accentPlumHex = "#6e3b5c"
        public static let surfaceWhiteHex = "#ffffff"
        public static let borderSoftHex = "#ebe0cf"
        public static let textOnColorHex = "#ffffff"
    }

    // MARK: - Guide card colors

    /// Per-guide accent colors used by the explore cards. These are distinct from
    /// the semantic accent tokens above (they come straight from the guide data).
    public enum GuideColor {
        public static let coffeeHex = "#B4573C"
        public static let jobsHex = "#2F4C3A"
        public static let meetupsHex = "#E0B44A"
        public static let recordsHex = "#6E3D5B"

        public static let coffee = SwiftUI.Color(hex: coffeeHex)
        public static let jobs = SwiftUI.Color(hex: jobsHex)
        public static let meetups = SwiftUI.Color(hex: meetupsHex)
        public static let records = SwiftUI.Color(hex: recordsHex)

        /// Resolves a guide accent color by its slug ("coffee"/"jobs"/"meetups"/"records").
        /// Returns `nil` for an unknown slug so callers can decide on a fallback.
        public static func color(forSlug slug: String) -> SwiftUI.Color? {
            hex(forSlug: slug).map(SwiftUI.Color.init(hex:))
        }

        /// Resolves the source hex for a guide slug, or `nil` if unknown.
        /// Matching is case-insensitive.
        public static func hex(forSlug slug: String) -> String? {
            switch slug.lowercased() {
            case "coffee": return coffeeHex
            case "jobs": return jobsHex
            case "meetups": return meetupsHex
            case "records": return recordsHex
            default: return nil
            }
        }
    }
}
