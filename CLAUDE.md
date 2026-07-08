# Welcome to Melbourne

A native iOS city-guide app for Melbourne — your local guide to coffee, jobs, meetups, and record stores across the world's most liveable city.

## Design

The source of truth for all UI is the Figma file. Always reference it before building or changing any screen, and match its layout, spacing, typography, and color exactly.

**Figma:** https://www.figma.com/design/6sT0G7JYBWVjZRKmfP0djD/Welcome-to-Melbourne?m=auto&t=eOaFuiU8vaXyKxm4-6

- Use the Figma MCP tools (`get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`) to pull layout, tokens, and assets straight from the file rather than eyeballing.
- Prefer the `figma-swiftui` skill when translating a Figma frame into SwiftUI.
- Extract design tokens (colors, type ramp, spacing) into a shared source so screens stay consistent with the file.

## Platform

- **Minimum deployment target: iOS 26.** Do not add availability fallbacks or compatibility shims for earlier iOS versions — target iOS 26 APIs directly.
- SwiftUI-first. Use the latest iOS 26 SwiftUI APIs and the current Liquid Glass design language where the Figma calls for it.

## Content model

App content is defined in `db.json` at the repo root. It describes:

- `home` — greeting, weather label, search placeholder, section titles
- `guides` — the four explore categories (Coffee, Jobs, Meetups, Records)
- `featured` — the "Featured this week" carousel
- `cafes`, `jobs`, `groups`, `records` — list data per category screen, each with its own `*Screen` header + filter chips
- `nav` — the bottom tab bar (Home, Coffee, Jobs, Groups, Records)

Model these as `Codable` Swift types that decode from `db.json`. Keep the JSON as the seed/content source so screens stay data-driven and easy to test.

## Architecture principles

**Features must be testable.** This is a hard requirement, not a nice-to-have.

- Keep view logic out of views. Put state, formatting, and data loading in observable view models (or plain value types) that can be unit-tested without a running UI.
- Inject dependencies (content loading, networking, clock/weather) behind protocols so they can be faked in tests. No singletons reached for directly inside features.
- Every feature ships with tests:
  - **Unit tests** for view models, decoding of `db.json`, filtering, and formatting logic.
  - **UI tests** (XCUITest) for the key user flows on each screen — browse a guide, apply a filter, open a detail.
  - Give interactive elements stable `accessibilityIdentifier`s so UI tests can target them reliably.
- A feature isn't done until its tests pass.

## Build, run & test — use XcodeBuildMCP

Always drive builds, simulator runs, and tests through the **XcodeBuildMCP** tools rather than shelling out to raw `xcodebuild` by hand. It gives structured build output, simulator control, and test results.

Typical loop:

1. Discover the project/scheme (list projects/schemes).
2. Build for an iOS 26 simulator.
3. Boot the simulator and install/launch the app.
4. Run the unit + UI test suites and read structured results.
5. Capture a screenshot to visually verify against the Figma frame.

When a build or test fails, read the structured diagnostics from XcodeBuildMCP and fix the root cause before moving on.

## Definition of done for any feature

1. Matches the Figma design (verified with a simulator screenshot).
2. Runs on an iOS 26 simulator via XcodeBuildMCP.
3. Data-driven from `db.json` where applicable.
4. Covered by passing unit and UI tests.
