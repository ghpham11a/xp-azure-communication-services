# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Azure Communication Services (ACS) experimentation project with a React frontend for chat, video calling, and PSTN phone calls. The project has placeholder directories for Azure Functions and Lambda functions (currently empty).

## Project Structure

- `react-client/` - Vite + React 19 + TypeScript frontend using ACS UI Library composites
- `azure-functions/` - Placeholder for Azure Functions backend (empty)
- `lambda-functions/` - Placeholder for AWS Lambda backend (empty)

## Commands

All commands run from the `react-client/` directory:

```bash
# Development
npm run dev          # Start Vite dev server with HMR

# Build & Type Check
npm run build        # TypeScript compile + Vite production build
tsc -b               # Type check only

# Lint
npm run lint         # ESLint

# Preview production build
npm run preview
```

## Architecture

### Frontend (react-client)

The app uses Azure Communication Services UI Library composites for pre-built communication experiences:

- **App.tsx** - Main component handling user authentication, mode switching (chat/video/phone), and state management
- **components/Chat/ChatComposite.tsx** - Wraps `ChatComposite` from `@azure/communication-react`
- **components/Calling/CallingComposite.tsx** - Wraps `CallComposite` with support for group calls, Teams meetings, and rooms
- **components/Calling/PhoneCall.tsx** - Direct PSTN calling using `CallClient` from `@azure/communication-calling`

### Token Flow

The client expects a backend token endpoint (default: `http://localhost:7071/api/token`) that:
1. Creates ACS user identities
2. Issues access tokens
3. Returns `{ token, userId, expiresOn }`

Token service calls are in `services/acsService.ts`.

### Configuration

Environment variables (create `.env` in `react-client/`):
```
VITE_ACS_ENDPOINT=https://your-resource.communication.azure.com
VITE_TOKEN_ENDPOINT=http://localhost:7071/api/token
VITE_ACS_PHONE_NUMBER=+1234567890  # Optional, for PSTN
```

## Key Dependencies

- `@azure/communication-react` - UI Library with composites
- `@azure/communication-calling` - Core calling SDK
- `@azure/communication-chat` - Core chat SDK
- `@azure/communication-common` - Shared types and credentials
- React 19 with React Compiler enabled via babel-plugin-react-compiler
