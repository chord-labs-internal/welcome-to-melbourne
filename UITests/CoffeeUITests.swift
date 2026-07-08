import XCTest

/// UI tests for the Coffee guide screen (issue #7): open the Coffee tab, confirm
/// the header + café list, then tap a filter chip and confirm the list narrows.
final class CoffeeUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testOpenCoffeeTapFilterUpdatesList() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Coffee tab.
        let coffeeTab = app.tabBars.buttons["Coffee"]
        XCTAssertTrue(coffeeTab.waitForExistence(timeout: 10), "Coffee tab should exist")
        coffeeTab.tap()

        // The Coffee header is visible.
        XCTAssertTrue(app.staticTexts["screen.coffee.title"].waitForExistence(timeout: 5),
                      "The Coffee screen title should be visible")

        // All four café cards are present under the default "All" filter.
        for id in 1...4 {
            XCTAssertTrue(app.otherElements["cafe.\(id)"].waitForExistence(timeout: 5),
                          "Café row 'cafe.\(id)' should exist under the All filter")
        }

        // Tapping the "Roasters" chip narrows the list to just Seven Seeds (cafe.4).
        let roasters = app.buttons["chip.Roasters"]
        XCTAssertTrue(roasters.waitForExistence(timeout: 5), "Roasters chip should exist")
        roasters.tap()

        XCTAssertTrue(app.otherElements["cafe.4"].waitForExistence(timeout: 5),
                      "Seven Seeds (cafe.4) should remain visible under Roasters")
        // Espresso-only and Filter-only cafés drop out of the list.
        XCTAssertFalse(app.otherElements["cafe.1"].exists,
                       "Patricia (cafe.1) should be hidden under the Roasters filter")
        XCTAssertFalse(app.otherElements["cafe.3"].exists,
                       "Market Lane (cafe.3) should be hidden under the Roasters filter")
    }
}
