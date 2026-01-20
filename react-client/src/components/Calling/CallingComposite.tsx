import { useEffect, useMemo, useState, useRef } from 'react';
import {
  CallComposite,
  createAzureCommunicationCallAdapter,
  type CallAdapter,
} from '@azure/communication-react';
import { AzureCommunicationTokenCredential } from '@azure/communication-common';

type CallLocator = { groupId: string } | { meetingLink: string } | { roomId: string };

interface CallingProps {
  token: string;
  userId: string;
  displayName: string;
  locator: CallLocator;
}

// Adapter singleton with ref counting
interface AdapterState {
  adapter: CallAdapter | null;
  promise: Promise<CallAdapter> | null;
  locatorKey: string;
  refCount: number;
  disposeTimer: ReturnType<typeof setTimeout> | null;
}

const stateMap = new Map<string, AdapterState>();

function getState(userId: string): AdapterState {
  let state = stateMap.get(userId);
  if (!state) {
    state = { adapter: null, promise: null, locatorKey: '', refCount: 0, disposeTimer: null };
    stateMap.set(userId, state);
  }
  return state;
}

export function Calling({ token, userId, displayName, locator }: CallingProps) {
  const [adapter, setAdapter] = useState<CallAdapter | null>(null);
  const [error, setError] = useState<string | null>(null);

  const credential = useMemo(() => new AzureCommunicationTokenCredential(token), [token]);
  const locatorKey = JSON.stringify(locator);

  useEffect(() => {
    const state = getState(userId);
    let active = true;

    // Cancel any pending disposal
    if (state.disposeTimer) {
      clearTimeout(state.disposeTimer);
      state.disposeTimer = null;
    }

    // Increment ref count
    state.refCount++;

    const init = async () => {
      // If adapter exists with same locator, reuse it
      if (state.adapter && state.locatorKey === locatorKey) {
        if (active) setAdapter(state.adapter);
        return;
      }

      // If adapter exists with different locator, dispose it
      if (state.adapter && state.locatorKey !== locatorKey) {
        const oldAdapter = state.adapter;
        state.adapter = null;
        state.promise = null;
        await oldAdapter.dispose().catch(() => {});
        if (!active) return;
      }

      // If creation in progress with same locator, wait for it
      if (state.promise && state.locatorKey === locatorKey) {
        try {
          const result = await state.promise;
          if (active && state.adapter === result) {
            setAdapter(result);
          }
        } catch (err) {
          if (active) setError(err instanceof Error ? err.message : 'Failed');
        }
        return;
      }

      // Start new creation
      state.locatorKey = locatorKey;
      state.promise = createAzureCommunicationCallAdapter({
        userId: { communicationUserId: userId },
        displayName,
        credential,
        locator,
      });

      try {
        const newAdapter = await state.promise;
        state.adapter = newAdapter;
        if (active) setAdapter(newAdapter);
      } catch (err) {
        state.promise = null;
        if (active) {
          console.error('Failed to create call adapter:', err);
          setError(err instanceof Error ? err.message : 'Failed to join call');
        }
      }
    };

    init();

    return () => {
      active = false;
      state.refCount--;

      if (state.refCount <= 0 && state.adapter) {
        // Defer disposal to handle StrictMode double-mount
        state.disposeTimer = setTimeout(() => {
          if (state.refCount <= 0 && state.adapter) {
            const toDispose = state.adapter;
            state.adapter = null;
            state.promise = null;
            toDispose.dispose().catch(console.error);
          }
        }, 100);
      }
    };
  }, [credential, userId, displayName, locatorKey]);

  if (error) {
    return <div className="error">Error: {error}</div>;
  }

  if (!adapter) {
    return <div className="loading">Initializing call...</div>;
  }

  return (
    <div className="calling-container" style={{ height: '600px', width: '100%' }}>
      <CallComposite adapter={adapter} />
    </div>
  );
}

export function createGroupCallLocator(groupId: string): CallLocator {
  return { groupId };
}

export function createTeamsMeetingLocator(meetingLink: string): CallLocator {
  return { meetingLink };
}

export function createRoomCallLocator(roomId: string): CallLocator {
  return { roomId };
}

export default Calling;
