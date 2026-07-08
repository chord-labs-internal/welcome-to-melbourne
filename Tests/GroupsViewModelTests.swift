import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for ``GroupsViewModel`` — content exposure, per-chip filtering
/// (including the `New here` → newcomer mapping), the per-card accent/symbol
/// cycle, and the graceful failure fallback. All run without a UI by injecting a
/// fake ``ContentLoading``.
@MainActor
struct GroupsViewModelTests {

    // MARK: - Fakes

    private struct FakeLoader: ContentLoading {
        var content: AppContent
        func load() throws -> AppContent { content }
    }

    private struct FailingLoader: ContentLoading {
        func load() throws -> AppContent {
            throw ContentLoadingError.resourceNotFound(resource: "db", ext: "json")
        }
    }

    // MARK: - Content exposure

    @Test func exposesHeaderCopyAndFilters() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.screen.eyebrow == "MEET YOUR PEOPLE")
        #expect(vm.screen.title == "Meetups")
        #expect(vm.filters == ["All", "Social", "Fitness", "Creative", "New here"])
    }

    @Test func exposesAllGroupsInOrder() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.groups.count == 4)
        #expect(vm.groups.map(\.name) == [
            "Melbourne Coffee Lovers",
            "Run Club Melbourne",
            "Design & Coffee",
            "New in Melbourne",
        ])
    }

    @Test func defaultsToFirstFilter() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.selectedFilter == "All")
    }

    // MARK: - Filtering: All

    @Test func allFilterReturnsEveryGroup() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "All"
        #expect(vm.filteredGroups.count == 4)
        #expect(vm.filteredGroups == vm.groups)
    }

    // MARK: - Filtering: per category chip

    @Test func socialFilterReturnsBothSocialGroups() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Social"
        #expect(vm.filteredGroups.map(\.name) == ["Melbourne Coffee Lovers", "New in Melbourne"])
    }

    @Test func fitnessFilterReturnsRunClub() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Fitness"
        #expect(vm.filteredGroups.map(\.name) == ["Run Club Melbourne"])
    }

    @Test func creativeFilterReturnsDesignGroup() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Creative"
        #expect(vm.filteredGroups.map(\.name) == ["Design & Coffee"])
    }

    // MARK: - Filtering: "New here" → newcomer mapping

    @Test func newHereFilterReturnsNewcomerGroupOnly() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "New here"
        // "New here" is NOT a group category; it maps to the newcomer group.
        #expect(vm.filteredGroups.map(\.name) == ["New in Melbourne"])
    }

    @Test func newHereChipHasNoMatchingCategory() {
        // Sanity: no group actually carries the category "New here".
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.groups.contains { $0.category == "New here" } == false)
    }

    @Test func isNewcomerMatchesNameContainingNew() {
        let newcomer = Group(id: 9, name: "New in Melbourne", category: "Social", suburb: "Citywide", description: "", members: 0, membersLabel: "", nextMeet: "")
        let other = Group(id: 10, name: "Run Club Melbourne", category: "Fitness", suburb: "Yarra", description: "", members: 0, membersLabel: "", nextMeet: "")
        #expect(GroupsViewModel.isNewcomer(newcomer) == true)
        #expect(GroupsViewModel.isNewcomer(other) == false)
    }

    // MARK: - Static filter helper

    @Test func staticFilterMatchesCategoryExactly() {
        let groups = AppContent.fixture.groups
        #expect(GroupsViewModel.groups(groups, matching: "Fitness").map(\.name) == ["Run Club Melbourne"])
        #expect(GroupsViewModel.groups(groups, matching: "All").count == 4)
        #expect(GroupsViewModel.groups(groups, matching: "New here").map(\.name) == ["New in Melbourne"])
    }

    // MARK: - Per-card accent + symbol cycle

    @Test func accentColorCyclesByIndex() {
        #expect(GroupsViewModel.accentColor(forIndex: 0) == Theme.Color.terracotta)
        #expect(GroupsViewModel.accentColor(forIndex: 1) == Theme.Color.green)
        #expect(GroupsViewModel.accentColor(forIndex: 2) == Theme.Color.plum)
        #expect(GroupsViewModel.accentColor(forIndex: 3) == Theme.Color.gold)
        // Wraps.
        #expect(GroupsViewModel.accentColor(forIndex: 4) == Theme.Color.terracotta)
    }

    @Test func symbolNameCyclesByIndex() {
        #expect(GroupsViewModel.symbolName(forIndex: 0) == "cup.and.saucer.fill")
        #expect(GroupsViewModel.symbolName(forIndex: 1) == "bolt.fill")
        #expect(GroupsViewModel.symbolName(forIndex: 2) == "paintpalette.fill")
        #expect(GroupsViewModel.symbolName(forIndex: 3) == "sparkles")
    }

    @Test func perGroupAccentIsStableAcrossFiltering() {
        let vm = GroupsViewModel(contentLoader: FakeLoader(content: .fixture))
        // Run Club is at index 1 in the full list → green, regardless of the
        // filter narrowing the visible list to just itself.
        let runClub = vm.groups[1]
        #expect(vm.accentColor(for: runClub) == Theme.Color.green)
        vm.selectedFilter = "Fitness"
        #expect(vm.filteredGroups == [runClub])
        #expect(vm.accentColor(for: runClub) == Theme.Color.green)
        #expect(vm.symbolName(for: runClub) == "bolt.fill")
    }

    // MARK: - Failure path

    @Test func degradesGracefullyWhenLoadingFails() {
        let vm = GroupsViewModel(contentLoader: FailingLoader())
        #expect(vm.groups.isEmpty)
        #expect(vm.filteredGroups.isEmpty)
        // Still renders sensible header copy and at least the "All" chip.
        #expect(vm.screen.title == "Meetups")
        #expect(vm.selectedFilter == "All")
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Content matching `db.json` for the fields the Meetups screen renders.
    static let fixture = AppContent(
        home: Home(
            weather: Weather(day: "Saturday", temperature: 18, unit: "C", condition: "Sunny", label: "SATURDAY · 18° · SUNNY"),
            greeting: "Welcome to",
            city: "Melbourne",
            tagline: "",
            searchPlaceholder: "Search",
            exploreTitle: "Explore the city",
            exploreCount: "4 guides",
            featuredTitle: "Featured this week"
        ),
        guides: [],
        featured: [],
        coffeeScreen: CategoryScreen(eyebrow: "e", title: "Coffee", subtitle: "s", filters: []),
        cafes: [],
        jobsScreen: CategoryScreen(eyebrow: "e", title: "Find a job", subtitle: "s", filters: []),
        jobs: [],
        meetupsScreen: CategoryScreen(
            eyebrow: "MEET YOUR PEOPLE",
            title: "Meetups",
            subtitle: "56 groups making it easy to find friends in Melbourne.",
            filters: ["All", "Social", "Fitness", "Creative", "New here"]
        ),
        groups: [
            Group(id: 1, name: "Melbourne Coffee Lovers", category: "Social", suburb: "CBD", description: "Weekend café crawls & latte-art throwdowns across the city.", members: 1200, membersLabel: "1.2k members", nextMeet: "Sat 9:00am"),
            Group(id: 2, name: "Run Club Melbourne", category: "Fitness", suburb: "Yarra", description: "Easy 5k along the river every Tuesday. All paces welcome.", members: 860, membersLabel: "860 members", nextMeet: "Tue 6:00pm"),
            Group(id: 3, name: "Design & Coffee", category: "Creative", suburb: "Collingwood", description: "Portfolio nights & casual crits for designers and makers.", members: 540, membersLabel: "540 members", nextMeet: "Thu 7:00pm"),
            Group(id: 4, name: "New in Melbourne", category: "Social", suburb: "Citywide", description: "Just moved here? Make friends fast at weekly hangs.", members: 2400, membersLabel: "2.4k members", nextMeet: "Fri 6:30pm"),
        ],
        recordsScreen: CategoryScreen(eyebrow: "e", title: "Records", subtitle: "s", filters: []),
        records: [],
        nav: []
    )
}
