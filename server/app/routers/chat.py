import os

from fastapi import APIRouter, HTTPException, Request
from azure.communication.chat import ChatClient, ChatParticipant, CommunicationTokenCredential
from azure.communication.identity import CommunicationIdentityClient, CommunicationUserIdentifier


from models import CreateThreadRequest, JoinThreadRequest

router = APIRouter()


def get_chat_client() -> tuple[ChatClient, CommunicationUserIdentifier]:
    """Create a ChatClient using a fresh admin token."""
    connection_string = os.environ.get('ACS_CONNECTION_STRING', '')
    endpoint = os.environ.get('ACS_ENDPOINT', '')

    # Create an identity client to generate an admin token
    identity_client = CommunicationIdentityClient.from_connection_string(connection_string)

    # Create admin user and token for server-side operations
    admin_user, token_response = identity_client.create_user_and_token(scopes=['chat'])

    # Create credential from the token
    credential = CommunicationTokenCredential(token_response.token)

    # Create chat client with the credential
    chat_client = ChatClient(endpoint, credential)

    return chat_client, admin_user


@router.post("/thread")
async def create_thread(request: Request, body: CreateThreadRequest):
    """Create a new chat thread and add the user as a participant."""
    try:
        chat_client, admin_user = get_chat_client()

        # Create participants list - include the requesting user
        participant = ChatParticipant(
            identifier=CommunicationUserIdentifier(body.userId),
            display_name=body.displayName
        )

        # Create the thread
        create_result = chat_client.create_chat_thread(
            topic=body.topic,
            thread_participants=[participant]
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
    """Add a user to an existing chat thread."""
    try:
        chat_client, admin_user = get_chat_client()

        # Get the chat thread client
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
