import XCTest

/// UI tests for the Meetups guide screen (issue #9): open the Groups tab, see the
/// group cards, then apply a filter and confirm the list updates.
final class MeetupsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    @MainActor
    func testOpenGroupsApplyFilterUpdatesList() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to the Groups (Meetups) tab.
        let groupsTab = app.tabBars.buttons["Groups"]
        XCTAssertTrue(groupsTab.waitForExistence(timeout: 10), "Groups tab should exist")
        groupsTab.tap()

        // The Meetups header is visible.
        XCTAssertTrue(app.staticTexts["meetups.title"].waitForExistence(timeout: 5),
                      "Meetups header title should appear")

        // All five group cards are present under the default "All" filter.
        let allCards = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'group.'")
        )
        XCTAssertTrue(app.otherElements["group.1"].waitForExistence(timeout: 5),
                      "First group card should exist")
        XCTAssertEqual(allCards.count, 5, "All five group cards should show under the 'All' filter")

        // Apply the "Fitness" filter → only the Run Club card remains.
        app.buttons["chip.Fitness"].tap()

        let fitnessCards = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'group.'")
        )
        // group.2 is Run Club Melbourne (Fitness).
        XCTAssertTrue(app.otherElements["group.2"].waitForExistence(timeout: 5),
                      "Fitness group card should remain after filtering")
        XCTAssertEqual(fitnessCards.count, 1, "Only one card should remain after applying the Fitness filter")
    }

    @MainActor
    func testNewHereFilterShowsNewcomerGroup() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Groups"].tap()
        XCTAssertTrue(app.staticTexts["meetups.title"].waitForExistence(timeout: 10))

        // "New here" maps to the "New in Melbourne" group (group.4), not a category.
        app.buttons["chip.New here"].tap()

        XCTAssertTrue(app.otherElements["group.4"].waitForExistence(timeout: 5),
                      "The newcomer group should show under the 'New here' filter")
        let cards = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'group.'")
        )
        XCTAssertEqual(cards.count, 1, "Only the newcomer group should remain under 'New here'")
    }

    @MainActor
    func testTechFilterShowsCocoaheads() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Groups"].tap()
        XCTAssertTrue(app.staticTexts["meetups.title"].waitForExistence(timeout: 10))

        // "Tech" is the last chip and starts off-screen. Scroll the filter row to
        // bring it into view. `isHittable` throws on an off-screen element, so
        // swipe unconditionally rather than guarding on it.
        let techChip = app.buttons["chip.Tech"]
        XCTAssertTrue(techChip.waitForExistence(timeout: 5), "Tech chip should exist")
        let filterRow = app.scrollViews["meetups.filters"]
        XCTAssertTrue(filterRow.waitForExistence(timeout: 5), "Filter row should exist")
        filterRow.swipeLeft()

        // "Tech" matches on category → only Melbourne Cocoaheads (group.5).
        techChip.tap()

        XCTAssertTrue(app.otherElements["group.5"].waitForExistence(timeout: 5),
                      "Melbourne Cocoaheads should show under the 'Tech' filter")
        let cards = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'group.'")
        )
        XCTAssertEqual(cards.count, 1, "Only Cocoaheads should remain under 'Tech'")
    }
}
