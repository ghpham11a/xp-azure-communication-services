from fastapi import APIRouter, HTTPException, Request

from models import TokenRequest

router = APIRouter()


@router.post("/create")
async def create_token(request: Request, body: TokenRequest):
    client = request.app.state.identity_client

    try:
        # Create user and token with chat and voip scopes
        user, token_response = client.create_user_and_token(scopes=['chat', 'voip'])

        return {
            'userId': user.properties['id'],
            'token': token_response.token,
            'expiresOn': token_response.expires_on,
        }
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/service-user")
async def create_service_user(request: Request):
    """
    One-time setup: Creates a persistent service user for chat operations.
    Save the returned userId to your .env as ACS_SERVICE_USER_ID.
    """
    client = request.app.state.identity_client

    try:
        user = client.create_user()

        return {
            'userId': user.properties['id'],
            'message': 'Save this userId to your .env file as ACS_SERVICE_USER_ID'
        }
    except Exception as e:
        print(str(e))
        raise HTTPException(status_code=500, detail=str(e))