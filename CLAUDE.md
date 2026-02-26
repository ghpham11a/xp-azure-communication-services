# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Azure Communication Services (ACS) experimentation project with a React frontend, Android app, and FastAPI backend for chat and video calling.

## Project Structure

- `react-client/` - Vite + React 18 + TypeScript frontend using ACS UI Library composites
- `android-client/` - Kotlin + Jetpack Compose Android app using ACS UI SDK
- `ios-client/` - SwiftUI iOS app using ACS iOS SDK
- `server/` - FastAPI backend for ACS token and chat operations

## Commands

### Frontend (react-client/)

```bash
cd react-client
npm run dev          # Start Vite dev server (localhost:5173)
npm run build        # TypeScript compile + Vite production build
npm run lint         # ESLint
```

### Backend (server/)

```bash
cd server
pip install -r requirements.txt  # Install dependencies (use venv at server/env/)
cd app
uvicorn main:app --host 0.0.0.0 --port 6969 --reload
```

### Android (android-client/)

Open in Android Studio. Uses Gradle with version catalogs (`gradle/libs.versions.toml`).

### iOS (ios-client/)

```bash
cd ios-client/AzureCommunication
pod install                    # Install CocoaPods dependencies
open AzureCommunication.xcworkspace  # Open workspace (NOT .xcodeproj)
```

Requires Xcode 15+, iOS 17.0+ deployment target. Uses CocoaPods for ACS SDKs.

### Tunneling for mobile testing

```bash
ngrok http --hostname=<your-hostname>.ngrok.io <your-port>
```

## Architecture

### React Frontend

Uses `@azure/communication-react` UI Library composites:

- **App.tsx** - Main component: user auth, mode switching (chat/video), state management
- **components/Chat/ChatComposite.tsx** - Wraps `ChatComposite`
- **components/Calling/CallingComposite.tsx** - Wraps `CallComposite` (group calls, Teams meetings, rooms)
- **services/acsService.ts** - Backend API calls for tokens and chat threads

### Android App

Jetpack Compose with MVVM architecture:

- **MainActivity.kt** - Entry point, handles permissions and navigation flow
- **ui/viewmodel/AcsViewModel.kt** - State management for connection, chat, and calls
- **ui/screens/** - Compose screens: Home, ModeSelection, ChatSetup, Chat, CallSetup, Calling
- **data/api/AcsApiService.kt** - Retrofit service for backend API
- **data/repository/AcsRepository.kt** - Data layer
- **config/AcsConfig.kt** - ACS endpoint configuration

### iOS App

SwiftUI with MVVM architecture, Swinject DI, `@Observable` macro:

- **AzureCommunicationApp.swift** - Entry point, injects `SharedState` environment
- **ContentView.swift** - Root navigation, resolves ViewModels from DI container
- **DI/DependencyContainer.swift** - Swinject singleton registering all dependencies
- **Core/SharedState.swift** - `@Observable` cross-cutting session state (user, mode, threadId, groupId)
- **Core/Networking/** - Protocol-based networking: `Networking` protocol, `NetworkService` (URLSession), `Endpoint` protocol, `NetworkError`
- **Features/** - Co-located screens + ViewModels per feature: `Home/`, `ModeSelection/`, `Chat/`, `Calling/`
- **Data/Endpoints/** - Typed endpoint structs: `TokenEndpoints`, `ChatEndpoints`
- **Data/Repositories/** - Protocol + implementation per domain: `TokensRepo`/`TokensRepository`, `ChatRepo`/`ChatRepository`
- **Data/Models/AcsModels.swift** - Codable models
- **Config/AcsConfig.swift** - ACS endpoint configuration
- **Utilities/PermissionManager.swift** - Camera/microphone permissions

**ACS iOS SDK Notes:**
- Chat SDK uses completion handlers with Swift `Result` types, not async/await
- Example: `threadClient.send(message: request) { result, _ in switch result { case .success(let r): ... } }`
- Message types need explicit enum: `ChatMessageType.text` (not `.text`)
- Podfile includes post_install patch for Swift 6 compatibility with AzureCore

### Backend (FastAPI)

- **routers/tokens.py** - `POST /tokens/create` (identity + token), `POST /tokens/service-user` (one-time setup)
- **routers/chat.py** - `POST /chat/thread` (create), `POST /chat/thread/{id}/join` (add user)

Identity client initialized at startup via `ACS_CONNECTION_STRING` from environment.

### Token & Chat Flow

1. Client calls `/tokens/create` to get ACS user identity and token
2. To chat: create new thread (`/chat/thread`) or join existing (`/chat/thread/{id}/join`)
3. Thread creation adds both user and service user as participants
4. Service user can add new participants when others join via thread ID

## Configuration

### React (.env in react-client/)
```
VITE_ACS_ENDPOINT=https://your-resource.communication.azure.com
VITE_TOKEN_ENDPOINT=http://localhost:6969/tokens/create
```

### Backend (.env in server/)
```
ACS_CONNECTION_STRING=endpoint=https://...;accesskey=...
ACS_ENDPOINT=https://your-resource.communication.azure.com
ACS_SERVICE_USER_ID=8:acs:...  # See setup below
```

### Android (config/AcsConfig.kt)

Update `ACS_ENDPOINT` constant and backend URL in `NetworkModule.kt`.

### iOS (Config/AcsConfig.swift)

Update `acsEndpoint` and `apiBaseURL` constants.

### Service User Setup (one-time)

Required for chat "join" functionality:

1. Start the server
2. Run: `curl -X POST http://localhost:6969/tokens/service-user`
3. Copy returned `userId` to `.env` as `ACS_SERVICE_USER_ID`
4. Restart the server
