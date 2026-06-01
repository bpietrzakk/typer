import hashlib

from fastapi import APIRouter, HTTPException

from db.connection import get_conn, release_conn
from db.queries import create_user, get_user_by_nick
from schemas.models import LoginRequest, RegisterRequest, UserResponse

router = APIRouter()


def hash_password(password: str) -> str:
    # simple sha256 hash — good enough for this academic project
    return hashlib.sha256(password.encode()).hexdigest()


@router.post("/auth/login", response_model=UserResponse)
def login(body: LoginRequest):
    conn = get_conn()
    try:
        user = get_user_by_nick(conn, body.nick)

        # check if user exists and password matches
        if not user or user["password_hash"] != hash_password(body.password):
            raise HTTPException(status_code=401, detail="Nieprawidłowy login lub hasło")

        return {"id": user["id"], "nick": user["nick"], "is_admin": user["is_admin"]}
    finally:
        release_conn(conn)


@router.post("/auth/register", response_model=UserResponse, status_code=201)
def register(body: RegisterRequest):
    conn = get_conn()
    try:
        # check if nick is already taken
        existing = get_user_by_nick(conn, body.nick)
        if existing:
            raise HTTPException(status_code=409, detail="Login jest już zajęty")

        email = f"{body.nick}@typer.local"
        user = create_user(conn, body.nick, email, hash_password(body.password))
        return {"id": user["id"], "nick": user["nick"], "is_admin": user["is_admin"]}
    finally:
        release_conn(conn)
