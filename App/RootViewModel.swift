import Foundation
import Observation

// MARK: - RootTab

/// A single tab in the root navigation shell, derived from `db.json` `nav` data.
///
/// Pure value type so it is trivially unit-testable without a running UI.
/// `route` doubles as the `TabView` selection tag, and `accessibilityIdentifier`
/// gives UI tests a stable handle on each tab.
struct RootTab: Identifiable, Hashable, Sendable {
    /// Human-readable label, e.g. `"Home"`, `"Coffee"`.
    let label: String
    /// SF Symbol name for the tab icon. The system fills the selected symbol.
    let systemImage: String
    /// The route from `db.json`, e.g. `"/"`, `"/coffee"`. Used as the selection tag.
    let route: String

    var id: String { route }

    /// Stable identifier for UI tests, e.g. `"tab.home"`, `"tab.coffee"`.
    var accessibilityIdentifier: String { "tab.\(label.lowercased())" }

    /// Maps a `db.json` `nav` icon string to an SF Symbol name.
    ///
    /// Unknown icons fall back to `"circle.circle"` so the UI never renders a
    /// blank tab.
    static func systemImage(forIcon icon: String) -> String {
        switch icon.lowercased() {
        case "home": return "house"
        case "coffee": return "cup.and.saucer"
        case "briefcase": return "briefcase"
        case "users": return "person.2"
        case "disc": return "opticaldisc"
        default: return "circle.circle"
        }
    }
}

// MARK: - RootViewModel

/// Drives the root tab navigation shell.
///
/// Loads ``AppContent`` through an injected ``ContentLoading`` dependency
/// (default ``BundleContentLoader``) and exposes the ordered tab list plus the
/// decoded content. If loading fails — or the `nav` array is empty — it falls
/// back to a built-in tab list so the UI never crashes.
@MainActor
@Observable
final class RootViewModel {
    /// The ordered tabs to render, one per `db.json` `nav` entry.
    private(set) var tabs: [RootTab]
    /// The decoded content, if it loaded. `nil` when the loader failed and the
    /// view model is running on the built-in fallback tabs.
    private(set) var content: AppContent?

    init(contentLoader: ContentLoading = BundleContentLoader()) {
        if let content = try? contentLoader.load() {
            self.content = content
            let mapped = content.nav.map {
                RootTab(
                    label: $0.label,
                    systemImage: RootTab.systemImage(forIcon: $0.icon),
                    route: $0.route
                )
            }
            self.tabs = mapped.isEmpty ? Self.defaultTabs : mapped
        } else {
            self.content = nil
            self.tabs = Self.defaultTabs
        }
    }

    /// Built-in tabs used when content fails to load. Mirrors the five known
    /// tabs so the shell is always navigable.
    static let defaultTabs: [RootTab] = [
        RootTab(label: "Home", systemImage: "house", route: "/"),
        RootTab(label: "Coffee", systemImage: "cup.and.saucer", route: "/coffee"),
        RootTab(label: "Jobs", systemImage: "briefcase", route: "/jobs"),
        RootTab(label: "Groups", systemImage: "person.2", route: "/groups"),
        RootTab(label: "Records", systemImage: "opticaldisc", route: "/records"),
    ]
}
