import SwiftUI
import Observation

// MARK: - HomeViewModel

/// Drives the Home screen.
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes exactly what the view renders:
/// the ``Home`` copy, the explore ``Guide`` list, and the ``FeaturedItem``
/// carousel. Derived presentation values — the guide → SF Symbol mapping and the
/// featured badge tint — live here (not in the view) so they are unit-testable
/// without a running UI. If loading fails, it degrades to sensible empty content
/// so the screen never crashes.
@MainActor
@Observable
final class HomeViewModel {
    /// The Home hero + section copy.
    private(set) var home: Home
    /// The four explore guides.
    private(set) var guides: [Guide]
    /// The "Featured this week" carousel entries.
    private(set) var featured: [FeaturedItem]

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        if let content = try? contentLoader.load() {
            self.home = content.home
            self.guides = content.guides
            self.featured = content.featured
        } else {
            self.home = Self.fallbackHome
            self.guides = []
            self.featured = []
        }
    }

    // MARK: - Derived hero values

    /// The terracotta eyebrow above the hero — the weather label (already uppercase).
    var eyebrow: String { home.weather.label }

    // MARK: - Guide presentation

    /// Resolves the SF Symbol for a guide from its slug (or `icon`) value.
    ///
    /// Accepts both the guide `slug` ("coffee"/"jobs"/"meetups"/"records") and the
    /// raw `icon` token from `db.json` ("coffee"/"briefcase"/"users"/"disc").
    /// Falls back to a neutral map pin for anything unknown so a card never renders
    /// a blank icon.
    nonisolated static func symbolName(forGuide key: String) -> String {
        switch key.lowercased() {
        case "coffee": return "cup.and.saucer"
        case "jobs", "briefcase": return "briefcase"
        case "meetups", "users": return "person.2"
        case "records", "disc": return "opticaldisc"
        default: return "mappin.and.ellipse"
        }
    }

    /// Convenience: the SF Symbol for a `Guide` value (keyed on its slug).
    nonisolated static func symbolName(for guide: Guide) -> String {
        symbolName(forGuide: guide.slug)
    }

    /// The solid card background for a guide: the themed guide color for its slug,
    /// falling back to the raw `color` hex from the data if the slug is unknown.
    nonisolated static func cardColor(for guide: Guide) -> Color {
        Theme.GuideColor.color(forSlug: guide.slug) ?? Color(hex: guide.color)
    }

    // MARK: - Featured presentation

    /// The badge tint for a featured card, keyed on its `type`.
    /// coffee → terracotta, job → green, record → plum; anything else → terracotta.
    nonisolated static func featuredTint(forType type: String) -> Color {
        switch type.lowercased() {
        case "coffee": return Theme.Color.terracotta
        case "job": return Theme.Color.green
        case "record": return Theme.Color.plum
        default: return Theme.Color.terracotta
        }
    }

    /// The badge tint for a `FeaturedItem`.
    nonisolated static func tint(for item: FeaturedItem) -> Color {
        featuredTint(forType: item.type)
    }

    // MARK: - Fallback

    /// Sensible empty-state copy used when content fails to load, so the hero still
    /// renders text rather than a blank screen.
    static let fallbackHome = Home(
        weather: Weather(day: "", temperature: 0, unit: "C", condition: "", label: ""),
        greeting: "Welcome to",
        city: "Melbourne",
        tagline: "",
        searchPlaceholder: "Search",
        exploreTitle: "Explore the city",
        exploreCount: "",
        featuredTitle: "Featured this week"
    )
}
