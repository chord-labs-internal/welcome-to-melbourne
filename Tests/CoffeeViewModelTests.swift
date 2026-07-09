import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for ``CoffeeViewModel`` — content exposure, per-chip filtering,
/// exclusive selection, and the graceful failure fallback. All run without a UI by
/// injecting a fake ``ContentLoading``.
@MainActor
struct CoffeeViewModelTests {

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

    @Test func exposesHeaderAndFiltersFromContent() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        #expect(vm.screen.eyebrow == "BEST OF MELBOURNE")
        #expect(vm.screen.title == "Coffee")
        #expect(vm.screen.subtitle == "128 specialty cafés & roasters, ranked by locals.")
        #expect(vm.filters == ["All", "Espresso", "Filter", "Brunch", "Roasters"])
        #expect(vm.cafes.count == 4)
    }

    @Test func defaultsToFirstFilterSelected() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        #expect(vm.selectedFilter == "All")
        #expect(vm.isSelected("All"))
    }

    // MARK: - Filtering

    @Test func allReturnsEveryCafeInOrder() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("All")
        #expect(vm.filteredCafes.count == 4)
        #expect(vm.filteredCafes.map(\.id) == [1, 2, 3, 4])
    }

    @Test func espressoChipMatchesOnlyEspressoCafes() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Espresso")
        #expect(vm.filteredCafes.map(\.name) == ["Patricia Coffee Brewers"])
    }

    @Test func filterChipMatchesFilterCafes() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Filter")
        // Proud Mary (Filter, Brunch) + Market Lane (Filter).
        #expect(Set(vm.filteredCafes.map(\.name)) == ["Proud Mary", "Market Lane Coffee"])
    }

    @Test func brunchChipMatchesBrunchCafes() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Brunch")
        #expect(Set(vm.filteredCafes.map(\.name)) == ["Proud Mary", "Seven Seeds"])
    }

    @Test func roastersChipMatchesRoastersCafes() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Roasters")
        #expect(vm.filteredCafes.map(\.name) == ["Seven Seeds"])
    }

    @Test func unmatchedFilterReturnsEmpty() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Nonexistent")
        #expect(vm.filteredCafes.isEmpty)
    }

    // MARK: - Exclusive selection

    @Test func selectionIsExclusive() {
        let vm = CoffeeViewModel(contentLoader: FakeLoader(content: .coffeeFixture))
        vm.select("Brunch")
        #expect(vm.selectedFilter == "Brunch")
        #expect(vm.isSelected("Brunch"))
        for other in ["All", "Espresso", "Filter", "Roasters"] {
            #expect(!vm.isSelected(other))
        }
        // Selecting another replaces, never accumulates.
        vm.select("Espresso")
        #expect(vm.isSelected("Espresso"))
        #expect(!vm.isSelected("Brunch"))
    }

    // MARK: - Pure filter helper

    @Test func staticFilterMatchesInstanceBehaviour() {
        let cafes = AppContent.coffeeFixture.cafes
        #expect(CoffeeViewModel.cafes(cafes, matching: "All").count == 4)
        #expect(CoffeeViewModel.cafes(cafes, matching: "Roasters").map(\.name) == ["Seven Seeds"])
        #expect(CoffeeViewModel.isAll("all"))     // case-insensitive
        #expect(CoffeeViewModel.isAll("All"))
        #expect(!CoffeeViewModel.isAll("Espresso"))
    }

    // MARK: - Tile color

    @Test func tileColorIsStableAndCyclesByCafeId() {
        #expect(CoffeeViewModel.tileColor(forCafeId: 1) == Theme.Color.terracotta)
        #expect(CoffeeViewModel.tileColor(forCafeId: 2) == Theme.Color.green)
        #expect(CoffeeViewModel.tileColor(forCafeId: 3) == Theme.Color.gold)
        #expect(CoffeeViewModel.tileColor(forCafeId: 4) == Theme.Color.plum)
        // Wraps around the palette.
        #expect(CoffeeViewModel.tileColor(forCafeId: 5) == Theme.Color.terracotta)
    }

    // MARK: - Failure path

    @Test func degradesGracefullyWhenLoadingFails() {
        let vm = CoffeeViewModel(contentLoader: FailingLoader())
        #expect(vm.cafes.isEmpty)
        #expect(vm.filteredCafes.isEmpty)
        // Header still renders sensible copy rather than crashing.
        #expect(vm.screen.title == "Coffee")
        #expect(vm.selectedFilter == "All")
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Content matching `db.json` for the fields the Coffee screen renders.
    static let coffeeFixture = AppContent(
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
        coffeeScreen: CategoryScreen(
            eyebrow: "BEST OF MELBOURNE",
            title: "Coffee",
            subtitle: "128 specialty cafés & roasters, ranked by locals.",
            filters: ["All", "Espresso", "Filter", "Brunch", "Roasters"]
        ),
        cafes: [
            Cafe(id: 1, name: "Patricia Coffee Brewers", rating: 4.9, suburb: "CBD", tags: "Espresso · Standing room", categories: ["Espresso"], priceLevel: "$$", image: "https://example.com/1.jpg"),
            Cafe(id: 2, name: "Proud Mary", rating: 4.8, suburb: "Collingwood", tags: "Filter · All-day brunch", categories: ["Filter", "Brunch"], priceLevel: "$$$", image: "https://example.com/2.jpg"),
            Cafe(id: 3, name: "Market Lane Coffee", rating: 4.7, suburb: "Carlton", tags: "Single origin · Retail", categories: ["Filter"], priceLevel: "$$", image: "https://example.com/3.jpg"),
            Cafe(id: 4, name: "Seven Seeds", rating: 4.8, suburb: "Carlton", tags: "Roastery · Brunch", categories: ["Roasters", "Brunch"], priceLevel: "$$", image: "https://example.com/4.jpg"),
        ],
        jobsScreen: CategoryScreen(eyebrow: "e", title: "Find a job", subtitle: "s", filters: []),
        jobs: [],
        meetupsScreen: CategoryScreen(eyebrow: "e", title: "Meetups", subtitle: "s", filters: []),
        groups: [],
        recordsScreen: CategoryScreen(eyebrow: "e", title: "Records", subtitle: "s", filters: []),
        records: [],
        nav: []
    )
}
