import XCTest

/// UI tests for the Records guide screen (issue #10): navigate to the Records
/// tab, confirm the store list renders, then apply a filter and confirm the list
/// updates.
final class RecordsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testRecordsTabShowsStoresAndFilterUpdatesList() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Records tab.
        let recordsTab = app.tabBars.buttons["Records"]
        XCTAssertTrue(recordsTab.waitForExistence(timeout: 10),
                      "The Records tab should exist in the tab bar")
        recordsTab.tap()

        // The Records header is visible.
        XCTAssertTrue(app.staticTexts["records.title"].waitForExistence(timeout: 5),
                      "The Records screen title should be visible")

        // All four stores render under the default "All" filter.
        let roundRound = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == 'record.1'")).firstMatch
        let thornbury = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == 'record.4'")).firstMatch
        XCTAssertTrue(roundRound.waitForExistence(timeout: 5),
                      "Round & Round Records (record.1) should be visible under 'All'")
        XCTAssertTrue(thornbury.exists,
                      "Thornbury Records (record.4) should be visible under 'All'")

        // Apply the "Vinyl" filter — a Second-hand-only store drops out.
        app.buttons["chip.Vinyl"].tap()

        XCTAssertTrue(roundRound.waitForExistence(timeout: 5),
                      "Round & Round Records (Vinyl) should remain after filtering")
        // Thornbury Records is Second-hand only, so it should disappear.
        expectDisappears(thornbury, message: "Thornbury Records should be filtered out under 'Vinyl'")
    }

    /// Polls until the element no longer exists, failing if it lingers.
    @MainActor
    private func expectDisappears(_ element: XCUIElement, message: String) {
        var attempts = 0
        while element.exists && attempts < 10 {
            usleep(200_000)
            attempts += 1
        }
        XCTAssertFalse(element.exists, message)
    }
}
