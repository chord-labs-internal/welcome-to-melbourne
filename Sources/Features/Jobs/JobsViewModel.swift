import SwiftUI
import Observation

// MARK: - JobsViewModel

/// Drives the Jobs guide screen (`Screen / Find a Job`).
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes exactly what the view renders:
/// the ``CategoryScreen`` header, the full ``Job`` list, the selected filter, and
/// the derived filtered list. Filtering and the category → avatar-color mapping
/// live here (not in the view) so they are unit-testable without a running UI.
/// If loading fails, it degrades to sensible empty content so the screen never
/// crashes.
@MainActor
@Observable
final class JobsViewModel {
    /// The Jobs header copy + filter chip titles.
    private(set) var screen: CategoryScreen
    /// Every job from `db.json`.
    private(set) var jobs: [Job]
    /// The currently selected filter chip. Defaults to the first chip ("All").
    var selectedFilter: String

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        let screen: CategoryScreen
        let jobs: [Job]
        if let content = try? contentLoader.load() {
            screen = content.jobsScreen
            jobs = content.jobs
        } else {
            screen = Self.fallbackScreen
            jobs = []
        }
        self.screen = screen
        self.jobs = jobs
        self.selectedFilter = screen.filters.first ?? Self.allFilter
    }

    // MARK: - Derived state

    /// The filter chip titles to render.
    var filters: [String] { screen.filters }

    /// The jobs matching the current filter selection.
    var filteredJobs: [Job] { Self.apply(filter: selectedFilter, to: jobs) }

    /// Select a filter chip.
    func select(_ filter: String) { selectedFilter = filter }

    // MARK: - Filtering (pure)

    /// The "show everything" chip title. `nonisolated` so the pure filter can
    /// reference it off the main actor.
    nonisolated static let allFilter = "All"

    /// Pure filter: `All` returns every job; any other chip matches a job's
    /// `category` exactly. Kept `nonisolated` + `static` so it is unit-testable
    /// without a UI or an instance.
    nonisolated static func apply(filter: String, to jobs: [Job]) -> [Job] {
        guard filter != allFilter else { return jobs }
        return jobs.filter { $0.category == filter }
    }

    // MARK: - Avatar color (pure)

    /// The `accent/sky` avatar color used for Tech roles — the one avatar color in
    /// the Figma file that isn't a semantic ``Theme`` token. `nonisolated` so the
    /// pure color mapping can reference it off the main actor.
    nonisolated static let accentSkyHex = "#7ba7bc"

    /// Resolves the monogram-avatar background hex for a job `category`, keyed to
    /// the Figma colors. Unknown categories fall back to ink so an avatar is never
    /// blank. Matching is case-sensitive to the `db.json` category keys.
    nonisolated static func avatarColorHex(forCategory category: String) -> String {
        switch category {
        case "Design": return Theme.Color.accentGreenHex
        case "Tech": return accentSkyHex
        case "Hospitality": return Theme.Color.primaryTerracottaHex
        case "Remote": return Theme.Color.accentPlumHex
        default: return Theme.Color.textInkHex
        }
    }

    /// The monogram-avatar background ``Color`` for a job `category`.
    nonisolated static func avatarColor(forCategory category: String) -> Color {
        Color(hex: avatarColorHex(forCategory: category))
    }

    // MARK: - Fallback

    /// Empty-state header used when content fails to load, so the screen still
    /// renders sensible copy rather than a blank page.
    static let fallbackScreen = CategoryScreen(
        eyebrow: "WORK IN MELBOURNE",
        title: "Find a job",
        subtitle: "",
        filters: [allFilter]
    )
}
