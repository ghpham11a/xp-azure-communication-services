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