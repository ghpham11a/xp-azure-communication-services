import os

from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from azure.communication.identity import CommunicationIdentityClient

from routers import tokens

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.identity_client = CommunicationIdentityClient.from_connection_string(os.environ.get('ACS_CONNECTION_STRING', ''))
    yield 
    app.state.identity_client = None

def create_app() -> FastAPI:

    app = FastAPI(lifespan=lifespan)

    app.include_router(tokens.router, prefix="/tokens", tags=["tokens"])

    @app.get("/")
    def root():
        return { "status": "up" }
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["http://localhost:5173"],
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["Content-Type"],
    )
    
    return app

load_dotenv() 

# uvicorn main:app --host 0.0.0.0 --port 6969 --reload
app = create_app()