import SwiftUI
import Observation

// MARK: - GroupsViewModel

/// Drives the Meetups guide screen.
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes exactly what the view renders:
/// the ``CategoryScreen`` header copy, the full ``Group`` list, the filter chip
/// titles, the ``selectedFilter``, and the derived ``filteredGroups``.
///
/// Presentation values that the view needs but that are *not* in the data — the
/// per-card accent color and the SF Symbol for a group's icon tile — are derived
/// here (not in the view) so they stay unit-testable without a running UI. Per
/// the Figma frame the accent rotates by the group's position in the full list
/// (terracotta → green → plum → gold), independent of its category, so the color
/// stays stable for a given group even when the list is filtered.
///
/// If loading fails the view model degrades to empty content with sensible
/// fallback header copy so the screen never crashes.
@MainActor
@Observable
final class GroupsViewModel {
    /// The Meetups header copy + filter titles.
    private(set) var screen: CategoryScreen
    /// Every group, in `db.json` order.
    private(set) var groups: [Group]
    /// The currently selected filter chip title (defaults to the first filter).
    var selectedFilter: String

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        let resolvedScreen: CategoryScreen
        let resolvedGroups: [Group]
        if let content = try? contentLoader.load() {
            resolvedScreen = content.meetupsScreen
            resolvedGroups = content.groups
        } else {
            resolvedScreen = Self.fallbackScreen
            resolvedGroups = []
        }
        self.screen = resolvedScreen
        self.groups = resolvedGroups
        self.selectedFilter = resolvedScreen.filters.first ?? "All"
    }

    // MARK: - Derived content

    /// The filter chip titles, e.g. `["All", "Social", "Fitness", "Creative", "New here"]`.
    var filters: [String] { screen.filters }

    /// The groups matching the ``selectedFilter``.
    var filteredGroups: [Group] {
        Self.groups(groups, matching: selectedFilter)
    }

    // MARK: - Filtering

    /// Sentinel filter that returns every group.
    static let allFilter = "All"
    /// The newcomer filter chip title. It maps to the "New in Melbourne" group
    /// rather than to a `category` value (no group has category "New here").
    static let newHereFilter = "New here"

    /// Filters `groups` for a chip `filter`.
    ///
    /// - `All` returns everything.
    /// - `New here` returns the newcomer group(s) — matched on name via
    ///   ``isNewcomer(_:)`` because no group carries the category "New here".
    /// - Any other chip matches a group's `category` exactly.
    nonisolated static func groups(_ groups: [Group], matching filter: String) -> [Group] {
        switch filter {
        case allFilter:
            return groups
        case newHereFilter:
            return groups.filter(isNewcomer)
        default:
            return groups.filter { $0.category == filter }
        }
    }

    /// Whether a group is a "newcomers" group — the target of the `New here`
    /// chip. Matched on the group name containing "new" (e.g. "New in
    /// Melbourne"), since the newcomer group is categorised as `Social`, not
    /// "New here".
    nonisolated static func isNewcomer(_ group: Group) -> Bool {
        group.name.range(of: "new", options: .caseInsensitive) != nil
    }

    // MARK: - Per-card presentation

    /// The accent palette used for group cards, cycled by position: the icon
    /// tile fill, the next-meet pill tint, and the pill text/dot all draw from
    /// this. Mirrors the Figma frame (card 1 terracotta, 2 green, 3 plum, 4 gold).
    nonisolated static let accentPalette: [Color] = [
        Theme.Color.terracotta,
        Theme.Color.green,
        Theme.Color.plum,
        Theme.Color.gold,
    ]

    /// The SF Symbols cycled for the icon tile, in step with ``accentPalette``.
    nonisolated static let symbolCycle: [String] = [
        "cup.and.saucer.fill",
        "bolt.fill",
        "paintpalette.fill",
        "sparkles",
    ]

    /// The accent color for the group at `index` in the full list (wraps).
    nonisolated static func accentColor(forIndex index: Int) -> Color {
        accentPalette[wrapped(index, count: accentPalette.count)]
    }

    /// The icon-tile SF Symbol for the group at `index` in the full list (wraps).
    nonisolated static func symbolName(forIndex index: Int) -> String {
        symbolCycle[wrapped(index, count: symbolCycle.count)]
    }

    /// Non-negative modulo so negative indices still wrap into range.
    private nonisolated static func wrapped(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((index % count) + count) % count
    }

    /// The accent color for a specific `group`, resolved from its stable position
    /// in the full (unfiltered) list so it doesn't change when the list is filtered.
    func accentColor(for group: Group) -> Color {
        Self.accentColor(forIndex: index(of: group))
    }

    /// The icon-tile SF Symbol for a specific `group`, keyed on its stable
    /// position in the full (unfiltered) list.
    func symbolName(for group: Group) -> String {
        Self.symbolName(forIndex: index(of: group))
    }

    /// The group's index in the full list, or `0` if not found.
    private func index(of group: Group) -> Int {
        groups.firstIndex(of: group) ?? 0
    }

    // MARK: - Fallback

    /// Header copy shown when content fails to load, so the screen still renders
    /// text (and at least the "All" chip) rather than a blank view.
    static let fallbackScreen = CategoryScreen(
        eyebrow: "MEET YOUR PEOPLE",
        title: "Meetups",
        subtitle: "",
        filters: ["All"]
    )
}
