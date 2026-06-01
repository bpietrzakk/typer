-- access_schema.sql
-- Schemat bazy danych Typer Ligowy w dialekcie Microsoft Access (Jet SQL)
-- Wklejaj kolejne bloki po jednym w: Create -> Query Design -> SQL View -> Run
-- Kolejnosc tworzenia tabel jest wazna (foreign keys)

-- 1. users
CREATE TABLE users (
    id            COUNTER   CONSTRAINT pk_users PRIMARY KEY,
    nick          TEXT(50)  NOT NULL,
    email         TEXT(255) NOT NULL,
    password_hash TEXT(64)  NOT NULL,
    created_at    DATETIME  DEFAULT Now(),
    CONSTRAINT uq_users_nick  UNIQUE (nick),
    CONSTRAINT uq_users_email UNIQUE (email)
);

-- 2. leagues
CREATE TABLE leagues (
    id      COUNTER   CONSTRAINT pk_leagues PRIMARY KEY,
    name    TEXT(100) NOT NULL,
    country TEXT(50)  NOT NULL,
    season  TEXT(20)  NOT NULL
);

-- 3. scoring_rules
CREATE TABLE scoring_rules (
    id           COUNTER   CONSTRAINT pk_scoring_rules PRIMARY KEY,
    name         TEXT(100) NOT NULL,
    exact_pts    SHORT     NOT NULL,
    diff_pts     SHORT     NOT NULL,
    tendency_pts SHORT     NOT NULL
);

-- 4. teams (wymaga: leagues)
CREATE TABLE teams (
    id         COUNTER   CONSTRAINT pk_teams PRIMARY KEY,
    name       TEXT(100) NOT NULL,
    short_name TEXT(10)  NOT NULL,
    league_id  INTEGER   NOT NULL,
    CONSTRAINT fk_teams_league FOREIGN KEY (league_id) REFERENCES leagues(id)
);

-- 5. matches (wymaga: leagues, teams)
CREATE TABLE matches (
    id           COUNTER  CONSTRAINT pk_matches PRIMARY KEY,
    league_id    INTEGER  NOT NULL,
    home_team_id INTEGER  NOT NULL,
    away_team_id INTEGER  NOT NULL,
    kickoff_at   DATETIME NOT NULL,
    home_goals   SHORT,
    away_goals   SHORT,
    status       TEXT(20) NOT NULL,
    CONSTRAINT fk_matches_league    FOREIGN KEY (league_id)    REFERENCES leagues(id),
    CONSTRAINT fk_matches_home_team FOREIGN KEY (home_team_id) REFERENCES teams(id),
    CONSTRAINT fk_matches_away_team FOREIGN KEY (away_team_id) REFERENCES teams(id)
);

-- 6. predictions (wymaga: users, matches)
CREATE TABLE predictions (
    id             COUNTER  CONSTRAINT pk_predictions PRIMARY KEY,
    user_id        INTEGER  NOT NULL,
    match_id       INTEGER  NOT NULL,
    pred_home      SHORT    NOT NULL,
    pred_away      SHORT    NOT NULL,
    points_awarded SHORT,
    created_at     DATETIME DEFAULT Now(),
    CONSTRAINT uq_predictions       UNIQUE (user_id, match_id),
    CONSTRAINT fk_predictions_user  FOREIGN KEY (user_id)  REFERENCES users(id),
    CONSTRAINT fk_predictions_match FOREIGN KEY (match_id) REFERENCES matches(id)
);

-- UWAGI:
-- COUNTER     = odpowiednik SERIAL/AUTOINCREMENT z PostgreSQL
-- SHORT       = odpowiednik SMALLINT
-- TEXT(n)     = odpowiednik VARCHAR(n)
-- DATETIME    = odpowiednik TIMESTAMPTZ
-- DEFAULT Now() = odpowiednik DEFAULT NOW()
-- Constrainty CHECK (np. status IN ('scheduled','finished')) Access nie obsluguje w SQL
-- Mozna je dodac recznie przez widok projektu tabeli -> Validation Rule
