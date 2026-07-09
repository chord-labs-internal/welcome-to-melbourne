import SwiftUI

// MARK: - MeetupsView

/// The Meetups guide screen (Figma frame `Screen / Meetup Groups`): a glass nav
/// row, the "MEET YOUR PEOPLE" header, a horizontal filter row, and a column of
/// group cards — all driven by ``GroupsViewModel`` and scrolling on the cream
/// background under the floating Liquid Glass tab bar.
struct MeetupsView: View {
    @State private var viewModel: GroupsViewModel

    init(viewModel: GroupsViewModel = GroupsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.section) {
                NavRow()
                MeetupsHeader(screen: viewModel.screen)
                FilterRow(
                    filters: viewModel.filters,
                    selected: viewModel.selectedFilter,
                    onSelect: { viewModel.selectedFilter = $0 }
                )
                GroupList(viewModel: viewModel)
            }
            .padding(.top, Theme.Spacing.small)
            // Clear the floating tab bar so the last card isn't obscured.
            .padding(.bottom, 96)
        }
        .background(Theme.Color.cream)
        .scrollIndicators(.hidden)
    }
}

// MARK: - NavRow

/// The top nav row: a glass back button on the left and a glass filter button on
/// the right. Decorative on a tab-hosted screen (there's no navigation stack to
/// pop), but carries stable identifiers so UI tests can find them.
private struct NavRow: View {
    var body: some View {
        HStack {
            GlassCircleButton(systemName: "chevron.left", identifier: "meetups.back")
            Spacer(minLength: 0)
            GlassCircleButton(systemName: "line.3.horizontal.decrease", identifier: "meetups.filter")
        }
        .padding(.horizontal, Theme.Spacing.screen - 8)
    }
}

/// A 40×40 translucent Liquid Glass circular icon button.
private struct GlassCircleButton: View {
    let systemName: String
    let identifier: String

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Color.ink)
                .frame(width: IconBadge.headerButtonSize, height: IconBadge.headerButtonSize)
                .background(.ultraThinMaterial, in: .circle)
                .overlay {
                    Circle().strokeBorder(Theme.Color.surfaceWhite.opacity(0.6), lineWidth: 1)
                }
                .shadow(color: Theme.Color.ink.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - MeetupsHeader

/// The header block: plum eyebrow, big serif "Meetups" title, muted subtitle.
private struct MeetupsHeader: View {
    let screen: CategoryScreen

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(screen.eyebrow)
                .font(Theme.Typography.eyebrow)
                .textCase(.uppercase)
                .tracking(0.9)
                .foregroundStyle(Theme.Color.plum)

            Text(screen.title)
                .font(Theme.Typography.heroTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("meetups.title")

            Text(screen.subtitle)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.muted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Theme.Spacing.xSmall)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screen)
    }
}

// MARK: - FilterRow

/// The horizontal filter chip row. Reuses the shared ``FilterChip`` so styling
/// and identifiers (`chip.<title>`) stay consistent across category screens.
private struct FilterRow: View {
    let filters: [String]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Theme.Spacing.small) {
                ForEach(filters, id: \.self) { title in
                    FilterChip(title: title, isSelected: title == selected) {
                        onSelect(title)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screen)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier("meetups.filters")
    }
}

// MARK: - GroupList

/// The vertical column of group cards for the selected filter.
private struct GroupList: View {
    let viewModel: GroupsViewModel

    var body: some View {
        LazyVStack(spacing: Theme.Spacing.cardPadding) {
            ForEach(viewModel.filteredGroups) { group in
                GroupCard(
                    group: group,
                    accent: viewModel.accentColor(for: group),
                    symbolName: viewModel.symbolName(for: group)
                )
            }
        }
        .padding(.horizontal, Theme.Spacing.screen - 8)
    }
}

// MARK: - GroupCard

/// A single group card: accent icon tile + name + `category · suburb`, a
/// description line, then a footer with overlapping member avatars + members
/// label on the left and an accent next-meet pill on the right.
private struct GroupCard: View {
    let group: Group
    let accent: Color
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            HStack(spacing: 13) {
                IconTile(systemName: symbolName, accent: accent)
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.name)
                        .font(Theme.Typography.cardTitle)
                        .foregroundStyle(Theme.Color.ink)
                        .lineLimit(1)
                    Text("\(group.category) · \(group.suburb)")
                        .font(Theme.Typography.countLabel)
                        .foregroundStyle(Theme.Color.muted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            Text(group.description)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Color.body)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Theme.Spacing.small) {
                MemberAvatars()
                Text(group.membersLabel)
                    .font(Theme.Typography.countLabel)
                    .foregroundStyle(Theme.Color.body)
                Spacer(minLength: Theme.Spacing.small)
                NextMeetPill(text: group.nextMeet, accent: accent)
            }
        }
        .padding(.horizontal, Theme.Spacing.cardPadding)
        .padding(.top, Theme.Spacing.cardPadding)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Color.surfaceWhite, in: .rect(cornerRadius: Theme.Radius.cardLarge))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.Radius.cardLarge)
                .strokeBorder(Theme.Color.borderSoft, lineWidth: 1.5)
        }
        .shadow(color: Color(hex: "#5c331f").opacity(0.06), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("group.\(group.id)")
    }
}

// MARK: - IconTile

/// The 52×52 rounded-square accent tile holding the group's SF Symbol.
private struct IconTile: View {
    let systemName: String
    let accent: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(Theme.Color.onColor)
            .frame(width: 52, height: 52)
            .background(accent, in: .rect(cornerRadius: Theme.Radius.small))
    }
}

// MARK: - MemberAvatars

/// A cluster of overlapping placeholder member avatars. Uses fixed themed tints
/// (no network) so the layout renders immediately and UI tests never wait.
private struct MemberAvatars: View {
    /// Placeholder avatar tints, in draw order.
    private static let tints: [Color] = [
        Theme.Color.gold,
        Theme.Color.plum,
        Theme.Color.green,
    ]

    private let diameter: CGFloat = 26
    private let overlap: CGFloat = 9

    var body: some View {
        HStack(spacing: -overlap) {
            ForEach(Array(Self.tints.enumerated()), id: \.offset) { _, tint in
                Circle()
                    .fill(tint)
                    .frame(width: diameter, height: diameter)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.Color.onColor.opacity(0.9))
                    }
                    .overlay {
                        Circle().strokeBorder(Theme.Color.surfaceWhite, lineWidth: 2)
                    }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - NextMeetPill

/// The next-meet time pill: a small accent dot + time text on an accent-tinted
/// capsule.
private struct NextMeetPill: View {
    let text: String
    let accent: Color

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(accent)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(accent)
                .lineLimit(1)
        }
        .padding(.leading, 11)
        .padding(.trailing, 12)
        .padding(.vertical, 7)
        .background(accent.opacity(0.12), in: .rect(cornerRadius: 11))
    }
}

#Preview {
    MeetupsView()
}
