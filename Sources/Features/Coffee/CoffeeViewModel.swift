import SwiftUI
import Observation

// MARK: - CoffeeViewModel

/// Drives the Coffee guide screen (`Screen / Coffee Places`).
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes exactly what the view renders:
/// the ``CategoryScreen`` header copy + filter chips, and the ``Cafe`` list.
/// The selected filter and the derived, filtered café list live here — not in the
/// view — so filtering is unit-testable without a running UI. Selection is
/// exclusive: exactly one chip is active at a time. If loading fails, it degrades
/// to sensible empty content so the screen never crashes.
@MainActor
@Observable
final class CoffeeViewModel {
    /// Header copy (eyebrow / title / subtitle) and the filter titles.
    private(set) var screen: CategoryScreen
    /// The full café list from `db.json`, before filtering.
    private(set) var cafes: [Cafe]
    /// The currently active filter chip. Exactly one is selected at a time;
    /// defaults to the first filter (usually `"All"`).
    var selectedFilter: String

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        let resolved: CategoryScreen
        if let content = try? contentLoader.load() {
            resolved = content.coffeeScreen
            self.cafes = content.cafes
        } else {
            resolved = Self.fallbackScreen
            self.cafes = []
        }
        self.screen = resolved
        self.selectedFilter = resolved.filters.first ?? Self.allFilter
    }

    // MARK: - Derived presentation

    /// The filter chip titles to render, in order.
    var filters: [String] { screen.filters }

    /// The café list narrowed to the current selection.
    var filteredCafes: [Cafe] {
        Self.cafes(cafes, matching: selectedFilter)
    }

    /// Whether the given filter is the active one.
    func isSelected(_ filter: String) -> Bool {
        selectedFilter == filter
    }

    /// Selects a filter. Selection is exclusive — this replaces the active chip.
    func select(_ filter: String) {
        selectedFilter = filter
    }

    // MARK: - Filtering (pure, testable)

    /// The catch-all filter title that returns every café.
    nonisolated static let allFilter = "All"

    /// `true` when the filter is the catch-all "All" chip (case-insensitive).
    nonisolated static func isAll(_ filter: String) -> Bool {
        filter.caseInsensitiveCompare(allFilter) == .orderedSame
    }

    /// Filters `cafes` by a chip title.
    ///
    /// The "All" chip returns everything (order preserved); any other chip keeps
    /// only cafés whose `categories` contain that exact title.
    nonisolated static func cafes(_ cafes: [Cafe], matching filter: String) -> [Cafe] {
        guard !isAll(filter) else { return cafes }
        return cafes.filter { $0.categories.contains(filter) }
    }

    // MARK: - Tile colors

    /// The palette used for a café's leading icon tile, cycling through the brand
    /// accents (terracotta → green → gold → plum) so the list reads with rhythm,
    /// mirroring the Figma frame.
    nonisolated static let tilePalette: [Color] = [
        Theme.Color.terracotta,
        Theme.Color.green,
        Theme.Color.gold,
        Theme.Color.plum,
    ]

    /// The stable icon-tile color for a café, keyed on its `id` so a café keeps
    /// the same tile color regardless of which filter is applied.
    nonisolated static func tileColor(forCafeId id: Int) -> Color {
        let count = tilePalette.count
        let index = ((id - 1) % count + count) % count
        return tilePalette[index]
    }

    // MARK: - Fallback

    /// Empty-state header used when content fails to load, so the screen still
    /// renders its title rather than a blank view.
    static let fallbackScreen = CategoryScreen(
        eyebrow: "BEST OF MELBOURNE",
        title: "Coffee",
        subtitle: "",
        filters: [allFilter]
    )
}
