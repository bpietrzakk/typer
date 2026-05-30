from fastapi import APIRouter, HTTPException

from db.connection import get_conn, release_conn
from db.queries import get_all_matches, get_match_by_id
from schemas.models import MatchResponse

router = APIRouter()


@router.get("/matches", response_model=list[MatchResponse])
def list_matches():
    # return all matches with team and league names
    conn = get_conn()
    try:
        return get_all_matches(conn)
    finally:
        release_conn(conn)


@router.get("/matches/{match_id}", response_model=MatchResponse)
def get_match(match_id: int):
    conn = get_conn()
    try:
        match = get_match_by_id(conn, match_id)
        if not match:
            raise HTTPException(status_code=404, detail="Mecz nie istnieje")
        return match
    finally:
        release_conn(conn)
