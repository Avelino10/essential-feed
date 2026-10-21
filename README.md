# EssentialFeed

An iOS feed application built with a modular, test-driven architecture that separates platform-agnostic business logic from UI and app composition. The project follows Clean Architecture principles, developed feature-by-feature using TDD, with strict boundaries between the core domain layer, the iOS presentation layer, and the composed application.

## Project structure

| Target | Description |
|---|---|
| `EssentialFeed` | Platform-agnostic core framework: feed and image comments domain models, API loading/mapping, caching, and presentation logic. No UIKit dependency. |
| `EssentialFeediOS` | UIKit-based UI layer (view controllers and views) for the feed and image comments features. |
| `EssentialApp` | The composed iOS application — wires together `EssentialFeed` and `EssentialFeediOS`, including navigation, remote/local loader composition with fallback and caching, and app lifecycle. |
| `Prototype` | Standalone UI prototype used for design exploration, independent of the production modules. |

Within `EssentialFeed`, code is organized by feature and layer, e.g.:

```
EssentialFeed/
├── Feed API                  # Remote feed loading + mapping
├── Feed Cache                # Local feed persistence
├── Feed Feature               # Core feed domain types/protocols
├── Feed Presentation           # Feed view models/presenters
├── Image Comments API
├── Image Comments Feature
├── Image Comments Presentation
├── Shared API
├── Shared API Infra
└── Shared Presentation
```

Test targets mirror this structure:

- `EssentialFeedTests` — unit tests for the core framework
- `EssentialFeediOSTests` — unit tests for the UI layer (snapshot + behavior tests)
- `EssentialFeedCacheIntegrationTests` — integration tests against real persistence
- `EssentialFeedAPIEndToEndTests` — end-to-end tests against the live remote API
- `EssentialAppTests` — tests for app-level composition (loader fallback, caching, navigation)

## Requirements

- Xcode 27 (Swift 5 language mode)
- iOS 18.0+
- macOS 15.0+ (for the framework's macOS test target)

The minimum OS versions follow an N-2 policy: the current major release plus the two before it.

## Getting started

Open the workspace (not the standalone project) to build and run the full app:

```
open EssentialApp.xcworkspace
```

Select the `EssentialApp` scheme and run on a simulator or device.

To work on the core framework in isolation, open `EssentialFeed.xcodeproj` directly.

## Running tests

Tests can be run from Xcode via **Product ▸ Test**, or from the command line using the same schemes as CI:

```bash
# Core framework (macOS)
xcodebuild test \
  -project EssentialFeed.xcodeproj \
  -scheme "CI_macOS" \
  -destination "platform=macOS" \
  -collect-test-diagnostics never

# Full app (iOS Simulator)
xcodebuild test \
  -workspace EssentialApp.xcworkspace \
  -scheme "CI_iOS" \
  -destination "platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0" \
  -collect-test-diagnostics never
```

`-collect-test-diagnostics never` stops xcodebuild from spending minutes collecting simulator diagnostics after a failing test.

Snapshot tests compare pixel-exact renders, so run them on **iPhone 18 Pro / iOS 27.0**, the simulator the reference images were recorded on. Rendering can differ between OS versions, so other simulators may fail the comparison.

## Continuous integration

Builds and tests run on GitHub Actions (see `.github/workflows/ci.yml`), running the `CI_macOS` and `CI_iOS` schemes on every push and pull request to `master`.

Both jobs run on the `xcode-27` runner with Xcode 27.0, and the iOS job uses the iPhone 18 Pro / iOS 27.0 simulator. No tests are skipped.

## Architecture notes

- **Framework independence**: `EssentialFeed` has no UIKit or app-level dependencies, so it can be tested and reused independently of any UI.
- **Composition over inheritance**: `EssentialApp` composes remote and local data sources (e.g. remote-with-local-fallback, caching decorators) rather than baking that logic into the core loaders.
- **MVP/MVVM-C presentation**: presenters and view models live in `EssentialFeed`, translating domain events into view-agnostic state that `EssentialFeediOS` renders..
