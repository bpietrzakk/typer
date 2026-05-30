from fastapi import APIRouter

from db.connection import get_conn, release_conn
from db.queries import get_ranking
from schemas.models import RankingEntry

router = APIRouter()


@router.get("/ranking", response_model=list[RankingEntry])
def list_ranking():
    # return all users sorted by total points from finished matches
    conn = get_conn()
    try:
        return get_ranking(conn)
    finally:
        release_conn(conn)
