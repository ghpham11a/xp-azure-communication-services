from pydantic import BaseModel

class TokenRequest(BaseModel):
    displayName: str = "Anonymous"