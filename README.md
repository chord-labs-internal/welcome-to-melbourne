# Welcome to Melbourne

A native iOS 26 city-guide app for Melbourne — coffee, jobs, meetups, and record stores.

## Project generation (XcodeGen)

The Xcode project is **not** checked in. `project.yml` is the source of truth; the
`.xcodeproj` is generated locally and git-ignored.

```bash
# one-time
brew install xcodegen

# generate WelcomeToMelbourne.xcodeproj from project.yml
xcodegen generate
```

Re-run `xcodegen generate` whenever you add/remove files or edit `project.yml`.

### Targets

| Target | Type | Notes |
| --- | --- | --- |
| `WelcomeToMelbourne` | app | SwiftUI lifecycle, iOS 26 deployment target, bundle id `com.chordlabs.welcometomelbourne` |
| `WelcomeToMelbourneTests` | unit tests | Swift Testing |
| `WelcomeToMelbourneUITests` | UI tests | XCUITest |

### Folder layout

```
App/            # @main entry point + root view
Sources/
  DesignSystem/ # tokens, styles (#2)
  Content/      # db.json models + loading (#3)
  Components/   # shared UI components (#4)
  Features/     # Home, Coffee, Jobs, Meetups, Records
Resources/      # bundled assets
Tests/          # unit tests
UITests/        # XCUITest flows
db.json         # content source of truth (bundled into the app target)
```

## Build / run / test (XcodeBuildMCP)

Drive builds, simulator runs, and tests through the **XcodeBuildMCP** tools (not raw
`xcodebuild`). Typical loop against an iOS 26 simulator:

1. Discover schemes — `list_schemes` on `WelcomeToMelbourne.xcodeproj`.
2. Build — `build_sim` with scheme `WelcomeToMelbourne`, an iOS 26 simulator (e.g.
   *iPhone 17 Pro*).
3. Boot + install + launch — `boot_sim`, `install_app_sim`, `launch_app_sim`
   (bundle id `com.chordlabs.welcometomelbourne`).
4. Test — `test_sim` for the unit + UI suites; read the structured results.
5. Screenshot — `screenshot` to verify against the Figma frame.

CLI equivalent for reference:

```bash
xcodegen generate
xcodebuild -project WelcomeToMelbourne.xcodeproj \
  -scheme WelcomeToMelbourne \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build test
```
