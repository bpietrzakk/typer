from fastapi import APIRouter, HTTPException
from psycopg2.errors import UniqueViolation

from db.connection import get_conn, release_conn
from db.queries import create_prediction, get_match_by_id, get_user_by_id
from domain.predictions import is_prediction_allowed
from schemas.models import PredictionCreate, PredictionResponse

router = APIRouter()


@router.post("/predictions", response_model=PredictionResponse, status_code=201)
def add_prediction(body: PredictionCreate):
    conn = get_conn()
    try:
        # check if user exists
        user = get_user_by_id(conn, body.user_id)
        if not user:
            raise HTTPException(status_code=404, detail="Użytkownik nie istnieje")

        # check if match exists
        match = get_match_by_id(conn, body.match_id)
        if not match:
            raise HTTPException(status_code=404, detail="Mecz nie istnieje")

        # check if match hasn't started yet — domain validates this rule
        if not is_prediction_allowed(match["kickoff_at"]):
            raise HTTPException(status_code=409, detail="Mecz już się rozpoczął, nie można dodać typu")

        try:
            return create_prediction(conn, body.user_id, body.match_id, body.pred_home, body.pred_away)
        except UniqueViolation:
            conn.rollback()
            raise HTTPException(status_code=409, detail="Już dodałeś typ na ten mecz")
    finally:
        release_conn(conn)
