import CoreGraphics

public extension Theme {

    /// Spacing scale. Screens should compose from these rather than literal numbers.
    enum Spacing {
        /// Tight inline gap (e.g. between an icon and its label).
        public static let xSmall: CGFloat = 4
        /// Small gap between related elements.
        public static let small: CGFloat = 8
        /// Default gap between stacked elements.
        public static let medium: CGFloat = 12
        /// Inner padding for cards (~16–18pt).
        public static let cardPadding: CGFloat = 16
        /// Larger card padding variant.
        public static let cardPaddingLarge: CGFloat = 18
        /// Gap between distinct sections.
        public static let section: CGFloat = 24
        /// Horizontal padding at the screen edge.
        public static let screen: CGFloat = 28
    }

    /// Corner-radius scale.
    enum Radius {
        /// Filter chips / pills.
        public static let chip: CGFloat = 12
        /// Small controls and inputs.
        public static let small: CGFloat = 14
        /// Standard cards (~20–24pt).
        public static let card: CGFloat = 20
        /// Larger card / hero container.
        public static let cardLarge: CGFloat = 24
    }
}
