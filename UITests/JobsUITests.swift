import XCTest

/// UI tests for the Jobs guide screen (issue #8): browse the job list and apply a
/// filter to narrow it.
final class JobsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testOpenJobsApplyFilterUpdatesList() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Jobs tab.
        let jobsTab = app.tabBars.buttons["Jobs"]
        XCTAssertTrue(jobsTab.waitForExistence(timeout: 10), "Jobs tab should exist")
        jobsTab.tap()

        // The header and all four job cards are visible on the "All" filter.
        XCTAssertTrue(app.staticTexts["jobs.header.title"].waitForExistence(timeout: 5),
                      "Jobs header title should appear")
        for id in ["job.1", "job.2", "job.3", "job.4"] {
            XCTAssertTrue(app.buttons[id].waitForExistence(timeout: 5),
                          "Job card '\(id)' should be visible under the 'All' filter")
        }

        // Apply the Tech filter: only the Tech job (job.2) remains.
        app.buttons["chip.Tech"].tap()
        XCTAssertTrue(app.buttons["job.2"].waitForExistence(timeout: 5),
                      "The Tech job (job.2) should remain after filtering")
        XCTAssertFalse(app.buttons["job.1"].exists,
                       "A Design job (job.1) should be filtered out by the Tech chip")
        XCTAssertFalse(app.buttons["job.3"].exists,
                       "A Hospitality job (job.3) should be filtered out by the Tech chip")

        // Switch back to All: every card returns.
        app.buttons["chip.All"].tap()
        XCTAssertTrue(app.buttons["job.1"].waitForExistence(timeout: 5),
                      "Selecting 'All' should bring every job card back")
    }
}
