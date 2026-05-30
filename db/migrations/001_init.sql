-- 001_init.sql

CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    nick        VARCHAR(50)  NOT NULL UNIQUE,
    email       VARCHAR(255) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE TABLE leagues (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    country VARCHAR(50)  NOT NULL,
    season  VARCHAR(20)  NOT NULL  -- e.g. '2024/25'
);

CREATE TABLE teams (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    short_name VARCHAR(10)  NOT NULL,
    league_id  INTEGER      NOT NULL REFERENCES leagues(id)
);

CREATE TABLE matches (
    id           SERIAL PRIMARY KEY,
    league_id    INTEGER     NOT NULL REFERENCES leagues(id),
    home_team_id INTEGER     NOT NULL REFERENCES teams(id),
    away_team_id INTEGER     NOT NULL REFERENCES teams(id),
    kickoff_at   TIMESTAMPTZ NOT NULL,
    home_goals   SMALLINT    CHECK (home_goals >= 0),
    away_goals   SMALLINT    CHECK (away_goals >= 0),
    status       VARCHAR(20) NOT NULL DEFAULT 'scheduled'
                             CHECK (status IN ('scheduled', 'finished')),
    CONSTRAINT different_teams CHECK (home_team_id <> away_team_id)
);

CREATE TABLE scoring_rules (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    exact_pts     SMALLINT     NOT NULL DEFAULT 5,
    diff_pts      SMALLINT     NOT NULL DEFAULT 3,
    tendency_pts  SMALLINT     NOT NULL DEFAULT 2
);

CREATE TABLE predictions (
    id             SERIAL PRIMARY KEY,
    user_id        INTEGER     NOT NULL REFERENCES users(id),
    match_id       INTEGER     NOT NULL REFERENCES matches(id),
    pred_home      SMALLINT    NOT NULL CHECK (pred_home >= 0),
    pred_away      SMALLINT    NOT NULL CHECK (pred_away >= 0),
    points_awarded SMALLINT    CHECK (points_awarded >= 0),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, match_id)
);

CREATE TABLE private_leagues (
    id               SERIAL PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    owner_user_id    INTEGER      NOT NULL REFERENCES users(id),
    join_code        VARCHAR(20)  NOT NULL UNIQUE,
    scoring_rules_id INTEGER      NOT NULL REFERENCES scoring_rules(id)
);

CREATE TABLE private_league_members (
    private_league_id INTEGER     NOT NULL REFERENCES private_leagues(id),
    user_id           INTEGER     NOT NULL REFERENCES users(id),
    joined_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (private_league_id, user_id)
);
