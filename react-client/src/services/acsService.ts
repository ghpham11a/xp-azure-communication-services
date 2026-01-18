import { AzureCommunicationTokenCredential } from '@azure/communication-common';
import { ACS_CONFIG } from '../config/acs.config';
import type { AcsUser, TokenResponse } from '../types/acs.types';

export async function getAcsToken(displayName: string): Promise<AcsUser> {
  const response = await fetch(ACS_CONFIG.tokenEndpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ displayName }),
  });

  if (!response.ok) {
    throw new Error(`Failed to get ACS token: ${response.statusText}`);
  }

  const data: TokenResponse = await response.json();

  return {
    identity: { communicationUserId: data.userId },
    token: data.token,
    displayName,
  };
}

export function createTokenCredential(token: string): AzureCommunicationTokenCredential {
  return new AzureCommunicationTokenCredential(token);
}

export async function refreshToken(userId: string): Promise<string> {
  const response = await fetch(`${ACS_CONFIG.tokenEndpoint}/refresh`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ userId }),
  });

  if (!response.ok) {
    throw new Error(`Failed to refresh token: ${response.statusText}`);
  }

  const data: TokenResponse = await response.json();
  return data.token;
}

export async function createChatThread(topic: string, participantIds: string[]): Promise<string> {
  const response = await fetch(`${ACS_CONFIG.tokenEndpoint}/chat/thread`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ topic, participantIds }),
  });

  if (!response.ok) {
    throw new Error(`Failed to create chat thread: ${response.statusText}`);
  }

  const data = await response.json();
  return data.threadId;
}
