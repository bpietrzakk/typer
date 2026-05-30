-- 004_reseed.sql
-- clear all data and re-seed with new users and real matches

TRUNCATE TABLE private_league_members, private_leagues, predictions, matches, teams, leagues, users, scoring_rules
    RESTART IDENTITY CASCADE;

-- scoring rules
INSERT INTO scoring_rules (name, exact_pts, diff_pts, tendency_pts)
VALUES ('Standardowe', 5, 3, 2);

-- leagues
INSERT INTO leagues (name, country, season) VALUES
    ('Ekstraklasa',   'Polska',  '2024/25'),  -- id=1
    ('1. Liga',       'Polska',  '2024/25'),  -- id=2  (Wieczysta, Chrobry)
    ('Bundesliga',    'Niemcy',  '2024/25'),  -- id=3
    ('Liga Mistrzów', 'Europa',  '2024/25');  -- id=4

-- teams
INSERT INTO teams (name, short_name, league_id) VALUES
    -- Ekstraklasa
    ('Legia Warszawa',      'LEG', 1),  -- id=1
    ('Lech Poznań',         'LEC', 1),  -- id=2
    ('Raków Częstochowa',   'RAK', 1),  -- id=3
    ('Jagiellonia Białystok','JAG', 1), -- id=4
    -- 1. Liga
    ('Wieczysta Kraków',    'WIE', 2),  -- id=5
    ('Chrobry Głogów',      'CHR', 2),  -- id=6
    -- Bundesliga
    ('Bayern München',      'FCB', 3),  -- id=7
    ('Borussia Dortmund',   'BVB', 3),  -- id=8
    ('Bayer Leverkusen',    'B04', 3),  -- id=9
    -- Liga Mistrzów
    ('Arsenal',             'ARS', 4), -- id=10
    ('PSG',                 'PSG', 4), -- id=11
    ('Real Madrid',         'RMA', 4), -- id=12
    ('FC Barcelona',        'BAR', 4); -- id=13

-- users (haslo = login)
INSERT INTO users (nick, email, password_hash) VALUES
    ('bartek',   'bartek@example.com',   'b508f84ec91e4d4ad20a7d99054b2f1e1b3ab311e45edbd639376ef99b73df60'),
    ('daniel',   'daniel@example.com',   'bd3dae5fb91f88a4f0978222dfd58f59a124257cb081486387cbae9df11fb879'),
    ('bartosz',  'bartosz@example.com',  'cb1bb7da519c3d57e7ac473584f667a16d9e24faf148747cf0362183c8edc1ec'),
    ('wiktor',   'wiktor@example.com',   'ba0cc408d52c5965ac804448d36e1b24054a1b3a673d028c383395b61e1c82cf'),
    ('konrad',   'konrad@example.com',   'c0a0d1ca843832dba60f2f3e4fd83ad2116722dfc63479fffc63ddf1382613c8'),
    ('nikodem',  'nikodem@example.com',  'a35541927b24c4f1a603b54f1ade2a88373675cddc699fa94b8dc3e9987ac301'),
    ('sebastian','sebastian@example.com','4dd68e2ab3a30973318ea903e088b3d3480655ef4236109fe47272c1c1582880'),
    ('mateusz',  'mateusz@example.com',  'fe8c433a0e86185e0facbb4c0f4f0cfcc16baff8f2129205c63279fedf2d06b2'),
    ('kamil',    'kamil@example.com',    'caa915ff212f314b9013a3611edca986d5fb8d7cb90f3226176b7364c247ae10');
-- bartek=1, daniel=2, bartosz=3, wiktor=4, konrad=5, nikodem=6, sebastian=7, mateusz=8, kamil=9

-- =========================================================
-- ZAKONCZONE MECZE (status=finished)
-- =========================================================

-- Ekstraklasa: Legia 2:1 Lech (kolejka 30)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES (1, 1, 2, '2026-05-10 17:30:00+00', 2, 1, 'finished');  -- id=1

-- Ekstraklasa: Lech 1:1 Jagiellonia (kolejka 30)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES (1, 2, 4, '2026-05-10 17:30:00+00', 1, 1, 'finished');  -- id=2

-- Bundesliga: Bayern 2:0 Dortmund (kolejka 33)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES (3, 7, 8, '2026-05-17 15:30:00+00', 2, 0, 'finished');  -- id=3

-- Liga Mistrzów: Arsenal 2:1 Real Madrid (półfinał, rewanż)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES (4, 10, 12, '2026-05-07 19:00:00+00', 2, 1, 'finished'); -- id=4

-- Bundesliga: Leverkusen 1:3 Bayern (kolejka 32)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status)
VALUES (3, 9, 7, '2026-05-09 14:30:00+00', 1, 3, 'finished');   -- id=5

-- =========================================================
-- NADCHODZACE MECZE (status=scheduled)
-- =========================================================

-- 1. Liga: Wieczysta Kraków vs Chrobry Głogów (31 maja 15:00 CEST = 13:00 UTC)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status)
VALUES (2, 5, 6, '2026-05-31 13:00:00+00', 'scheduled');        -- id=6

-- Liga Mistrzów: FINAŁ Arsenal vs PSG (31 maja 20:00 CEST = 18:00 UTC)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status)
VALUES (4, 10, 11, '2026-05-31 18:00:00+00', 'scheduled');      -- id=7

-- Ekstraklasa: Legia vs Raków (kolejka 31)
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status)
VALUES (1, 1, 3, '2026-06-01 17:30:00+00', 'scheduled');        -- id=8

-- =========================================================
-- TYPY — mecz 1: Legia 2:1 Lech
-- bartosz: 2:1 exact=5, bartek: 3:2 diff=3, daniel: 1:0 diff=3, wiktor: 2:0 tend=2, konrad: 0:1 miss=0
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (3, 1, 2, 1, 5),  -- bartosz exact
    (1, 1, 3, 2, 3),  -- bartek  diff
    (2, 1, 1, 0, 3),  -- daniel  diff
    (4, 1, 2, 0, 2),  -- wiktor  tend
    (5, 1, 0, 1, 0),  -- konrad  miss
    (7, 1, 2, 1, 5),  -- sebastian exact
    (8, 1, 1, 0, 3);  -- mateusz diff

-- =========================================================
-- TYPY — mecz 2: Lech 1:1 Jagiellonia
-- bartosz: 1:1 exact=5, bartek: 0:0 diff=3, daniel: 2:2 diff=3, wiktor: 1:2 miss=0
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (3, 2, 1, 1, 5),  -- bartosz exact
    (1, 2, 0, 0, 3),  -- bartek  diff (0=0)
    (2, 2, 2, 2, 3),  -- daniel  diff (0=0)
    (4, 2, 1, 2, 0),  -- wiktor  miss
    (7, 2, 0, 1, 0),  -- sebastian miss
    (8, 2, 1, 1, 5);  -- mateusz exact

-- =========================================================
-- TYPY — mecz 3: Bayern 2:0 Dortmund
-- bartosz: 2:0 exact=5, bartek: 1:0 tend=2, daniel: 3:1 diff=3, wiktor: 2:0 exact=5
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (3, 3, 2, 0, 5),  -- bartosz exact
    (1, 3, 1, 0, 2),  -- bartek  tend
    (2, 3, 3, 1, 3),  -- daniel  diff (3-1=2, 2-0=2)
    (4, 3, 2, 0, 5),  -- wiktor  exact
    (6, 3, 1, 1, 0),  -- nikodem miss
    (7, 3, 3, 0, 2),  -- sebastian tend
    (9, 3, 2, 1, 2);  -- kamil tend

-- =========================================================
-- TYPY — mecz 4: Arsenal 2:1 Real Madrid
-- bartosz: 1:0 tend=2, bartek: 2:1 exact=5, daniel: 3:2 diff=3, sebastian: 0:1 miss=0
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (3, 4, 1, 0, 2),  -- bartosz tend
    (1, 4, 2, 1, 5),  -- bartek  exact
    (2, 4, 3, 2, 3),  -- daniel  diff
    (7, 4, 0, 1, 0),  -- sebastian miss
    (4, 4, 2, 1, 5),  -- wiktor  exact
    (8, 4, 1, 0, 2);  -- mateusz tend

-- =========================================================
-- TYPY — mecz 5: Leverkusen 1:3 Bayern
-- bartosz: 0:2 diff=3, bartek: 1:3 diff=3, daniel: 0:3 tend=2
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (3, 5, 0, 2, 3),  -- bartosz diff (-2=-2)
    (1, 5, 1, 3, 3),  -- bartek  diff (-2=-2)
    (2, 5, 0, 3, 2),  -- daniel  tend (gos wygrywa)
    (4, 5, 2, 1, 0),  -- wiktor  miss
    (9, 5, 0, 2, 3);  -- kamil   diff

-- =========================================================
-- TYPY — nadchodzace mecze (bez punktow)
-- =========================================================

-- mecz 6: Wieczysta vs Chrobry
INSERT INTO predictions (user_id, match_id, pred_home, pred_away) VALUES
    (1, 6, 2, 0),
    (2, 6, 1, 1),
    (3, 6, 3, 1),
    (4, 6, 1, 0);

-- mecz 7: FINAŁ Arsenal vs PSG
INSERT INTO predictions (user_id, match_id, pred_home, pred_away) VALUES
    (1, 7, 2, 1),
    (2, 7, 1, 2),
    (3, 7, 2, 0),
    (4, 7, 1, 1),
    (5, 7, 0, 1),
    (6, 7, 2, 2),
    (7, 7, 1, 0),
    (8, 7, 3, 1),
    (9, 7, 2, 1);
