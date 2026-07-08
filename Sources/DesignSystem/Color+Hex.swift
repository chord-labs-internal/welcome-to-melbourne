import SwiftUI

public extension Color {
    /// Creates a `Color` from a 6-digit hex string.
    ///
    /// Tolerant of a leading `#` and surrounding whitespace, e.g. `"#fbf5ec"`,
    /// `"FBF5EC"`, or `" #fbf5ec "` all decode to the same color. Colors are
    /// defined in the extended sRGB space so they resolve deterministically in
    /// tests via `Color.resolve(in:)`.
    ///
    /// Any string that is not exactly six hex digits (after stripping `#` and
    /// whitespace) falls back to opaque black so callers never crash on bad input.
    init(hex: String) {
        let rgb = Color.rgbComponents(fromHex: hex)
        self.init(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: 1)
    }

    /// Parses a 6-digit hex string into normalized (0...1) sRGB components.
    /// Exposed so unit tests can assert the parser directly against known values.
    static func rgbComponents(fromHex hex: String) -> (red: Double, green: Double, blue: Double) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
            return (0, 0, 0)
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        return (red, green, blue)
    }
}
