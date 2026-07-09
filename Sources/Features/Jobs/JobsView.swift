import SwiftUI

// MARK: - JobsView

/// The Jobs guide screen (`Screen / Find a Job`): a Liquid Glass nav row, the
/// "Find a job" header, a horizontally scrolling filter row, and a scrolling list
/// of job cards — all driven by ``JobsViewModel`` on the cream background under the
/// floating tab bar.
struct JobsView: View {
    @State private var viewModel: JobsViewModel

    init(viewModel: JobsViewModel = JobsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            NavRow()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    JobsHeader(screen: viewModel.screen)
                        .padding(.horizontal, Theme.Spacing.screen)
                        .padding(.top, Theme.Spacing.small)

                    FilterRow(
                        filters: viewModel.filters,
                        selected: viewModel.selectedFilter,
                        onSelect: { viewModel.select($0) }
                    )
                    .padding(.top, Theme.Spacing.cardPadding)

                    LazyVStack(spacing: Theme.Spacing.medium) {
                        ForEach(viewModel.filteredJobs) { job in
                            JobCard(job: job)
                        }
                    }
                    .padding(.horizontal, JobsHeader.cardMargin)
                    .padding(.top, Theme.Spacing.cardPadding)
                    // Clear the floating tab bar so the last card isn't obscured.
                    .padding(.bottom, 96)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.Color.cream)
    }
}

// MARK: - NavRow

/// The top navigation row: a back button and a filter button, each a 40pt Liquid
/// Glass circle, pinned above the scrolling content.
private struct NavRow: View {
    var body: some View {
        HStack {
            GlassIconButton(systemName: "chevron.left", identifier: "jobs.nav.back")
            Spacer(minLength: 0)
            GlassIconButton(systemName: "line.3.horizontal.decrease", identifier: "jobs.nav.filter")
        }
        .padding(.horizontal, 20)
        .padding(.top, Theme.Spacing.small)
        .padding(.bottom, Theme.Spacing.xSmall)
    }
}

/// A 40pt circular Liquid Glass icon button.
private struct GlassIconButton: View {
    let systemName: String
    let identifier: String

    var body: some View {
        Button {} label: {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Theme.Color.ink)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: .circle)
        .accessibilityIdentifier(identifier)
    }
}

// MARK: - JobsHeader

/// The header block: a green eyebrow, the big serif title, and a muted subtitle.
private struct JobsHeader: View {
    let screen: CategoryScreen

    /// Horizontal inset for the job cards (they sit slightly wider than the header
    /// text, matching the Figma frame).
    static let cardMargin: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(screen.eyebrow)
                .font(Theme.Typography.eyebrow)
                .textCase(.uppercase)
                .tracking(0.88)
                .foregroundStyle(Theme.Color.green)

            Text(screen.title)
                .font(Theme.Typography.heroTitle)
                .foregroundStyle(Theme.Color.ink)
                .accessibilityIdentifier("jobs.header.title")

            Text(screen.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Theme.Color.muted)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - FilterRow

/// The horizontally scrolling row of ``FilterChip``s.
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
            .padding(.vertical, Theme.Spacing.xSmall)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}

// MARK: - JobCard

/// A single job card: monogram avatar, title, `company · suburb`, a bookmark icon,
/// then a row of attribute pills (salary, employment, location).
private struct JobCard: View {
    let job: Job

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                HStack(spacing: 13) {
                    MonogramTile(
                        letter: job.avatar,
                        color: JobsViewModel.avatarColor(forCategory: job.category)
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(job.title)
                            .font(.system(size: 16.5, weight: .semibold, design: .serif))
                            .foregroundStyle(Theme.Color.ink)
                            .lineLimit(1)
                        Text("\(job.company)  ·  \(job.suburb)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.Color.muted)
                            .lineLimit(1)
                    }

                    Spacer(minLength: Theme.Spacing.small)

                    Image(systemName: "bookmark")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Theme.Color.muted)
                        .frame(width: 20, height: 20)
                }

                HStack(spacing: Theme.Spacing.small) {
                    AttributePill(job.salary, style: .accent(Theme.Color.green))
                    AttributePill(job.employment)
                    AttributePill(job.location)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.cardPadding)
            .cardSurface(cornerRadius: Theme.Radius.cardLarge)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("job.\(job.id)")
    }
}

// MARK: - MonogramTile

/// A 48pt rounded tile showing a single monogram letter on a solid color — the job
/// card avatar.
private struct MonogramTile: View {
    let letter: String
    let color: Color

    var body: some View {
        Text(letter)
            .font(.system(size: 20, weight: .semibold, design: .serif))
            .foregroundStyle(Theme.Color.onColor)
            .frame(width: 48, height: 48)
            .background(color, in: .rect(cornerRadius: 15))
            .accessibilityHidden(true)
    }
}

#Preview {
    JobsView()
}
