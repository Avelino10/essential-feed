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

- Xcode with Swift 5.0 toolchain
- iOS deployment target 14.4+
- macOS deployment target 11.1+ (for the framework's macOS test target)

## Getting started

Open the workspace (not the standalone project) to build and run the full app:

```
open EssentialApp/EssentialApp.xcworkspace
```

Select the `EssentialApp` scheme and run on a simulator or device.

To work on the core framework in isolation, open `EssentialFeed.xcodeproj` directly.

## Running tests

Tests can be run from Xcode via **Product ▸ Test**, or from the command line using the same schemes as CI:

```bash
# Core framework (macOS)
xcodebuild clean build test \
  -project EssentialFeed/EssentialFeed.xcodeproj \
  -scheme "CI_macOS" \
  -sdk macosx -destination "platform=macOS"

# Full app (iOS Simulator)
xcodebuild clean build test \
  -workspace EssentialApp/EssentialApp.xcworkspace \
  -scheme "CI_iOS" \
  -sdk iphonesimulator -destination "platform=iOS Simulator,OS=12.2,name=iPhone 8"
```

## Continuous integration

Builds and tests run on Travis CI (see `.travis.yml`), executing both the `CI_macOS` and `CI_iOS` schemes on every push.

## Architecture notes

- **Framework independence**: `EssentialFeed` has no UIKit or app-level dependencies, so it can be tested and reused independently of any UI.
- **Composition over inheritance**: `EssentialApp` composes remote and local data sources (e.g. remote-with-local-fallback, caching decorators) rather than baking that logic into the core loaders.
- **MVP/MVVM-C presentation**: presenters and view models live in `EssentialFeed`, translating domain events into view-agnostic state that `EssentialFeediOS` renders..
