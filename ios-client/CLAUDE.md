# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See also the root `../CLAUDE.md` for project-wide context (backend API, other clients, configuration).

## Commands

```bash
cd AzureCommunication
pod install                              # Install/update CocoaPods dependencies
open AzureCommunication.xcworkspace      # Open workspace (NOT .xcodeproj)
xcodebuild -workspace AzureCommunication.xcworkspace -scheme AzureCommunication -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build  # CLI build
```

No unit tests exist yet. UI test targets exist but contain only placeholder Xcode templates.

## Architecture

SwiftUI + MVVM + Swinject DI + `@Observable` (iOS 17+). CocoaPods for dependencies.

### Dependency Injection

`DI/DependencyContainer.swift` is a Swinject singleton that registers everything. ViewModels are resolved from the container in `ContentView.swift`. Singletons use `.inObjectScope(.container)`: `Networking`, repositories, `SharedState`, `RouteManager`. ViewModels get new instances per resolution.

### Navigation

`Core/RouteManager.swift` wraps a `NavigationPath` and `Route` enum. `ContentView` switches between `HomeScreen` (pre-auth) and a `NavigationStack` (post-auth). Deep links (`azcomms://chat/join/{id}`, `azcomms://call/join/{id}`) are handled in `AzureCommunicationApp.swift` and queued as `pendingRoute` if not yet connected.

### Networking

Protocol-based: `Networking` protocol → `NetworkService` (URLSession, async/await, 30s timeout). Endpoints are typed structs conforming to `Endpoint` protocol (path, method, headers, body). Repositories (`TokensRepo`, `ChatRepo`) wrap endpoint calls. Base URL comes from `Config/AcsConfig.swift`.

### State Management

`Core/SharedState.swift` is an `@Observable` class holding cross-cutting state: current user (`AcsUser`), selected mode, thread/group IDs, loading/error flags. Injected as `@Environment` and also passed to ViewModels via DI.

### App Flow

1. `HomeScreen` → user enters display name → `TokensRepo.createToken()` → `SharedState.connect()`
2. `ModeSelectionScreen` → choose Chat or Video
3. Setup screen → create new or join existing thread/group
4. `ChatScreen` (ACS Chat SDK) or `CallingScreen` (ACS CallComposite UI)

## ACS SDK Gotchas

- **Chat SDK uses completion handlers**, not async/await: `threadClient.send(message:) { result, _ in ... }`
- **Message type enum must be explicit**: `ChatMessageType.text` not `.text`
- **Podfile has a post_install patch** that removes a problematic `==` operator extension in AzureCore's `RequestString.swift` for Swift 6 compatibility. Don't remove this.
- **CallComposite** is a UIKit-based overlay launched imperatively, not a SwiftUI view.

## Configuration

`Config/AcsConfig.swift` has two hardcoded values to update:
- `acsEndpoint` — the ACS resource URL
- `apiBaseURL` — the backend server URL (use ngrok URL for device testing)
