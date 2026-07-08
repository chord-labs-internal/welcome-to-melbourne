import XCTest

/// Smoke UI test proving the app launches to the placeholder screen.
final class ScaffoldUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchesToPlaceholder() {
        let app = XCUIApplication()
        app.launch()

        let placeholder = app.staticTexts["Melbourne"]
        XCTAssertTrue(placeholder.waitForExistence(timeout: 10),
                      "Placeholder root screen should appear on launch")
    }
}
