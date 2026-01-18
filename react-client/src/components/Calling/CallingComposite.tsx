import { useEffect, useMemo, useState } from 'react';
import {
  CallComposite,
  createAzureCommunicationCallAdapter,
} from '@azure/communication-react';
import { AzureCommunicationTokenCredential } from '@azure/communication-common';

type CallLocator = { groupId: string } | { meetingLink: string } | { roomId: string };

interface CallingProps {
  token: string;
  userId: string;
  displayName: string;
  locator: CallLocator;
}

export function Calling({ token, userId, displayName, locator }: CallingProps) {
  const [adapter, setAdapter] = useState<Awaited<ReturnType<typeof createAzureCommunicationCallAdapter>> | null>(null);

  const credential = useMemo(() => new AzureCommunicationTokenCredential(token), [token]);

  useEffect(() => {
    const initAdapter = async () => {
      const callAdapter = await createAzureCommunicationCallAdapter({
        userId: { communicationUserId: userId },
        displayName,
        credential,
        locator,
      });
      setAdapter(callAdapter);
    };

    initAdapter();

    return () => {
      adapter?.dispose();
    };
  }, [credential, userId, displayName, locator]);

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
