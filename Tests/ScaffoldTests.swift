import Testing
@testable import WelcomeToMelbourne

/// Trivial sanity test proving the unit-test target is wired up.
/// Real view-model / decoding tests arrive with their features.
struct ScaffoldTests {
    @Test func appTargetIsLinked() {
        // If this compiles and runs, the test target can import the app module.
        #expect(Bool(true))
    }
}
