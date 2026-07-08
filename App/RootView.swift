import SwiftUI

/// Placeholder root view for the initial project scaffold (issue #1).
/// Real screens (Home, Coffee, Jobs, Meetups, Records) land in later issues.
struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome to")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Melbourne")
                .font(.largeTitle.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("root.placeholder")
    }
}

#Preview {
    RootView()
}
