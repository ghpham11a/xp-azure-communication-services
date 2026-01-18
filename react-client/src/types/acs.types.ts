import type { CommunicationUserIdentifier } from '@azure/communication-common';

export interface AcsUser {
  identity: CommunicationUserIdentifier;
  token: string;
  displayName: string;
}

export interface TokenResponse {
  token: string;
  expiresOn: string;
  userId: string;
}

export interface ChatThreadInfo {
  threadId: string;
  topic: string;
}

export interface CallInfo {
  groupId?: string;
  participantIds?: string[];
  phoneNumber?: string;
}

export type CommunicationMode = 'chat' | 'call' | 'video' | 'phone';
