import XCTest

/// UI tests for the Home screen (issue #6): hero, search pill, explore grid, and
/// the featured carousel.
final class HomeUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testHomeShowsHeroExploreGridAndSearch() {
        let app = XCUIApplication()
        app.launch()

        // Home is the launch tab: hero title is visible.
        XCTAssertTrue(app.staticTexts["Melbourne"].waitForExistence(timeout: 10),
                      "Home hero 'Melbourne' should be visible on launch")

        // Explore section header.
        XCTAssertTrue(app.staticTexts["Explore the city"].exists,
                      "The 'Explore the city' section header should be visible")

        // All four guide cards exist with stable identifiers.
        for slug in ["coffee", "jobs", "meetups", "records"] {
            XCTAssertTrue(app.buttons["guide.\(slug)"].exists,
                          "Guide card 'guide.\(slug)' should exist")
        }

        // The search pill exists.
        XCTAssertTrue(app.otherElements["home.search"].exists || app.staticTexts["home.search"].exists,
                      "The search field 'home.search' should exist")
    }

    @MainActor
    func testScrollingRevealsFeaturedCard() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Melbourne"].waitForExistence(timeout: 10))

        // Scroll to the featured section and confirm at least one featured card.
        let featured = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'featured.'")
        )
        var attempts = 0
        while featured.count == 0 && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertGreaterThan(featured.count, 0,
                             "Scrolling down should reveal at least one 'featured.*' card")
    }
}
