import { useState, useCallback } from 'react';
import { FluentProvider, webLightTheme } from '@fluentui/react-components';
import { Chat } from './components/Chat/ChatComposite';
import { Calling, createGroupCallLocator } from './components/Calling/CallingComposite';
import { getAcsToken, createChatThread, joinChatThread } from './services/acsService';
import { validateConfig } from './config/acs.config';
import type { AcsUser, CommunicationMode } from './types/acs.types';
import './App.css';

function App() {
  const [user, setUser] = useState<AcsUser | null>(null);
  const [displayName, setDisplayName] = useState('');
  const [mode, setMode] = useState<CommunicationMode>('chat');
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // For chat
  const [threadId, setThreadId] = useState('');
  const [hasJoinedThread, setHasJoinedThread] = useState(false);
  const [isJoiningThread, setIsJoiningThread] = useState(false);

  // For video/group calls
  const [groupId, setGroupId] = useState('');

  const connect = useCallback(async () => {
    if (!displayName.trim()) {
      setError('Please enter a display name');
      return;
    }

    if (!validateConfig()) {
      setError('ACS is not configured. Please set environment variables.');
      return;
    }

    setIsConnecting(true);
    setError(null);

    try {
      const acsUser = await getAcsToken(displayName);
      setUser(acsUser);
    } catch (err) {
      setError(`Failed to connect: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsConnecting(false);
    }
  }, [displayName]);

  const disconnect = useCallback(() => {
    setUser(null);
    setThreadId('');
    setGroupId('');
    setHasJoinedThread(false);
  }, []);

  const handleCreateThread = useCallback(async () => {
    if (!user) return;
    setIsJoiningThread(true);
    setError(null);
    try {
      const newThreadId = await createChatThread(
        user.identity.communicationUserId,
        user.displayName
      );
      setThreadId(newThreadId);
      setHasJoinedThread(true);
    } catch (err) {
      setError(`Failed to create thread: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsJoiningThread(false);
    }
  }, [user]);

  const handleJoinThread = useCallback(async () => {
    if (!user || !threadId.trim()) return;
    setIsJoiningThread(true);
    setError(null);
    try {
      await joinChatThread(threadId, user.identity.communicationUserId, user.displayName);
      setHasJoinedThread(true);
    } catch (err) {
      setError(`Failed to join thread: ${err instanceof Error ? err.message : 'Unknown error'}`);
    } finally {
      setIsJoiningThread(false);
    }
  }, [user, threadId]);

  if (!user) {
    return (
      <FluentProvider theme={webLightTheme}>
        <div className="app-container">
          <h1>Azure Communication Services</h1>
          <p>Chat & Video Calls</p>

          {error && <div className="error-message">{error}</div>}

          <div className="connect-form">
            <input
              type="text"
              placeholder="Enter your display name"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && connect()}
              disabled={isConnecting}
            />
            <button onClick={connect} disabled={isConnecting || !displayName.trim()}>
              {isConnecting ? 'Connecting...' : 'Connect'}
            </button>
          </div>

          <div className="setup-info">
            <h3>Setup Required</h3>
            <p>Create a <code>.env</code> file with:</p>
            <pre>
{`VITE_ACS_ENDPOINT=https://your-resource.communication.azure.com
VITE_TOKEN_ENDPOINT=http://localhost:6969/tokens/create`}
            </pre>
          </div>
        </div>
      </FluentProvider>
    );
  }

  return (
    <FluentProvider theme={webLightTheme}>
      <div className="app-container">
        <header className="app-header">
          <h1>Azure Communication Services</h1>
          <div className="user-info">
            <span>Connected as: {user.displayName}</span>
            <button onClick={disconnect} className="disconnect-btn">Disconnect</button>
          </div>
        </header>

        <nav className="mode-selector">
          <button
            className={mode === 'chat' ? 'active' : ''}
            onClick={() => setMode('chat')}
          >
            Chat
          </button>
          <button
            className={mode === 'video' ? 'active' : ''}
            onClick={() => setMode('video')}
          >
            Video Call
          </button>
        </nav>

        <main className="main-content">
          {mode === 'chat' && (
            <div className="chat-section">
              {error && <div className="error-message">{error}</div>}
              {!hasJoinedThread ? (
                <>
                  <div className="input-group">
                    <input
                      type="text"
                      placeholder="Enter Chat Thread ID to join"
                      value={threadId}
                      onChange={(e) => setThreadId(e.target.value)}
                      disabled={isJoiningThread}
                    />
                    <button
                      onClick={handleJoinThread}
                      disabled={isJoiningThread || !threadId.trim()}
                    >
                      {isJoiningThread ? 'Joining...' : 'Join Thread'}
                    </button>
                  </div>
                  <div className="divider">or</div>
                  <button
                    onClick={handleCreateThread}
                    disabled={isJoiningThread}
                    className="create-thread-btn"
                  >
                    {isJoiningThread ? 'Creating...' : 'Create New Thread'}
                  </button>
                </>
              ) : (
                <>
                  <div className="thread-info">
                    <span>Thread ID: <code>{threadId}</code></span>
                    <button
                      onClick={() => { setHasJoinedThread(false); setThreadId(''); }}
                      className="leave-btn"
                    >
                      Leave Thread
                    </button>
                  </div>
                  <Chat
                    token={user.token}
                    userId={user.identity.communicationUserId}
                    displayName={user.displayName}
                    threadId={threadId}
                  />
                </>
              )}
            </div>
          )}

          {mode === 'video' && (
            <div className="video-section">
              <div className="input-group">
                <input
                  type="text"
                  placeholder="Enter Group ID (UUID)"
                  value={groupId}
                  onChange={(e) => setGroupId(e.target.value)}
                />
                <button onClick={() => setGroupId(crypto.randomUUID())}>
                  Generate New Group ID
                </button>
              </div>
              {groupId ? (
                <Calling
                  token={user.token}
                  userId={user.identity.communicationUserId}
                  displayName={user.displayName}
                  locator={createGroupCallLocator(groupId)}
                />
              ) : (
                <p className="hint">Enter or generate a Group ID to start a video call</p>
              )}
            </div>
          )}
        </main>
      </div>
    </FluentProvider>
  );
}

export default App;
