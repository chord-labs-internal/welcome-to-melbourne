import XCTest

/// UI tests for the root tab navigation shell (issue #5).
///
/// Verifies the Liquid Glass tab bar renders on launch and that switching tabs
/// navigates to the corresponding screen.
final class RootTabBarUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsTabBarAndSwitchingTabsNavigates() {
        let app = XCUIApplication()
        app.launch()

        // The tab bar is present with the Home tab selected on launch.
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 10),
                      "Tab bar with a Home tab should appear on launch")
        XCTAssertTrue(app.tabBars.buttons["Coffee"].exists, "Coffee tab should exist")

        // Home content is showing.
        XCTAssertTrue(app.staticTexts["Melbourne"].waitForExistence(timeout: 5),
                      "Home screen should show the Melbourne hero")

        // Tapping the Coffee tab navigates to the Coffee screen.
        app.tabBars.buttons["Coffee"].tap()
        let coffeeTitle = app.staticTexts["screen.coffee.title"]
        XCTAssertTrue(coffeeTitle.waitForExistence(timeout: 5),
                      "Tapping the Coffee tab should reveal the Coffee screen")
    }
}
