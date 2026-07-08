import SwiftUI

public extension Theme {

    /// The type ramp. Point sizes are exposed as raw constants so tests can assert
    /// them, and each has a matching `Font` builder for use in views.
    ///
    /// The ramp also encodes the typeface family (serif vs sans) so screens never
    /// choose fonts themselves. Per the Figma home screen, DISPLAY/TITLE styles use
    /// a serif design while body/supporting text is sans.
    enum Typography {

        // MARK: Raw point sizes

        public static let heroTitleSize: CGFloat = 40
        public static let greetingSize: CGFloat = 26
        public static let sectionTitleSize: CGFloat = 22
        public static let cardTitleSize: CGFloat = 18
        public static let bodySize: CGFloat = 15
        public static let countLabelSize: CGFloat = 13
        public static let eyebrowSize: CGFloat = 12
        public static let tabLabelSize: CGFloat = 11

        // MARK: Fonts — serif display/title styles

        /// Large screen heading, e.g. the home "Melbourne" title (~40pt, serif, heavy).
        public static let heroTitle = Font.system(size: heroTitleSize, weight: .heavy, design: .serif)

        /// The "Welcome to" line above the hero (~26pt, serif, regular).
        public static let greeting = Font.system(size: greetingSize, weight: .regular, design: .serif)

        /// Section header, e.g. "Explore the city" / "Featured this week" (~22pt, serif, bold).
        public static let sectionTitle = Font.system(size: sectionTitleSize, weight: .bold, design: .serif)

        /// Card heading, e.g. "Coffee" / "Jobs" (~18pt, serif, semibold).
        public static let cardTitle = Font.system(size: cardTitleSize, weight: .semibold, design: .serif)

        // MARK: Fonts — sans body/supporting styles

        /// Default reading text (~15pt, sans).
        public static let body = Font.system(size: bodySize, weight: .regular)

        /// Small supporting count label, e.g. "128 spots" (~13pt, sans).
        public static let countLabel = Font.system(size: countLabelSize, weight: .medium)

        /// Small tracked/uppercased label, e.g. the weather eyebrow (~12pt, sans).
        /// Apply `.textCase(.uppercase)` and tracking at the call site.
        public static let eyebrow = Font.system(size: eyebrowSize, weight: .semibold)

        /// Bottom tab bar label (~11pt, sans).
        public static let tabLabel = Font.system(size: tabLabelSize, weight: .medium)
    }
}
