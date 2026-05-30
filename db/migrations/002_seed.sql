-- 002_seed.sql

INSERT INTO scoring_rules (name, exact_pts, diff_pts, tendency_pts)
VALUES ('Standardowe', 5, 3, 2);

INSERT INTO leagues (name, country, season)
VALUES
    ('Ekstraklasa',      'Polska',   '2024/25'),
    ('Bundesliga',       'Niemcy',   '2024/25'),
    ('Liga Mistrzów',    'Europa',   '2024/25');

-- Ekstraklasa teams
INSERT INTO teams (name, short_name, league_id)
VALUES
    ('Legia Warszawa',     'LEG', 1),
    ('Lech Poznań',        'LEC', 1),
    ('Raków Częstochowa',  'RAK', 1),
    ('Wisła Kraków',       'WIS', 1);

-- Bundesliga teams
INSERT INTO teams (name, short_name, league_id)
VALUES
    ('Bayern München',     'FCB', 2),
    ('Borussia Dortmund',  'BVB', 2);

-- Liga Mistrzów teams
INSERT INTO teams (name, short_name, league_id)
VALUES
    ('Real Madrid',        'RMA', 3),
    ('Manchester City',    'MCI', 3);

-- Test users
INSERT INTO users (nick, email)
VALUES
    ('janek',   'janek@example.com'),
    ('kasia',   'kasia@example.com'),
    ('marek',   'marek@example.com'),
    ('zofia',   'zofia@example.com');

-- Matches: mix of future (scheduled) and past (finished)
-- Future kickoffs (well beyond seed date for testing)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status)
VALUES
    (1, 1, 2, NOW() + INTERVAL '7 days',  'scheduled'),   -- Legia vs Lech
    (1, 3, 4, NOW() + INTERVAL '7 days',  'scheduled'),   -- Raków vs Wisła
    (2, 5, 6, NOW() + INTERVAL '3 days',  'scheduled'),   -- Bayern vs BVB
    (3, 7, 8, NOW() + INTERVAL '14 days', 'scheduled');   -- Real vs City

-- Finished matches with goals already set
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES
    (1, 2, 1, NOW() - INTERVAL '7 days', 1, 2, 'finished'),  -- Lech 1:2 Legia
    (2, 6, 5, NOW() - INTERVAL '3 days', 0, 3, 'finished');  -- BVB  0:3 Bayern

-- Predictions for finished match id=5 (Lech 1:2 Legia)
-- janek: dokładny wynik (5 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (1, 5, 1, 2, 5);
-- kasia: trafiona różnica (3 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (2, 5, 0, 1, 3);
-- marek: trafiony rezultat (2 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (3, 5, 1, 3, 2);
-- zofia: pudło (0 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (4, 5, 2, 0, 0);

-- Predictions for finished match id=6 (BVB 0:3 Bayern)
-- janek: trafiony rezultat (2 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (1, 6, 1, 4, 2);
-- kasia: dokładny wynik (5 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (2, 6, 0, 3, 5);
-- marek: pudło (0 pkt)
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded)
VALUES (3, 6, 2, 1, 0);

-- Predictions for scheduled match id=1 (Legia vs Lech) — no points yet
INSERT INTO predictions (user_id, match_id, pred_home, pred_away)
VALUES
    (1, 1, 2, 1),
    (2, 1, 1, 1),
    (3, 1, 0, 0);
