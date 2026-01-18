# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Azure Communication Services (ACS) experimentation project with a React frontend for chat, video calling, and PSTN phone calls, and a FastAPI backend for token management and chat operations.

## Project Structure

- `react-client/` - Vite + React 19 + TypeScript frontend using ACS UI Library composites
- `server/` - FastAPI backend for ACS token and chat operations
- `azure-functions/` - Placeholder for Azure Functions backend (empty)
- `lambda-functions/` - Placeholder for AWS Lambda backend (empty)

## Commands

### Frontend (react-client/)

```bash
npm run dev          # Start Vite dev server with HMR
npm run build        # TypeScript compile + Vite production build
npm run lint         # ESLint
tsc -b               # Type check only
```

### Backend (server/)

```bash
cd server/app
uvicorn main:app --host 0.0.0.0 --port 6969 --reload
```

## Architecture

### Frontend (react-client)

Uses Azure Communication Services UI Library composites for pre-built communication experiences:

- **App.tsx** - Main component handling user authentication, mode switching (chat/video/phone), and state management
- **components/Chat/ChatComposite.tsx** - Wraps `ChatComposite` from `@azure/communication-react`
- **components/Calling/CallingComposite.tsx** - Wraps `CallComposite` with support for group calls, Teams meetings, and rooms
- **components/Calling/PhoneCall.tsx** - Direct PSTN calling using `CallClient` from `@azure/communication-calling`
- **services/acsService.ts** - API calls to backend for tokens and chat thread management

### Backend (server)

FastAPI application with routers:

- **routers/tokens.py** - `POST /tokens/create` - Creates ACS user identities and issues access tokens
- **routers/chat.py** - `POST /chat/thread` - Creates chat threads; `POST /chat/thread/{id}/join` - Adds users to threads

The identity client is initialized at startup using `ACS_CONNECTION_STRING` from environment.

### Token & Chat Flow

1. Frontend calls `/tokens/create` to get a new ACS user identity and token
2. To chat, user either creates a new thread (`/chat/thread`) or joins existing (`/chat/thread/{id}/join`)
3. User must be a participant in a thread before sending messages

## Configuration

### Frontend (.env in react-client/)
```
VITE_ACS_ENDPOINT=https://your-resource.communication.azure.com
VITE_TOKEN_ENDPOINT=http://localhost:6969/tokens/create
VITE_ACS_PHONE_NUMBER=+1234567890  # Optional, for PSTN
```

### Backend (.env in server/)
```
ACS_CONNECTION_STRING=endpoint=https://...;accesskey=...
ACS_ENDPOINT=https://your-resource.communication.azure.com
```

## Key Dependencies

### Frontend
- `@azure/communication-react` - UI Library with composites
- `@azure/communication-calling` - Core calling SDK
- `@azure/communication-chat` - Core chat SDK
- React 19 with React Compiler enabled via babel-plugin-react-compiler

### Backend
- FastAPI with uvicorn
- `azure-communication-identity` - User/token management
- `azure-communication-chat` - Chat thread operations
