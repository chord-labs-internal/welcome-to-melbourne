import SwiftUI

// MARK: - HomeView

/// The Home screen: hero header, search pill, a 2×2 explore grid, and the
/// "Featured this week" carousel — all driven by ``HomeViewModel`` and scrolling
/// on the cream background under the floating Liquid Glass tab bar.
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                HeroHeader(home: viewModel.home)
                SearchField(placeholder: viewModel.home.searchPlaceholder)
                ExploreSection(
                    title: viewModel.home.exploreTitle,
                    count: viewModel.home.exploreCount,
                    guides: viewModel.guides
                )
                FeaturedSection(
                    title: viewModel.home.featuredTitle,
                    items: viewModel.featured
                )
            }
            .padding(.horizontal, Theme.Spacing.screen)
            .padding(.top, Theme.Spacing.medium)
            // Clear the floating tab bar so the last row isn't obscured.
            .padding(.bottom, 96)
        }
        .background(Theme.Color.cream)
        .scrollIndicators(.hidden)
    }
}

// MARK: - HeroHeader

/// The greeting block: terracotta weather eyebrow, serif "Welcome to", the big
/// serif "Melbourne" title, and a muted tagline.
private struct HeroHeader: View {
    let home: Home

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(home.weather.label)
                .font(Theme.Typography.eyebrow)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Theme.Color.terracotta)
                .padding(.bottom, Theme.Spacing.small)

            Text(home.greeting)
                .font(Theme.Typography.greeting)
                .foregroundStyle(Theme.Color.ink)

            Text(home.city)
                .font(Theme.Typography.heroTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("home.hero.title")

            Text(home.tagline)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.muted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.xSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - SearchField

/// A visual-only full-width search pill.
private struct SearchField: View {
    let placeholder: String

    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Color.terracotta)
            Text(placeholder)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.muted)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Spacing.cardPadding)
        .frame(height: 51)
        .background(Theme.Color.surfaceWhite, in: .capsule)
        .overlay {
            Capsule().strokeBorder(Theme.Color.borderSoft, lineWidth: 1)
        }
        .shadow(color: Theme.Color.ink.opacity(0.05), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("home.search")
    }
}

// MARK: - ExploreSection

/// Section header + the 2×2 grid of guide cards.
private struct ExploreSection: View {
    let title: String
    let count: String
    let guides: [Guide]

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.cardPadding) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(Theme.Typography.sectionTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .accessibilityIdentifier("home.explore.title")
                Spacer(minLength: Theme.Spacing.small)
                Text(count)
                    .font(Theme.Typography.countLabel)
                    .foregroundStyle(Theme.Color.muted)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(guides) { guide in
                    GuideCard(guide: guide)
                }
            }
        }
    }
}

// MARK: - GuideCard

/// A single explore card: solid guide color, an icon badge, serif title,
/// subtitle, and a count + arrow footer row.
private struct GuideCard: View {
    let guide: Guide
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                IconBadge(
                    systemName: HomeViewModel.symbolName(for: guide),
                    size: IconBadge.guideCardSize
                )

                Spacer(minLength: Theme.Spacing.medium)

                Text(guide.title)
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Color.onColor)

                Text(guide.subtitle)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Color.onColor.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                Spacer(minLength: Theme.Spacing.medium)

                HStack(spacing: Theme.Spacing.small) {
                    Text(guide.countLabel)
                        .font(Theme.Typography.countLabel)
                        .foregroundStyle(Theme.Color.onColor.opacity(0.9))
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Color.onColor)
                        .frame(width: 28, height: 28)
                        .background(Theme.Color.onColor.opacity(0.18), in: .circle)
                }
            }
            .padding(Theme.Spacing.cardPadding)
            .frame(height: 168, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                HomeViewModel.cardColor(for: guide),
                in: .rect(cornerRadius: Theme.Radius.cardLarge)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("guide.\(guide.slug)")
    }
}

// MARK: - FeaturedSection

/// Section header + a horizontal carousel of featured cards.
private struct FeaturedSection: View {
    let title: String
    let items: [FeaturedItem]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.cardPadding) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(Theme.Typography.sectionTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .accessibilityIdentifier("home.featured.title")
                Spacer(minLength: Theme.Spacing.small)
                Text("See all")
                    .font(Theme.Typography.countLabel)
                    .foregroundStyle(Theme.Color.terracotta)
            }

            ScrollView(.horizontal) {
                HStack(spacing: Theme.Spacing.cardPadding) {
                    ForEach(items) { item in
                        FeaturedCard(item: item)
                    }
                }
                .padding(.vertical, Theme.Spacing.small)
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }
}

// MARK: - FeaturedCard

/// A featured carousel card: image area with an overlaid badge, then title + meta
/// on the standard white card surface.
private struct FeaturedCard: View {
    let item: FeaturedItem

    private var tint: Color { HomeViewModel.tint(for: item) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageArea
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(item.title)
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .lineLimit(1)
                Text(item.meta)
                    .font(Theme.Typography.countLabel)
                    .foregroundStyle(Theme.Color.muted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.cardPadding)
        }
        .frame(width: 232)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .cardSurface()
        .accessibilityIdentifier("featured.\(item.id)")
    }

    /// The 112pt image area. Uses a themed colored placeholder that renders
    /// immediately, so the layout (and UI tests) never wait on the network.
    private var imageArea: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: item.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                tint.opacity(0.22)
            }
            .frame(height: 112)
            .frame(maxWidth: .infinity)
            .clipped()

            Badge(item.badge, tint: tint)
                .padding(Theme.Spacing.medium)
        }
    }
}

#Preview {
    HomeView()
}
