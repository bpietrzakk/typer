from psycopg2.extras import RealDictCursor

# --- matches ---

# get all matches with team and league names instead of raw ids
_SQL_GET_ALL_MATCHES = """
    SELECT
        m.id,
        m.kickoff_at,
        m.home_goals,
        m.away_goals,
        m.status,
        ht.name AS home_team,
        at.name AS away_team,
        l.name  AS league
    FROM matches m
    JOIN teams ht ON m.home_team_id = ht.id
    JOIN teams at ON m.away_team_id = at.id
    JOIN leagues l ON m.league_id = l.id
    ORDER BY m.kickoff_at
"""

# get single match by id — used for validation and setting result
_SQL_GET_MATCH_BY_ID = """
    SELECT
        m.id,
        m.kickoff_at,
        m.home_goals,
        m.away_goals,
        m.status,
        ht.name AS home_team,
        at.name AS away_team,
        l.name  AS league
    FROM matches m
    JOIN teams ht ON m.home_team_id = ht.id
    JOIN teams at ON m.away_team_id = at.id
    JOIN leagues l ON m.league_id = l.id
    WHERE m.id = %s
"""

# set match result and mark as finished
_SQL_SET_MATCH_RESULT = """
    UPDATE matches
    SET home_goals = %s,
        away_goals = %s,
        status     = 'finished'
    WHERE id = %s
"""

# --- predictions ---

# insert a new prediction for a user
_SQL_CREATE_PREDICTION = """
    INSERT INTO predictions (user_id, match_id, pred_home, pred_away)
    VALUES (%s, %s, %s, %s)
    RETURNING *
"""

# get all predictions for a match — used when recalculating points after result is set
_SQL_GET_PREDICTIONS_FOR_MATCH = """
    SELECT id, user_id, pred_home, pred_away, points_awarded
    FROM predictions
    WHERE match_id = %s
"""

# update points for a single prediction after match result is set
_SQL_UPDATE_PREDICTION_POINTS = """
    UPDATE predictions
    SET points_awarded = %s
    WHERE id = %s
"""

# --- users ---

# check if user exists before saving a prediction
_SQL_GET_USER_BY_ID = """
    SELECT id, nick, email
    FROM users
    WHERE id = %s
"""

# get user by nick — used for login
_SQL_GET_USER_BY_NICK = """
    SELECT id, nick, email, password_hash
    FROM users
    WHERE nick = %s
"""

# create new user account
_SQL_CREATE_USER = """
    INSERT INTO users (nick, email, password_hash)
    VALUES (%s, %s, %s)
    RETURNING id, nick, email
"""

# --- scoring_rules ---

# get scoring config — default id=1 which is the standard ruleset
_SQL_GET_SCORING_RULES = """
    SELECT id, name, exact_pts, diff_pts, tendency_pts
    FROM scoring_rules
    WHERE id = %s
"""

# --- ranking ---

# sum points per user from finished matches only
_SQL_GET_RANKING = """
    SELECT
        u.id   AS user_id,
        u.nick,
        COALESCE(SUM(p.points_awarded), 0) AS total_points
    FROM users u
    LEFT JOIN predictions p ON p.user_id = u.id
    LEFT JOIN matches m     ON p.match_id = m.id AND m.status = 'finished'
    GROUP BY u.id, u.nick
    ORDER BY total_points DESC
"""


def get_all_matches(conn) -> list:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_ALL_MATCHES)
    return cur.fetchall()


def get_match_by_id(conn, match_id: int) -> dict | None:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_MATCH_BY_ID, (match_id,))
    return cur.fetchone()


def set_match_result(conn, match_id: int, home_goals: int, away_goals: int) -> None:
    cur = conn.cursor()
    cur.execute(_SQL_SET_MATCH_RESULT, (home_goals, away_goals, match_id))
    conn.commit()


def create_prediction(conn, user_id: int, match_id: int, pred_home: int, pred_away: int) -> dict:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_CREATE_PREDICTION, (user_id, match_id, pred_home, pred_away))
    conn.commit()
    return cur.fetchone()


def get_predictions_for_match(conn, match_id: int) -> list:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_PREDICTIONS_FOR_MATCH, (match_id,))
    return cur.fetchall()


def update_prediction_points(conn, prediction_id: int, points: int) -> None:
    cur = conn.cursor()
    cur.execute(_SQL_UPDATE_PREDICTION_POINTS, (points, prediction_id))
    # no commit here — caller commits after updating all predictions for the match


def get_user_by_nick(conn, nick: str) -> dict | None:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_USER_BY_NICK, (nick,))
    return cur.fetchone()


def create_user(conn, nick: str, email: str, password_hash: str) -> dict:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_CREATE_USER, (nick, email, password_hash))
    conn.commit()
    return cur.fetchone()


def get_user_by_id(conn, user_id: int) -> dict | None:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_USER_BY_ID, (user_id,))
    return cur.fetchone()


def get_scoring_rules(conn, rules_id: int = 1) -> dict | None:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_SCORING_RULES, (rules_id,))
    return cur.fetchone()


def get_ranking(conn) -> list:
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(_SQL_GET_RANKING)
    return cur.fetchall()
