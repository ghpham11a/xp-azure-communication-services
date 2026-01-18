import { useEffect, useMemo, useState, useCallback } from 'react';
import { CallClient } from '@azure/communication-calling';
import { AzureCommunicationTokenCredential } from '@azure/communication-common';

interface PhoneCallProps {
  token: string;
  displayName: string;
  alternateCallerId: string;
}

type CallState = 'idle' | 'connecting' | 'ringing' | 'connected' | 'disconnected';

export function PhoneCall({ token, displayName, alternateCallerId }: PhoneCallProps) {
  const [callAgent, setCallAgent] = useState<Awaited<ReturnType<CallClient['createCallAgent']>> | null>(null);
  const [currentCall, setCurrentCall] = useState<ReturnType<NonNullable<typeof callAgent>['startCall']> | null>(null);
  const [callState, setCallState] = useState<CallState>('idle');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [error, setError] = useState<string | null>(null);

  const credential = useMemo(() => new AzureCommunicationTokenCredential(token), [token]);

  useEffect(() => {
    const initCallAgent = async () => {
      try {
        const callClient = new CallClient();
        const agent = await callClient.createCallAgent(credential, { displayName });
        setCallAgent(agent);
      } catch (err) {
        setError(`Failed to initialize call agent: ${err}`);
      }
    };

    initCallAgent();

    return () => {
      callAgent?.dispose();
    };
  }, [credential, displayName]);

  const startCall = useCallback(async () => {
    if (!callAgent || !phoneNumber) return;

    setError(null);
    setCallState('connecting');

    try {
      const call = callAgent.startCall(
        [{ phoneNumber: phoneNumber }],
        { alternateCallerId: { phoneNumber: alternateCallerId } }
      );

      setCurrentCall(call);

      call.on('stateChanged', () => {
        switch (call.state) {
          case 'Connecting':
            setCallState('connecting');
            break;
          case 'Ringing':
            setCallState('ringing');
            break;
          case 'Connected':
            setCallState('connected');
            break;
          case 'Disconnected':
            setCallState('disconnected');
            setCurrentCall(null);
            break;
        }
      });
    } catch (err) {
      setError(`Failed to start call: ${err}`);
      setCallState('idle');
    }
  }, [callAgent, phoneNumber, alternateCallerId]);

  const endCall = useCallback(async () => {
    if (currentCall) {
      await currentCall.hangUp();
      setCurrentCall(null);
      setCallState('idle');
    }
  }, [currentCall]);

  return (
    <div className="phone-call-container" style={{ padding: '20px' }}>
      <h3>Phone Call (PSTN)</h3>

      {error && (
        <div style={{ color: 'red', marginBottom: '10px' }}>{error}</div>
      )}

      <div style={{ marginBottom: '10px' }}>
        <input
          type="tel"
          placeholder="+1234567890"
          value={phoneNumber}
          onChange={(e) => setPhoneNumber(e.target.value)}
          disabled={callState !== 'idle'}
          style={{ padding: '10px', marginRight: '10px', width: '200px' }}
        />
      </div>

      <div style={{ marginBottom: '10px' }}>
        <strong>Status:</strong> {callState}
      </div>

      <div>
        {callState === 'idle' ? (
          <button
            onClick={startCall}
            disabled={!callAgent || !phoneNumber}
            style={{ padding: '10px 20px', cursor: 'pointer' }}
          >
            Call
          </button>
        ) : (
          <button
            onClick={endCall}
            style={{ padding: '10px 20px', backgroundColor: 'red', color: 'white', cursor: 'pointer' }}
          >
            End Call
          </button>
        )}
      </div>

      <p style={{ marginTop: '20px', fontSize: '12px', color: '#666' }}>
        Note: PSTN calling requires a phone number purchased through Azure Communication Services
        and proper configuration of your ACS resource.
      </p>
    </div>
  );
}

export default PhoneCall;
