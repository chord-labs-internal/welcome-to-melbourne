import SwiftUI

// MARK: - RecordsView

/// The Records guide screen: a fixed nav row, then a scrolling header, filter
/// chip row, and a stack of record-store cards — all driven by
/// ``RecordsViewModel`` on the cream background under the floating tab bar.
struct RecordsView: View {
    @State private var viewModel: RecordsViewModel

    init(viewModel: RecordsViewModel = RecordsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavRow()
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                    Header(screen: viewModel.screen)
                    FilterRow(
                        filters: viewModel.screen.filters,
                        selected: viewModel.selectedFilter,
                        onSelect: { viewModel.selectedFilter = $0 }
                    )
                    StoreList(
                        records: viewModel.filteredRecords,
                        placeholderTint: RecordsView.albumTint
                    )
                }
                .padding(.top, Theme.Spacing.medium)
                // Clear the floating tab bar so the last card isn't obscured.
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.Color.cream)
        .accessibilityIdentifier("screen.records")
    }

    /// Themed placeholder tint for album art, so the layout (and UI tests) never
    /// wait on the network. Uses the Records guide accent.
    static let albumTint = Theme.GuideColor.records
}

// MARK: - NavRow

/// The top nav row: a circular back button on the left and a filter button on
/// the right, matching the Figma header.
private struct NavRow: View {
    var body: some View {
        HStack {
            CircleIconButton(systemName: "chevron.left", identifier: "records.nav.back")
            Spacer()
            CircleIconButton(systemName: "line.3.horizontal.decrease", identifier: "records.nav.filter")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, Theme.Spacing.small)
    }
}

/// A circular white icon button used in the nav row.
private struct CircleIconButton: View {
    let systemName: String
    let identifier: String

    var body: some View {
        Button {} label: {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Color.ink)
                .frame(width: IconBadge.headerButtonSize, height: IconBadge.headerButtonSize)
                .background(Theme.Color.surfaceWhite, in: .circle)
                .overlay { Circle().strokeBorder(Theme.Color.borderSoft, lineWidth: 1) }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - Header

/// The eyebrow / title / subtitle block from `recordsScreen`.
private struct Header: View {
    let screen: CategoryScreen

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(screen.eyebrow)
                .font(Theme.Typography.eyebrow)
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Theme.Color.terracotta)
                .padding(.bottom, Theme.Spacing.xSmall)

            Text(screen.title)
                .font(Theme.Typography.heroTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("records.title")

            Text(screen.subtitle)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.muted)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.xSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screen)
    }
}

// MARK: - FilterRow

/// The horizontally-scrolling filter chip row, reusing the shared ``FilterChip``.
private struct FilterRow: View {
    let filters: [String]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(filters, id: \.self) { filter in
                    FilterChip(title: filter, isSelected: filter == selected) {
                        onSelect(filter)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - StoreList

/// The vertical stack of store cards for the current filter.
private struct StoreList: View {
    let records: [Record]
    let placeholderTint: Color

    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ForEach(records) { record in
                StoreCard(record: record, placeholderTint: placeholderTint)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - StoreCard

/// A single record-store card: album art, name, `★ rating · suburb`, genres,
/// and a trailing action icon on the standard card surface.
private struct StoreCard: View {
    let record: Record
    let placeholderTint: Color

    var body: some View {
        HStack(spacing: 14) {
            albumArt
            VStack(alignment: .leading, spacing: 5) {
                Text(record.name)
                    .font(Theme.Typography.cardTitle)
                    .foregroundStyle(Theme.Color.ink)
                    .lineLimit(1)
                RatingLine(rating: record.rating, suburb: record.suburb)
                Text(record.genres)
                    .font(Theme.Typography.countLabel)
                    .foregroundStyle(Theme.Color.muted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "heart")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Theme.Color.muted)
                .accessibilityHidden(true)
        }
        .padding(.leading, 14)
        .padding(.trailing, Theme.Spacing.cardPadding)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(cornerRadius: Theme.Radius.cardLarge)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("record.\(record.id)")
    }

    /// The 60pt rounded album-art tile. Uses a themed colored placeholder that
    /// renders immediately so the layout (and UI tests) never wait on the network.
    private var albumArt: some View {
        AsyncImage(url: URL(string: record.image)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            placeholderTint.opacity(0.22)
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small))
    }
}

// MARK: - RatingLine

/// The `★ rating · suburb` line: a gold star, the formatted rating in ink, then
/// the suburb in muted text. Private to the Records feature.
private struct RatingLine: View {
    let rating: Double
    let suburb: String

    var body: some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundStyle(Theme.Color.gold)
            Text(RecordsViewModel.formattedRating(rating))
                .font(.system(size: Theme.Typography.countLabelSize, weight: .semibold))
                .foregroundStyle(Theme.Color.ink)
            Text("· \(suburb)")
                .font(Theme.Typography.countLabel)
                .foregroundStyle(Theme.Color.muted)
        }
    }
}

#Preview {
    RecordsView()
}
