import SwiftUI
import Observation

// MARK: - RecordsViewModel

/// Drives the Records guide screen (Figma frame `Screen / Record Stores`).
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes exactly what the view renders:
/// the ``CategoryScreen`` header copy, the full ``Record`` store list, the
/// current `selectedFilter`, and the derived ``filteredRecords``. Filtering is a
/// pure function of the selection and the store `categories`, kept here (not in
/// the view) so it is unit-testable without a running UI. If loading fails, it
/// degrades to sensible empty content so the screen never crashes.
@MainActor
@Observable
final class RecordsViewModel {
    /// The eyebrow / title / subtitle + filter chips for the screen.
    private(set) var screen: CategoryScreen
    /// Every record store, in content order.
    private(set) var records: [Record]
    /// The currently selected filter chip. Defaults to the first filter ("All").
    var selectedFilter: String

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        let content = try? contentLoader.load()
        let screen = content?.recordsScreen ?? Self.fallbackScreen
        self.screen = screen
        self.records = content?.records ?? []
        self.selectedFilter = screen.filters.first ?? Self.allFilter
    }

    // MARK: - Filtering

    /// The stores matching the current selection.
    ///
    /// The "All" chip (the first filter) returns every store; any other chip
    /// returns the stores whose `categories` contain that chip's exact title.
    var filteredRecords: [Record] {
        Self.filter(records, by: selectedFilter, allFilter: allFilter)
    }

    /// The label treated as "show everything" — the first filter, or "All".
    var allFilter: String { screen.filters.first ?? Self.allFilter }

    /// Pure filtering used by ``filteredRecords`` and unit tests.
    ///
    /// Returns all `records` when `filter` equals `allFilter`; otherwise the
    /// records whose `categories` contain `filter`.
    nonisolated static func filter(
        _ records: [Record],
        by filter: String,
        allFilter: String = allFilter
    ) -> [Record] {
        guard filter != allFilter else { return records }
        return records.filter { $0.categories.contains(filter) }
    }

    // MARK: - Formatting

    /// The rating value formatted to a single decimal place, e.g. `4.8`.
    /// Pure and `nonisolated` so it is unit-testable off the main actor.
    nonisolated static func formattedRating(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }

    // MARK: - Fallback

    /// The default "All" label used when content is unavailable.
    nonisolated static let allFilter = "All"

    /// Sensible empty-state header used when content fails to load, so the
    /// screen still renders its title rather than a blank view.
    static let fallbackScreen = CategoryScreen(
        eyebrow: "CRATE DIGGING",
        title: "Records",
        subtitle: "",
        filters: [allFilter]
    )
}
