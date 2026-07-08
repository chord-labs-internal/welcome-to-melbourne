import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for ``HomeViewModel`` — content exposure, derived presentation
/// mappings, and the graceful failure fallback. All run without a UI by injecting
/// a fake ``ContentLoading``.
@MainActor
struct HomeViewModelTests {

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

    @Test func exposesHomeCopyFromContent() {
        let vm = HomeViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.home.exploreTitle == "Explore the city")
        #expect(vm.home.city == "Melbourne")
        #expect(vm.home.featuredTitle == "Featured this week")
        #expect(vm.eyebrow == "SATURDAY · 18° · SUNNY")
        #expect(vm.eyebrow == vm.home.weather.label)
    }

    @Test func exposesFourGuidesInOrder() {
        let vm = HomeViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(vm.guides.count == 4)
        #expect(vm.guides.map(\.slug) == ["coffee", "jobs", "meetups", "records"])
    }

    @Test func exposesFeaturedItems() {
        let vm = HomeViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(!vm.featured.isEmpty)
        #expect(vm.featured.contains { $0.title == "Patricia Coffee Brewers" })
    }

    // MARK: - Guide → SF Symbol mapping

    @Test func mapsGuideSlugsToSymbols() {
        #expect(HomeViewModel.symbolName(forGuide: "coffee") == "cup.and.saucer")
        #expect(HomeViewModel.symbolName(forGuide: "jobs") == "briefcase")
        #expect(HomeViewModel.symbolName(forGuide: "meetups") == "person.2")
        #expect(HomeViewModel.symbolName(forGuide: "records") == "opticaldisc")
    }

    @Test func mapsGuideIconTokensToSymbols() {
        // The raw `icon` tokens from db.json also resolve.
        #expect(HomeViewModel.symbolName(forGuide: "briefcase") == "briefcase")
        #expect(HomeViewModel.symbolName(forGuide: "users") == "person.2")
        #expect(HomeViewModel.symbolName(forGuide: "disc") == "opticaldisc")
    }

    @Test func mapsUnknownGuideKeyToFallbackSymbol() {
        #expect(HomeViewModel.symbolName(forGuide: "totally-unknown") == "mappin.and.ellipse")
    }

    // MARK: - Featured tint mapping

    @Test func mapsFeaturedTypeToTint() {
        #expect(HomeViewModel.featuredTint(forType: "coffee") == Theme.Color.terracotta)
        #expect(HomeViewModel.featuredTint(forType: "job") == Theme.Color.green)
        #expect(HomeViewModel.featuredTint(forType: "record") == Theme.Color.plum)
        #expect(HomeViewModel.featuredTint(forType: "other") == Theme.Color.terracotta)
    }

    // MARK: - Guide card color

    @Test func resolvesGuideCardColorFromSlug() {
        let coffee = Guide(id: 1, slug: "coffee", title: "Coffee", subtitle: "", count: 0, countLabel: "", icon: "coffee", color: "#000000", route: "/coffee")
        #expect(HomeViewModel.cardColor(for: coffee) == Theme.GuideColor.coffee)
    }

    // MARK: - Failure path

    @Test func degradesGracefullyWhenLoadingFails() {
        let vm = HomeViewModel(contentLoader: FailingLoader())
        #expect(vm.guides.isEmpty)
        #expect(vm.featured.isEmpty)
        // Hero still renders sensible copy rather than crashing.
        #expect(vm.home.city == "Melbourne")
        #expect(vm.home.greeting == "Welcome to")
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Content matching `db.json` for the fields Home renders.
    static let fixture = AppContent(
        home: Home(
            weather: Weather(day: "Saturday", temperature: 18, unit: "C", condition: "Sunny", label: "SATURDAY · 18° · SUNNY"),
            greeting: "Welcome to",
            city: "Melbourne",
            tagline: "Your local guide to the world's most liveable city.",
            searchPlaceholder: "Search cafés, jobs, meetups…",
            exploreTitle: "Explore the city",
            exploreCount: "4 guides",
            featuredTitle: "Featured this week"
        ),
        guides: [
            Guide(id: 1, slug: "coffee", title: "Coffee", subtitle: "The city's best cafés & roasters", count: 128, countLabel: "128 spots", icon: "coffee", color: "#B4573C", route: "/coffee"),
            Guide(id: 2, slug: "jobs", title: "Jobs", subtitle: "Roles hiring across Melbourne", count: 340, countLabel: "340 open", icon: "briefcase", color: "#2F4C3A", route: "/jobs"),
            Guide(id: 3, slug: "meetups", title: "Meetups", subtitle: "Find your people & make friends", count: 56, countLabel: "56 groups", icon: "users", color: "#E0B44A", route: "/groups"),
            Guide(id: 4, slug: "records", title: "Records", subtitle: "Vinyl & crate-digging spots", count: 22, countLabel: "22 stores", icon: "disc", color: "#6E3D5B", route: "/records"),
        ],
        featured: [
            FeaturedItem(id: 1, badge: "CAFÉ", type: "coffee", title: "Patricia Coffee Brewers", meta: "CBD · ★ 4.9", suburb: "CBD", rating: 4.9, refId: 1, image: "https://example.com/a.jpg"),
            FeaturedItem(id: 2, badge: "HIRING", type: "job", title: "Product Designer · Canva", meta: "Surry Hills · $120k", suburb: "Surry Hills", refId: 1, image: "https://example.com/b.jpg", salary: "$120k"),
            FeaturedItem(id: 3, badge: "VINYL", type: "record", title: "Round & Round Records", meta: "Brunswick · 4.8", suburb: "Brunswick", rating: 4.8, refId: 1, image: "https://example.com/c.jpg"),
        ],
        coffeeScreen: CategoryScreen(eyebrow: "e", title: "Coffee", subtitle: "s", filters: []),
        cafes: [],
        jobsScreen: CategoryScreen(eyebrow: "e", title: "Find a job", subtitle: "s", filters: []),
        jobs: [],
        meetupsScreen: CategoryScreen(eyebrow: "e", title: "Meetups", subtitle: "s", filters: []),
        groups: [],
        recordsScreen: CategoryScreen(eyebrow: "e", title: "Records", subtitle: "s", filters: []),
        records: [],
        nav: []
    )
}
