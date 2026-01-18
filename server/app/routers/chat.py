import os

from fastapi import APIRouter, HTTPException, Request
from azure.communication.chat import ChatClient, ChatParticipant, CommunicationTokenCredential
from azure.communication.identity import CommunicationIdentityClient, CommunicationUserIdentifier

from models import CreateThreadRequest, JoinThreadRequest

router = APIRouter()


def get_chat_client_with_service_user() -> tuple[ChatClient, CommunicationUserIdentifier]:
    """
    Create a ChatClient authenticated as the persistent service user.
    The service user ID must be set in ACS_SERVICE_USER_ID env var.
    """
    connection_string = os.environ.get('ACS_CONNECTION_STRING', '')
    endpoint = os.environ.get('ACS_ENDPOINT', '')
    service_user_id = os.environ.get('ACS_SERVICE_USER_ID', '')

    if not service_user_id:
        raise ValueError("ACS_SERVICE_USER_ID not set. Run POST /tokens/service-user first.")

    # Create an identity client to get a token for the service user
    identity_client = CommunicationIdentityClient.from_connection_string(connection_string)

    # Get a fresh token for the existing service user
    service_user = CommunicationUserIdentifier(service_user_id)
    token_response = identity_client.get_token(service_user, scopes=['chat'])

    # Create chat client with the service user's token
    credential = CommunicationTokenCredential(token_response.token)
    chat_client = ChatClient(endpoint, credential)

    return chat_client, service_user


@router.post("/thread")
async def create_thread(request: Request, body: CreateThreadRequest):
    """Create a new chat thread with the user and service user as participants."""
    try:
        chat_client, service_user = get_chat_client_with_service_user()

        # Create participants list - include both the requesting user AND the service user
        # Service user is added so it can later add more participants (for join functionality)
        user_participant = ChatParticipant(
            identifier=CommunicationUserIdentifier(body.userId),
            display_name=body.displayName
        )
        service_participant = ChatParticipant(
            identifier=service_user,
            display_name="System"
        )

        # Create the thread with both participants
        create_result = chat_client.create_chat_thread(
            topic=body.topic,
            thread_participants=[user_participant, service_participant]
        )

        thread_id = create_result.chat_thread.id

        return {
            "threadId": thread_id,
            "topic": body.topic
        }

    except Exception as e:
        print(f"Error creating thread: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/thread/{thread_id}/join")
async def join_thread(thread_id: str, body: JoinThreadRequest):
    """Add a user to an existing chat thread (service user must already be a participant)."""
    try:
        chat_client, service_user = get_chat_client_with_service_user()

        # Get the chat thread client (authenticated as service user)
        chat_thread_client = chat_client.get_chat_thread_client(thread_id)

        # Add the user as a participant
        participant = ChatParticipant(
            identifier=CommunicationUserIdentifier(body.userId),
            display_name=body.displayName
        )

        chat_thread_client.add_participants([participant])

        return {
            "success": True,
            "threadId": thread_id,
            "userId": body.userId
        }

    except Exception as e:
        print(f"Error joining thread: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
