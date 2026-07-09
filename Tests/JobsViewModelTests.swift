import Testing
import SwiftUI
@testable import WelcomeToMelbourne

/// Unit tests for ``JobsViewModel`` — content exposure, per-category filtering,
/// the avatar-color mapping, and the graceful failure fallback. All run without a
/// UI by injecting a fake ``ContentLoading``.
@MainActor
struct JobsViewModelTests {

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

    @Test func exposesHeaderAndJobsFromContent() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))
        #expect(vm.screen.eyebrow == "WORK IN MELBOURNE")
        #expect(vm.screen.title == "Find a job")
        #expect(vm.filters == ["All", "Design", "Tech", "Hospitality", "Remote"])
        #expect(vm.jobs.count == 4)
    }

    @Test func defaultsToFirstFilter() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))
        #expect(vm.selectedFilter == "All")
    }

    // MARK: - Filtering

    @Test func allFilterReturnsEveryJob() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))
        vm.select("All")
        #expect(vm.filteredJobs.count == vm.jobs.count)
        #expect(vm.filteredJobs.map(\.id) == [1, 2, 3, 4])
    }

    @Test func eachCategoryFilterReturnsMatchingJobs() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))

        vm.select("Design")
        #expect(vm.filteredJobs.map(\.title) == ["Senior Product Designer"])

        vm.select("Tech")
        #expect(vm.filteredJobs.map(\.title) == ["Frontend Engineer"])

        vm.select("Hospitality")
        #expect(vm.filteredJobs.map(\.title) == ["Head Barista"])

        vm.select("Remote")
        #expect(vm.filteredJobs.map(\.title) == ["Marketing Lead"])
    }

    @Test func everyFilteredJobMatchesTheSelectedCategory() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))
        for category in ["Design", "Tech", "Hospitality", "Remote"] {
            vm.select(category)
            #expect(vm.filteredJobs.allSatisfy { $0.category == category })
            #expect(!vm.filteredJobs.isEmpty)
        }
    }

    @Test func unknownFilterMatchesNothing() {
        let vm = JobsViewModel(contentLoader: FakeLoader(content: .jobsFixture))
        vm.select("Nonexistent")
        #expect(vm.filteredJobs.isEmpty)
    }

    @Test func pureFilterMatchesInstanceBehavior() {
        let jobs = AppContent.jobsFixture.jobs
        #expect(JobsViewModel.apply(filter: "All", to: jobs).count == 4)
        #expect(JobsViewModel.apply(filter: "Tech", to: jobs).map(\.id) == [2])
        #expect(JobsViewModel.apply(filter: "Remote", to: jobs).map(\.id) == [4])
    }

    // MARK: - Avatar color mapping

    @Test func mapsCategoriesToAvatarColors() {
        #expect(JobsViewModel.avatarColorHex(forCategory: "Design") == Theme.Color.accentGreenHex)
        #expect(JobsViewModel.avatarColorHex(forCategory: "Tech") == JobsViewModel.accentSkyHex)
        #expect(JobsViewModel.avatarColorHex(forCategory: "Hospitality") == Theme.Color.primaryTerracottaHex)
        #expect(JobsViewModel.avatarColorHex(forCategory: "Remote") == Theme.Color.accentPlumHex)
    }

    @Test func mapsUnknownCategoryToInkAvatarColor() {
        #expect(JobsViewModel.avatarColorHex(forCategory: "totally-unknown") == Theme.Color.textInkHex)
    }

    // MARK: - Failure path

    @Test func degradesGracefullyWhenLoadingFails() {
        let vm = JobsViewModel(contentLoader: FailingLoader())
        #expect(vm.jobs.isEmpty)
        #expect(vm.filteredJobs.isEmpty)
        // Header still renders sensible copy and a usable filter.
        #expect(vm.screen.title == "Find a job")
        #expect(vm.selectedFilter == "All")
    }
}

// MARK: - Fixture

private extension AppContent {
    /// Content matching `db.json` for the fields the Jobs screen renders.
    static let jobsFixture = AppContent(
        home: Home(
            weather: Weather(day: "Saturday", temperature: 18, unit: "C", condition: "Sunny", label: ""),
            greeting: "Welcome to", city: "Melbourne", tagline: "",
            searchPlaceholder: "", exploreTitle: "", exploreCount: "", featuredTitle: ""
        ),
        guides: [],
        featured: [],
        coffeeScreen: CategoryScreen(eyebrow: "e", title: "Coffee", subtitle: "s", filters: []),
        cafes: [],
        jobsScreen: CategoryScreen(
            eyebrow: "WORK IN MELBOURNE",
            title: "Find a job",
            subtitle: "340 roles hiring across the city right now.",
            filters: ["All", "Design", "Tech", "Hospitality", "Remote"]
        ),
        jobs: [
            Job(id: 1, title: "Senior Product Designer", company: "Canva", suburb: "Cremorne", avatar: "C", salary: "$130–160k", employment: "Full-time", location: "Hybrid", category: "Design"),
            Job(id: 2, title: "Frontend Engineer", company: "REA Group", suburb: "Richmond", avatar: "R", salary: "$120–150k", employment: "Full-time", location: "Hybrid", category: "Tech"),
            Job(id: 3, title: "Head Barista", company: "Proud Mary", suburb: "Collingwood", avatar: "P", salary: "$34 / hr", employment: "Part-time", location: "On-site", category: "Hospitality"),
            Job(id: 4, title: "Marketing Lead", company: "Who Gives A Crap", suburb: "Fitzroy", avatar: "W", salary: "$115–140k", employment: "Full-time", location: "Remote", category: "Remote"),
        ],
        meetupsScreen: CategoryScreen(eyebrow: "e", title: "Meetups", subtitle: "s", filters: []),
        groups: [],
        recordsScreen: CategoryScreen(eyebrow: "e", title: "Records", subtitle: "s", filters: []),
        records: [],
        nav: []
    )
}
