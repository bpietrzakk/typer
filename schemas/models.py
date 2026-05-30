from datetime import datetime
from pydantic import BaseModel


# --- request bodies ---

class PredictionCreate(BaseModel):
    user_id:   int
    match_id:  int
    pred_home: int
    pred_away: int


class MatchResultRequest(BaseModel):
    home_goals: int
    away_goals: int


# --- response models ---

class MatchResponse(BaseModel):
    id:         int
    home_team:  str
    away_team:  str
    league:     str
    kickoff_at: datetime
    home_goals: int | None
    away_goals: int | None
    status:     str


class PredictionResponse(BaseModel):
    id:             int
    user_id:        int
    match_id:       int
    pred_home:      int
    pred_away:      int
    points_awarded: int | None
    created_at:     datetime


class RankingEntry(BaseModel):
    user_id:      int
    nick:         str
    total_points: int
