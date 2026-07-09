import SwiftUI

// MARK: - CoffeeView

/// The Coffee guide screen (`Screen / Coffee Places`): a nav row, the
/// `BEST OF MELBOURNE` header, a scrolling filter-chip row, and the list of café
/// cards — all driven by ``CoffeeViewModel`` on the cream background under the
/// floating Liquid Glass tab bar.
struct CoffeeView: View {
    @State private var viewModel: CoffeeViewModel

    init(viewModel: CoffeeViewModel = CoffeeViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavRow()
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.cardPadding) {
                    Header(screen: viewModel.screen)
                    FilterRow(
                        filters: viewModel.filters,
                        isSelected: viewModel.isSelected,
                        onSelect: viewModel.select
                    )
                    CafeList(cafes: viewModel.filteredCafes)
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.Color.cream)
        .accessibilityIdentifier("screen.coffee")
    }
}

// MARK: - NavRow

/// The top nav row: a circular back button on the leading edge and a filter
/// button on the trailing edge, both in the Liquid Glass button treatment.
private struct NavRow: View {
    var onBack: () -> Void = {}
    var onFilter: () -> Void = {}

    var body: some View {
        HStack {
            NavIconButton(systemName: "chevron.left", identifier: "coffee.nav.back", action: onBack)
            Spacer(minLength: 0)
            NavIconButton(
                systemName: "line.3.horizontal.decrease",
                identifier: "coffee.nav.filter",
                action: onFilter
            )
        }
        .padding(.horizontal, Theme.Spacing.medium + Theme.Spacing.small)
        .padding(.top, Theme.Spacing.small)
        .padding(.bottom, Theme.Spacing.xSmall)
    }
}

/// A single circular nav button (40×40) with a white surface, soft border, and a
/// subtle shadow — the app's lightweight take on the Liquid Glass control.
private struct NavIconButton: View {
    let systemName: String
    let identifier: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Color.ink)
                .frame(width: IconBadge.headerButtonSize, height: IconBadge.headerButtonSize)
                .background(Theme.Color.surfaceWhite, in: .circle)
                .overlay {
                    Circle().strokeBorder(Theme.Color.borderSoft, lineWidth: 1)
                }
                .shadow(color: Theme.Color.ink.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - Header

/// The screen header: terracotta eyebrow, big serif title, and a muted subtitle.
private struct Header: View {
    let screen: CategoryScreen

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(screen.eyebrow)
                .font(Theme.Typography.eyebrow)
                .textCase(.uppercase)
                .tracking(0.88)
                .foregroundStyle(Theme.Color.terracotta)

            Text(screen.title)
                .font(Theme.Typography.heroTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("screen.coffee.title")

            Text(screen.subtitle)
                .font(Theme.Typography.countLabel)
                .foregroundStyle(Theme.Color.muted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screen)
        .padding(.top, Theme.Spacing.small)
    }
}

// MARK: - FilterRow

/// The horizontally scrolling row of filter chips, reusing the shared
/// ``FilterChip``. Selection is exclusive — the view model owns which is active.
private struct FilterRow: View {
    let filters: [String]
    let isSelected: (String) -> Bool
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(filters, id: \.self) { filter in
                    FilterChip(title: filter, isSelected: isSelected(filter)) {
                        onSelect(filter)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.vertical, Theme.Spacing.xSmall)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

// MARK: - CafeList

/// The vertical list of café cards. Shows a gentle empty state when a filter
/// matches nothing.
private struct CafeList: View {
    let cafes: [Cafe]

    var body: some View {
        LazyVStack(spacing: Theme.Spacing.medium) {
            if cafes.isEmpty {
                Text("No cafés match this filter yet.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Color.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, Theme.Spacing.section)
                    .accessibilityIdentifier("coffee.empty")
            } else {
                ForEach(cafes) { cafe in
                    CafeRow(cafe: cafe)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.medium + Theme.Spacing.small)
    }
}

// MARK: - CafeRow

/// A single café card: colored icon tile, name, `★ rating · suburb`, a tags line,
/// and a trailing price level with a bookmark/heart toggle.
private struct CafeRow: View {
    let cafe: Cafe
    @State private var isBookmarked = false

    private var tileColor: Color {
        CoffeeViewModel.tileColor(forCafeId: cafe.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            iconTile
            details
            Spacer(minLength: 0)
            trailing
        }
        .padding(.vertical, Theme.Spacing.medium)
        .padding(.leading, Theme.Spacing.medium)
        .padding(.trailing, Theme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.cardLarge)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cafe.\(cafe.id)")
    }

    /// The 64×64 colored icon tile with a white coffee-cup glyph.
    private var iconTile: some View {
        Image(systemName: "cup.and.saucer.fill")
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(Theme.Color.onColor)
            .frame(width: 64, height: 64)
            .background(tileColor, in: .rect(cornerRadius: 18))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(cafe.name)
                .font(Theme.Typography.cardTitle)
                .foregroundStyle(Theme.Color.ink)
                .lineLimit(1)

            RatingLabel(rating: cafe.rating, suburb: cafe.suburb)

            Text(cafe.tags)
                .font(Theme.Typography.countLabel)
                .foregroundStyle(Theme.Color.muted)
                .lineLimit(1)
        }
    }

    private var trailing: some View {
        VStack(alignment: .trailing, spacing: Theme.Spacing.small) {
            Text(cafe.priceLevel)
                .font(Theme.Typography.countLabel)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.Color.terracotta)

            Button {
                isBookmarked.toggle()
            } label: {
                Image(systemName: isBookmarked ? "heart.fill" : "heart")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(isBookmarked ? Theme.Color.terracotta : Theme.Color.muted)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark")
            .accessibilityIdentifier("cafe.\(cafe.id).bookmark")
        }
    }
}

// MARK: - RatingLabel

/// A compact `★ rating · suburb` row: a gold star, the rating in ink, and the
/// suburb in muted text.
private struct RatingLabel: View {
    let rating: Double
    let suburb: String

    var body: some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: "star.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.Color.gold)
            Text(Self.format(rating))
                .font(Theme.Typography.countLabel)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.Color.ink)
            Text("· \(suburb)")
                .font(Theme.Typography.countLabel)
                .foregroundStyle(Theme.Color.muted)
        }
    }

    /// Formats a rating to a single decimal place, e.g. `4.9`.
    static func format(_ rating: Double) -> String {
        String(format: "%.1f", rating)
    }
}

#Preview {
    CoffeeView()
}
