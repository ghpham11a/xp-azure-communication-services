# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Android client for Azure Communication Services (ACS) using Jetpack Compose, Hilt DI, and the ACS UI SDK for chat and video calling.

## Commands

Open in Android Studio. Uses Gradle with version catalogs (`gradle/libs.versions.toml`).

```bash
./gradlew assembleDebug       # Build debug APK
./gradlew installDebug        # Build and install on connected device
./gradlew test                # Run unit tests
./gradlew connectedAndroidTest  # Run instrumented tests
```

## Architecture

### Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Jetpack Compose, Material 3 |
| DI | Hilt |
| Networking | Retrofit, Moshi, OkHttp |
| State | StateFlow, SharedState singleton |
| ACS | azure-communication-ui-calling, azure-communication-ui-chat |

### Project Structure

```
app/src/main/java/com/example/azurecommunication/
├── app/
│   ├── AzureCommunicationApp.kt    # @HiltAndroidApp
│   ├── MainActivity.kt             # @AndroidEntryPoint, permissions, navigation
│   └── MainViewModel.kt            # Exposes SharedState to root composable
├── config/
│   └── AcsConfig.kt                # ACS endpoint constant
├── core/
│   └── networking/
│       └── NetworkModule.kt        # Hilt module: Retrofit, Moshi, OkHttp
├── data/
│   ├── api/
│   │   └── AcsApiService.kt        # Retrofit interface for backend
│   ├── models/
│   │   └── AcsModels.kt            # Moshi models: TokenRequest/Response, thread models
│   └── repository/
│       └── AcsRepository.kt        # Result-wrapped API calls
├── features/                       # Feature modules (screen + viewmodel + components)
│   ├── home/
│   ├── modeselection/
│   ├── chatsetup/
│   ├── chat/
│   ├── callsetup/
│   └── calling/
└── shared/
    ├── components/                 # Reusable UI components
    ├── state/
    │   └── SharedState.kt          # @Singleton cross-feature state
    └── theme/                      # Color, Theme, Type
```

### Navigation Flow

State-driven navigation in `MainActivity.kt` using `SharedState`:

1. **HomeScreen** - User enters display name, gets ACS token via `/tokens/create`
2. **ModeSelectionScreen** - Choose Chat or Video mode
3. **ChatSetupScreen/CallSetupScreen** - Create new or join existing thread/group
4. **ChatScreen/CallingScreen** - ACS UI SDK composites

### SharedState Pattern

`SharedState` is a `@Singleton` Hilt-injected class holding cross-feature state:
- `user: StateFlow<AcsUser?>` - Current user identity and token
- `isConnected: StateFlow<Boolean>` - Whether user has valid token
- `mode: StateFlow<CommunicationMode?>` - CHAT or VIDEO
- `threadId: StateFlow<String?>` - Active chat thread
- `groupId: StateFlow<String?>` - Active video call group

ViewModels inject `SharedState` and expose its flows. The root `AzureCommunicationApp` composable observes these flows to determine which screen to show.

### ACS UI SDK Integration

**Chat** (`features/chat/ChatScreen.kt`):
- Uses `ChatAdapterBuilder` to create adapter with credential, identity, endpoint, threadId
- Embeds `ChatThreadView` via `AndroidView` interop
- Connects on composition, disconnects on dispose

**Calling** (`features/calling/CallingScreen.kt`):
- Uses `CallCompositeBuilder` with credential and display name
- Launches via `callComposite.launch()` with `CallCompositeGroupCallLocator`
- Full-screen call UI handled by ACS SDK

## Configuration

Update `API_URL` in `app/build.gradle.kts` (line 27) to point to backend:
```kotlin
buildConfigField("String", "API_URL", "\"https://your-server.ngrok.io/\"")
```

Update ACS endpoint in `config/AcsConfig.kt`:
```kotlin
const val ACS_ENDPOINT = "https://your-resource.communication.azure.com"
```

## Key Patterns

- **Result wrapping**: Repository methods use `runCatching { }` returning `Result<T>`
- **Moshi codegen**: Models use `@JsonClass(generateAdapter = true)` with KSP
- **Hilt ViewModels**: Use `@HiltViewModel` with `hiltViewModel()` in composables
- **StateFlow**: All state exposed as `StateFlow`, collected with `collectAsState()`
