import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for ``RecordsViewModel`` — content exposure, per-chip filtering,
/// rating formatting, and the graceful failure fallback. All run without a UI by
/// injecting a fake ``ContentLoading``.
@MainActor
struct RecordsViewModelTests {

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

    @Test func exposesHeaderAndStoresFromContent() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.screen.eyebrow == "CRATE DIGGING")
        #expect(vm.screen.title == "Records")
        #expect(vm.screen.filters == ["All", "Vinyl", "Rare finds", "Second-hand", "New in"])
        #expect(vm.records.count == 4)
    }

    @Test func defaultsSelectedFilterToFirstFilter() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.selectedFilter == "All")
    }

    // MARK: - Filtering

    @Test func allFilterReturnsEveryStore() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "All"
        #expect(vm.filteredRecords.count == 4)
        #expect(vm.filteredRecords.map(\.id) == [1, 2, 3, 4])
    }

    @Test func vinylFilterReturnsMatchingStores() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Vinyl"
        #expect(vm.filteredRecords.map(\.id) == [1, 2, 3])
    }

    @Test func rareFindsFilterReturnsMatchingStores() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Rare finds"
        #expect(vm.filteredRecords.map(\.id) == [1, 3])
    }

    @Test func secondHandFilterReturnsMatchingStores() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "Second-hand"
        #expect(vm.filteredRecords.map(\.id) == [2, 4])
    }

    @Test func filterWithNoMatchesReturnsEmpty() {
        let vm = RecordsViewModel(contentLoader: FakeLoader(content: .fixture))
        vm.selectedFilter = "New in"
        #expect(vm.filteredRecords.isEmpty)
    }

    @Test func pureFilterMatchesCategories() {
        let records = AppContent.fixture.records
        #expect(RecordsViewModel.filter(records, by: "All", allFilter: "All").count == 4)
        #expect(RecordsViewModel.filter(records, by: "Vinyl", allFilter: "All").map(\.id) == [1, 2, 3])
        #expect(RecordsViewModel.filter(records, by: "Second-hand", allFilter: "All").map(\.id) == [2, 4])
    }

    // MARK: - Rating formatting

    @Test func formatsRatingToOneDecimal() {
        #expect(RecordsViewModel.formattedRating(4.8) == "4.8")
        #expect(RecordsViewModel.formattedRating(5) == "5.0")
        #expect(RecordsViewModel.formattedRating(4.65) == "4.7")
    }

    // MARK: - Failure path

    @Test func degradesGracefullyWhenLoadingFails() {
        let vm = RecordsViewModel(contentLoader: FailingLoader())
        #expect(vm.records.isEmpty)
        #expect(vm.filteredRecords.isEmpty)
        // Header still renders sensible copy rather than crashing.
        #expect(vm.screen.title == "Records")
        #expect(vm.selectedFilter == "All")
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Content matching `db.json` for the fields the Records screen renders.
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
        meetupsScreen: CategoryScreen(eyebrow: "e", title: "Meetups", subtitle: "s", filters: []),
        groups: [],
        recordsScreen: CategoryScreen(
            eyebrow: "CRATE DIGGING",
            title: "Records",
            subtitle: "22 vinyl & record stores worth the trip across town.",
            filters: ["All", "Vinyl", "Rare finds", "Second-hand", "New in"]
        ),
        records: [
            Record(id: 1, name: "Round & Round Records", rating: 4.8, suburb: "Brunswick", genres: "Soul · Funk · Jazz", categories: ["Vinyl", "Rare finds"], image: "https://picsum.photos/seed/roundround/120/120"),
            Record(id: 2, name: "Basement Discs", rating: 4.7, suburb: "CBD", genres: "Rock · Blues · Live", categories: ["Vinyl", "Second-hand"], image: "https://picsum.photos/seed/basement/120/120"),
            Record(id: 3, name: "Strangeworld Records", rating: 4.9, suburb: "Fitzroy", genres: "Punk · Indie · Rare", categories: ["Vinyl", "Rare finds"], image: "https://picsum.photos/seed/strangeworld/120/120"),
            Record(id: 4, name: "Thornbury Records", rating: 4.6, suburb: "Thornbury", genres: "Second-hand · All genres", categories: ["Second-hand"], image: "https://picsum.photos/seed/thornbury/120/120"),
        ],
        nav: []
    )
}
