from pydantic import BaseModel


class TokenRequest(BaseModel):
    displayName: str = "Anonymous"


class CreateThreadRequest(BaseModel):
    userId: str
    displayName: str
    topic: str = "Chat"


class JoinThreadRequest(BaseModel):
    userId: str
    displayName: str