from fastapi import APIRouter, HTTPException

from db.connection import get_conn, release_conn
from db.queries import (
    get_match_by_id,
    get_predictions_for_match,
    get_scoring_rules,
    set_match_result,
    update_prediction_points,
)
from domain.match_results import calculate_match_points
from schemas.models import MatchResultRequest

router = APIRouter()


@router.post("/matches/{match_id}/result")
def set_result(match_id: int, body: MatchResultRequest):
    conn = get_conn()
    try:
        # check if match exists
        match = get_match_by_id(conn, match_id)
        if not match:
            raise HTTPException(status_code=404, detail="Mecz nie istnieje")

        # don't allow setting result twice
        if match["status"] == "finished":
            raise HTTPException(status_code=409, detail="Wynik tego meczu już został wpisany")

        # get all user predictions for this match
        predictions = get_predictions_for_match(conn, match_id)

        # get scoring rules from db
        rules = get_scoring_rules(conn)

        # calculate how many points each prediction gets — pure domain function
        results = calculate_match_points(predictions, body.home_goals, body.away_goals, rules)

        # save points for each prediction (no commit yet — all in one transaction)
        for r in results:
            update_prediction_points(conn, r["prediction_id"], r["points"])

        # set match result and commit everything at once
        set_match_result(conn, match_id, body.home_goals, body.away_goals)

        return {
            "message": "Wynik zapisany, punkty przeliczone",
            "predictions_updated": len(results),
        }
    finally:
        release_conn(conn)
