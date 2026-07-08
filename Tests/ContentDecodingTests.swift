import Foundation
import Testing
@testable import WelcomeToMelbourne

/// Decoding tests for the `db.json` content layer.
///
/// `db.json` is bundled as a resource of the **app** target, so at runtime it
/// lives in the app host bundle rather than the test bundle. We locate the
/// bundle that actually contains it (searching `.main` + all loaded bundles)
/// and drive both the raw `decode(from:)` entry point and the real
/// `BundleContentLoader.load()` bundle-lookup path through it.
struct ContentDecodingTests {

    /// The bundle that carries `db.json` at runtime, plus the raw data.
    private static func locateDB() throws -> (bundle: Bundle, data: Data) {
        let candidates = [Bundle.main] + Bundle.allBundles + Bundle.allFrameworks
        for bundle in candidates {
            if let url = bundle.url(forResource: "db", withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                return (bundle, data)
            }
        }
        Issue.record("Could not locate db.json in any available bundle")
        throw ContentLoadingError.resourceNotFound(resource: "db", ext: "json")
    }

    // MARK: - Whole-file decode

    @Test func fullDatabaseDecodesWithoutThrowing() throws {
        let (_, data) = try Self.locateDB()
        // Should not throw.
        _ = try BundleContentLoader.decode(from: data)
    }

    @Test func bundleContentLoaderLoadsFromLocatedBundle() throws {
        let (bundle, _) = try Self.locateDB()
        let loader = BundleContentLoader(bundle: bundle)
        let content = try loader.load()
        #expect(content.home.city == "Melbourne")
    }

    // MARK: - Spot-check concrete values

    @Test func homeDecodesExpectedValues() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        #expect(content.home.city == "Melbourne")
        #expect(content.home.greeting == "Welcome to")
        #expect(content.home.weather.temperature == 18)
        #expect(content.home.weather.unit == "C")
    }

    @Test func guidesHaveFourExpectedSlugs() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        #expect(content.guides.count == 4)
        #expect(content.guides.map(\.slug) == ["coffee", "jobs", "meetups", "records"])
    }

    @Test func navHasFiveItemsWithHomeActive() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        #expect(content.nav.count == 5)
        let home = content.nav.first { $0.label == "Home" }
        #expect(home?.active == true)
        // Only Home is active.
        #expect(content.nav.filter(\.active).count == 1)
    }

    @Test func featuredContainsKnownItemWithTypeVaryingFields() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        let patricia = content.featured.first { $0.title == "Patricia Coffee Brewers" }
        #expect(patricia != nil)
        #expect(patricia?.type == "coffee")
        #expect(patricia?.rating == 4.9)
        #expect(patricia?.salary == nil)

        // A job entry carries salary but no rating.
        let job = content.featured.first { $0.type == "job" }
        #expect(job?.salary == "$120k")
        #expect(job?.rating == nil)
    }

    @Test func categoryListsAreNonEmpty() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        #expect(!content.cafes.isEmpty)
        #expect(!content.jobs.isEmpty)
        #expect(!content.groups.isEmpty)
        #expect(!content.records.isEmpty)
    }

    @Test func categoryScreensDecodeFilters() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        #expect(content.coffeeScreen.title == "Coffee")
        #expect(content.coffeeScreen.filters.first == "All")
        #expect(content.jobsScreen.filters.contains("Remote"))
        #expect(content.meetupsScreen.eyebrow == "MEET YOUR PEOPLE")
        #expect(content.recordsScreen.filters.contains("Vinyl"))
    }

    @Test func cafeTagsAreStringAndCategoriesAreArray() throws {
        let (_, data) = try Self.locateDB()
        let content = try BundleContentLoader.decode(from: data)

        let patricia = content.cafes.first { $0.name == "Patricia Coffee Brewers" }
        #expect(patricia?.tags == "Espresso · Standing room")
        #expect(patricia?.categories == ["Espresso"])
        #expect(patricia?.rating == 4.9)
    }

    // MARK: - Error path

    @Test func decodeThrowsOnMalformedJSON() {
        let bad = Data("{ not valid content }".utf8)
        #expect(throws: ContentLoadingError.self) {
            try BundleContentLoader.decode(from: bad)
        }
    }
}
