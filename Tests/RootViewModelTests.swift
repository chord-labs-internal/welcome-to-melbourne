import Testing
@testable import WelcomeToMelbourne

/// Unit tests for ``RootViewModel`` — tab derivation and the failure fallback.
@MainActor
struct RootViewModelTests {

    // MARK: - Fakes

    /// Returns fixed content, no bundle or singleton involved.
    private struct FakeLoader: ContentLoading {
        var content: AppContent
        func load() throws -> AppContent { content }
    }

    /// Always fails, to exercise the fallback path.
    private struct FailingLoader: ContentLoading {
        func load() throws -> AppContent {
            throw ContentLoadingError.resourceNotFound(resource: "db", ext: "json")
        }
    }

    // MARK: - Success path

    @Test func exposesFiveTabsInOrderFromNavData() {
        let viewModel = RootViewModel(contentLoader: FakeLoader(content: .fixture))

        #expect(viewModel.tabs.count == 5)
        #expect(viewModel.tabs.map(\.label) == ["Home", "Coffee", "Jobs", "Groups", "Records"])
        #expect(viewModel.tabs.map(\.systemImage) == [
            "house", "cup.and.saucer", "briefcase", "person.2", "opticaldisc",
        ])
        #expect(viewModel.tabs.map(\.route) == ["/", "/coffee", "/jobs", "/groups", "/records"])
        #expect(viewModel.tabs.map(\.accessibilityIdentifier) == [
            "tab.home", "tab.coffee", "tab.jobs", "tab.groups", "tab.records",
        ])
    }

    @Test func retainsDecodedContentOnSuccess() {
        let viewModel = RootViewModel(contentLoader: FakeLoader(content: .fixture))
        #expect(viewModel.content?.home.city == "Melbourne")
        #expect(viewModel.content?.coffeeScreen.title == "Coffee")
    }

    // MARK: - Icon mapping

    @Test func mapsKnownIconsToSFSymbols() {
        #expect(RootTab.systemImage(forIcon: "home") == "house")
        #expect(RootTab.systemImage(forIcon: "coffee") == "cup.and.saucer")
        #expect(RootTab.systemImage(forIcon: "briefcase") == "briefcase")
        #expect(RootTab.systemImage(forIcon: "users") == "person.2")
        #expect(RootTab.systemImage(forIcon: "disc") == "opticaldisc")
    }

    @Test func mapsUnknownIconToFallbackSymbol() {
        #expect(RootTab.systemImage(forIcon: "totally-unknown") == "circle.circle")
    }

    // MARK: - Failure path

    @Test func fallsBackToBuiltInTabsWhenLoadingFails() {
        let viewModel = RootViewModel(contentLoader: FailingLoader())

        #expect(viewModel.content == nil)
        #expect(viewModel.tabs == RootViewModel.defaultTabs)
        #expect(viewModel.tabs.map(\.label) == ["Home", "Coffee", "Jobs", "Groups", "Records"])
        #expect(viewModel.tabs.map(\.accessibilityIdentifier) == [
            "tab.home", "tab.coffee", "tab.jobs", "tab.groups", "tab.records",
        ])
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Minimal but fully-valid content whose `nav` mirrors `db.json`.
    static let fixture = AppContent(
        home: Home(
            weather: Weather(day: "Saturday", temperature: 18, unit: "C", condition: "Sunny", label: "SATURDAY · 18° · SUNNY"),
            greeting: "Welcome to",
            city: "Melbourne",
            tagline: "tagline",
            searchPlaceholder: "search",
            exploreTitle: "Explore",
            exploreCount: "4 guides",
            featuredTitle: "Featured"
        ),
        guides: [],
        featured: [],
        coffeeScreen: CategoryScreen(eyebrow: "e", title: "Coffee", subtitle: "s", filters: []),
        cafes: [],
        jobsScreen: CategoryScreen(eyebrow: "e", title: "Find a job", subtitle: "s", filters: []),
        jobs: [],
        meetupsScreen: CategoryScreen(eyebrow: "e", title: "Meetups", subtitle: "s", filters: []),
        groups: [],
        recordsScreen: CategoryScreen(eyebrow: "e", title: "Records", subtitle: "s", filters: []),
        records: [],
        nav: [
            NavItem(id: 1, label: "Home", icon: "home", route: "/", active: true),
            NavItem(id: 2, label: "Coffee", icon: "coffee", route: "/coffee", active: false),
            NavItem(id: 3, label: "Jobs", icon: "briefcase", route: "/jobs", active: false),
            NavItem(id: 4, label: "Groups", icon: "users", route: "/groups", active: false),
            NavItem(id: 5, label: "Records", icon: "disc", route: "/records", active: false),
        ]
    )
}
