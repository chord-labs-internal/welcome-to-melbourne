import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for the shared ``AttributePill`` component — style resolution and
/// default styling. Exercises the pure, UI-free ``AttributePillStyle`` so pill
/// styling can't drift from ``Theme`` unnoticed.
@MainActor
struct AttributePillTests {

    @Test func neutralStyleUsesSandFillAndBodyText() {
        let style = AttributePillStyle.neutral
        #expect(style.background == Color(hex: AttributePill.neutralBackgroundHex))
        #expect(style.foreground == Theme.Color.body)
        #expect(style.isEmphasized == false)
    }

    @Test func accentStyleTintsBackgroundAndEmphasizesText() {
        let style = AttributePillStyle.accent(Theme.Color.green)
        #expect(style.background == Theme.Color.green.opacity(0.12))
        #expect(style.foreground == Theme.Color.green)
        #expect(style.isEmphasized == true)
    }

    @Test func neutralAndAccentStylesDiffer() {
        #expect(AttributePillStyle.neutral != AttributePillStyle.accent(Theme.Color.green))
    }

    @Test func pillDefaultsToNeutralStyle() {
        let pill = AttributePill("Full-time")
        #expect(pill.style == .neutral)
        #expect(pill.text == "Full-time")
    }

    @Test func pillHonorsExplicitAccentStyle() {
        let pill = AttributePill("$130–160k", style: .accent(Theme.Color.green))
        #expect(pill.style == .accent(Theme.Color.green))
    }
}
