import { useEffect, useMemo, useState } from 'react';
import {
  ChatComposite,
  createAzureCommunicationChatAdapter,
} from '@azure/communication-react';
import { AzureCommunicationTokenCredential } from '@azure/communication-common';
import { ACS_CONFIG } from '../../config/acs.config';

interface ChatProps {
  token: string;
  userId: string;
  displayName: string;
  threadId: string;
}

export function Chat({ token, userId, displayName, threadId }: ChatProps) {
  const [adapter, setAdapter] = useState<Awaited<ReturnType<typeof createAzureCommunicationChatAdapter>> | null>(null);

  const credential = useMemo(() => new AzureCommunicationTokenCredential(token), [token]);

  useEffect(() => {
    const initAdapter = async () => {
      const chatAdapter = await createAzureCommunicationChatAdapter({
        endpoint: ACS_CONFIG.endpoint,
        userId: { communicationUserId: userId },
        displayName,
        credential,
        threadId,
      });
      setAdapter(chatAdapter);
    };

    initAdapter();

    return () => {
      adapter?.dispose();
    };
  }, [credential, userId, displayName, threadId]);

  if (!adapter) {
    return <div className="loading">Initializing chat...</div>;
  }

  return (
    <div className="chat-container" style={{ height: '600px', width: '100%' }}>
      <ChatComposite adapter={adapter} />
    </div>
  );
}

export default Chat;
