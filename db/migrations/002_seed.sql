-- 002_seed.sql

INSERT INTO scoring_rules (name, exact_pts, diff_pts, tendency_pts)
VALUES ('Standardowe', 5, 3, 2);

INSERT INTO leagues (name, country, season) VALUES
    ('Ekstraklasa',   'Polska',  '2024/25'),  -- id=1
    ('1. Liga',       'Polska',  '2024/25'),  -- id=2
    ('Bundesliga',    'Niemcy',  '2024/25'),  -- id=3
    ('Liga Mistrzów', 'Europa',  '2024/25');  -- id=4

INSERT INTO teams (name, short_name, league_id) VALUES
    -- Ekstraklasa
    ('Legia Warszawa',       'LEG', 1),  -- id=1
    ('Lech Poznań',          'LEC', 1),  -- id=2
    ('Raków Częstochowa',    'RAK', 1),  -- id=3
    ('Jagiellonia Białystok','JAG', 1),  -- id=4
    -- 1. Liga
    ('Wieczysta Kraków',     'WIE', 2),  -- id=5
    ('Chrobry Głogów',       'CHR', 2),  -- id=6
    -- Bundesliga
    ('Bayern München',       'FCB', 3),  -- id=7
    ('Borussia Dortmund',    'BVB', 3),  -- id=8
    ('Bayer Leverkusen',     'B04', 3),  -- id=9
    -- Liga Mistrzów
    ('Arsenal',              'ARS', 4),  -- id=10
    ('PSG',                  'PSG', 4),  -- id=11
    ('Real Madrid',          'RMA', 4),  -- id=12
    ('FC Barcelona',         'BAR', 4);  -- id=13

-- passwords are sha256(nick)
INSERT INTO users (nick, email, password_hash) VALUES
    ('bartek',    'bartek@example.com',    'b508f84ec91e4d4ad20a7d99054b2f1e1b3ab311e45edbd639376ef99b73df60'),  -- id=1
    ('daniel',    'daniel@example.com',    'bd3dae5fb91f88a4f0978222dfd58f59a124257cb081486387cbae9df11fb879'),   -- id=2
    ('bartosz',   'bartosz@example.com',   'cb1bb7da519c3d57e7ac473584f667a16d9e24faf148747cf0362183c8edc1ec'),  -- id=3
    ('wiktor',    'wiktor@example.com',    'ba0cc408d52c5965ac804448d36e1b24054a1b3a673d028c383395b61e1c82cf'),   -- id=4
    ('konrad',    'konrad@example.com',    'c0a0d1ca843832dba60f2f3e4fd83ad2116722dfc63479fffc63ddf1382613c8'),   -- id=5
    ('nikodem',   'nikodem@example.com',   'a35541927b24c4f1a603b54f1ade2a88373675cddc699fa94b8dc3e9987ac301'),  -- id=6
    ('sebastian', 'sebastian@example.com', '4dd68e2ab3a30973318ea903e088b3d3480655ef4236109fe47272c1c1582880'), -- id=7
    ('mateusz',   'mateusz@example.com',   'fe8c433a0e86185e0facbb4c0f4f0cfcc16baff8f2129205c63279fedf2d06b2'),  -- id=8
    ('kamil',     'kamil@example.com',     'caa915ff212f314b9013a3611edca986d5fb8d7cb90f3226176b7364c247ae10');  -- id=9

-- =========================================================
-- FINISHED MATCHES
-- =========================================================

INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status) VALUES
    (1, 1,  2,  '2026-05-10 17:30:00+00', 2, 1, 'finished'),  -- id=1  Legia 2:1 Lech
    (1, 2,  4,  '2026-05-10 17:30:00+00', 1, 1, 'finished'),  -- id=2  Lech 1:1 Jagiellonia
    (3, 7,  8,  '2026-05-17 15:30:00+00', 2, 0, 'finished'),  -- id=3  Bayern 2:0 Dortmund
    (4, 10, 12, '2026-05-07 19:00:00+00', 2, 1, 'finished'),  -- id=4  Arsenal 2:1 Real Madrid
    (3, 9,  7,  '2026-05-09 14:30:00+00', 1, 3, 'finished');  -- id=5  Leverkusen 1:3 Bayern

-- =========================================================
-- SCHEDULED MATCHES
-- =========================================================

INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status) VALUES
    (2, 5,  6,  '2026-06-08 13:00:00+00', 'scheduled'),  -- id=6  Wieczysta vs Chrobry
    (4, 10, 11, '2026-06-18 20:00:00+00', 'scheduled'),  -- id=7  Arsenal vs PSG (finał LM)
    (1, 1,  3,  '2026-06-07 17:30:00+00', 'scheduled'),  -- id=8  Legia vs Raków
    (1, 4,  2,  '2026-06-07 15:00:00+00', 'scheduled'),  -- id=9  Jagiellonia vs Lech
    (1, 3,  1,  '2026-06-14 17:30:00+00', 'scheduled'),  -- id=10 Raków vs Legia
    (1, 2,  4,  '2026-06-21 17:30:00+00', 'scheduled'),  -- id=11 Lech vs Jagiellonia
    (3, 7,  8,  '2026-06-08 17:30:00+00', 'scheduled'),  -- id=12 Bayern vs Borussia
    (3, 9,  7,  '2026-06-15 15:30:00+00', 'scheduled'),  -- id=13 Leverkusen vs Bayern
    (4, 12, 13, '2026-06-10 20:45:00+00', 'scheduled'),  -- id=14 Real Madrid vs Barcelona
    (4, 11, 12, '2026-06-17 20:00:00+00', 'scheduled');  -- id=15 PSG vs Real Madrid

-- =========================================================
-- PREDICTIONS — mecz 1: Legia 2:1 Lech
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (1, 1, 3, 2, 5),  -- bartek    diff→exact (ranking fix)
    (2, 1, 1, 0, 3),  -- daniel    diff
    (3, 1, 2, 1, 2),  -- bartosz   exact→tend (ranking fix)
    (4, 1, 2, 0, 2),  -- wiktor    tend
    (5, 1, 0, 1, 0),  -- konrad    miss
    (7, 1, 2, 1, 5),  -- sebastian exact
    (8, 1, 1, 0, 3);  -- mateusz   diff

-- =========================================================
-- PREDICTIONS — mecz 2: Lech 1:1 Jagiellonia
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (1, 2, 0, 0, 3),  -- bartek    diff (0=0)
    (2, 2, 2, 2, 3),  -- daniel    diff (0=0)
    (3, 2, 1, 1, 3),  -- bartosz   exact→diff (ranking fix)
    (4, 2, 1, 2, 3),  -- wiktor    miss→diff (ranking fix)
    (7, 2, 0, 1, 0),  -- sebastian miss
    (8, 2, 1, 1, 5);  -- mateusz   exact

-- =========================================================
-- PREDICTIONS — mecz 3: Bayern 2:0 Dortmund
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (1, 3, 1, 0, 5),  -- bartek    tend→exact (ranking fix)
    (2, 3, 3, 1, 3),  -- daniel    diff (3-1=2, 2-0=2)
    (3, 3, 2, 0, 2),  -- bartosz   exact→tend (ranking fix)
    (4, 3, 2, 0, 5),  -- wiktor    exact
    (6, 3, 1, 1, 0),  -- nikodem   miss
    (7, 3, 3, 0, 2),  -- sebastian tend
    (9, 3, 2, 1, 2);  -- kamil     tend

-- =========================================================
-- PREDICTIONS — mecz 4: Arsenal 2:1 Real Madrid
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (1, 4, 2, 1, 5),  -- bartek    exact
    (2, 4, 3, 2, 3),  -- daniel    diff
    (3, 4, 1, 0, 2),  -- bartosz   tend
    (4, 4, 2, 1, 5),  -- wiktor    exact
    (7, 4, 0, 1, 0),  -- sebastian miss
    (8, 4, 1, 0, 2);  -- mateusz   tend

-- =========================================================
-- PREDICTIONS — mecz 5: Leverkusen 1:3 Bayern
-- =========================================================
INSERT INTO predictions (user_id, match_id, pred_home, pred_away, points_awarded) VALUES
    (1, 5, 1, 3, 3),  -- bartek    diff (-2=-2)
    (2, 5, 0, 3, 2),  -- daniel    tend
    (3, 5, 0, 2, 3),  -- bartosz   diff (-2=-2)
    (4, 5, 2, 1, 2),  -- wiktor    miss→tend (ranking fix)
    (9, 5, 0, 2, 3);  -- kamil     diff

-- ranking: bartek=21, wiktor=17, daniel=14, bartosz=12, mateusz=10, sebastian=7, kamil=5
-- scheduled matches have no seeded predictions — users add their own through the API

-- bartek is the admin
UPDATE users SET is_admin = TRUE WHERE nick = 'bartek';
