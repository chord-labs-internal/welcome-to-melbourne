import SwiftUI

// MARK: - RootTabView

/// The app's root navigation shell: an iOS 26 Liquid Glass floating `TabView`
/// driven by ``RootViewModel``.
///
/// Each tab hosts a screen resolved by route. The Home tab shows the real
/// ``HomeView`` (issue #6); the category tabs show lightweight placeholders
/// (``CategoryPlaceholderView``) filled out in issues #7–#10.
struct RootTabView: View {
    @State private var viewModel: RootViewModel
    @State private var selectedRoute: String

    init(viewModel: RootViewModel = RootViewModel()) {
        _viewModel = State(initialValue: viewModel)
        _selectedRoute = State(initialValue: viewModel.tabs.first?.route ?? "/")
    }

    var body: some View {
        TabView(selection: $selectedRoute) {
            ForEach(viewModel.tabs) { tab in
                Tab(tab.label, systemImage: tab.systemImage, value: tab.route) {
                    screen(for: tab)
                }
                .accessibilityIdentifier(tab.accessibilityIdentifier)
            }
        }
        .tint(Theme.Color.terracotta)
    }

    /// Resolves the destination screen for a tab by its route.
    @ViewBuilder
    private func screen(for tab: RootTab) -> some View {
        switch tab.route {
        case "/":
            HomeView()
        case "/coffee":
            CoffeeView()
        case "/jobs":
            JobsView()
        case "/groups":
            MeetupsView()
        case "/records":
            RecordsView()
        default:
            CategoryPlaceholderView(title: tab.label, identifier: "screen.\(tab.label.lowercased())")
        }
    }
}

// MARK: - CategoryPlaceholderView

/// Lightweight placeholder for a category tab (Coffee, Jobs, Groups, Records).
///
/// Shows just the category title; the full screens land in issues #7–#10.
struct CategoryPlaceholderView: View {
    let title: String
    /// Stable identifier applied to the title text so UI tests can confirm
    /// navigation to this screen, e.g. `"screen.coffee"`.
    let identifier: String

    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text(title)
                .font(Theme.Typography.sectionTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("\(identifier).title")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.cream)
    }
}

#Preview {
    RootTabView()
}
