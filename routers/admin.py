from fastapi import APIRouter, HTTPException

from db.connection import get_conn, release_conn
from db.queries import (
    create_match,
    delete_match,
    get_match_by_id,
    get_predictions_for_match,
    get_scoring_rules,
    get_user_by_id,
    set_match_result,
    update_prediction_points,
)
from domain.match_results import calculate_match_points
from domain.predictions import is_prediction_allowed
from schemas.models import MatchCreateRequest, MatchResultRequest

router = APIRouter()


@router.post("/matches", status_code=201)
def add_match(body: MatchCreateRequest):
    conn = get_conn()
    try:
        user = get_user_by_id(conn, body.user_id)
        if not user or not user["is_admin"]:
            raise HTTPException(status_code=403, detail="Brak uprawnień administratora")

        if body.home_team_id == body.away_team_id:
            raise HTTPException(status_code=422, detail="Drużyna nie może grać sama ze sobą")

        # kickoff must be in the future
        if not is_prediction_allowed(body.kickoff_at):
            raise HTTPException(status_code=422, detail="Data meczu musi być w przyszłości")

        match = create_match(conn, body.league_id, body.home_team_id, body.away_team_id, body.kickoff_at)
        return {"message": "Mecz dodany", "match_id": match["id"]}
    finally:
        release_conn(conn)


@router.delete("/matches/{match_id}", status_code=204)
def remove_match(match_id: int, user_id: int):
    conn = get_conn()
    try:
        user = get_user_by_id(conn, user_id)
        if not user or not user["is_admin"]:
            raise HTTPException(status_code=403, detail="Brak uprawnień administratora")

        match = get_match_by_id(conn, match_id)
        if not match:
            raise HTTPException(status_code=404, detail="Mecz nie istnieje")

        if match["status"] != "finished":
            raise HTTPException(status_code=409, detail="Można usuwać tylko zakończone mecze")

        delete_match(conn, match_id)
    finally:
        release_conn(conn)


@router.post("/matches/{match_id}/result")
def set_result(match_id: int, body: MatchResultRequest):
    conn = get_conn()
    try:
        # check if caller is an admin
        user = get_user_by_id(conn, body.user_id)
        if not user or not user["is_admin"]:
            raise HTTPException(status_code=403, detail="Brak uprawnień administratora")

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
