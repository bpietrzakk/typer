-- push existing scheduled matches to future dates and add new fixtures
-- run on: 2026-06-01

-- update the 3 stale scheduled matches to future kickoff times
UPDATE matches SET kickoff_at = '2026-06-08 13:00:00+00' WHERE id = 6; -- Wieczysta vs Chrobry
UPDATE matches SET kickoff_at = '2026-06-18 20:00:00+00' WHERE id = 7; -- Arsenal vs PSG
UPDATE matches SET kickoff_at = '2026-06-07 17:30:00+00' WHERE id = 8; -- Legia vs Raków

-- new Ekstraklasa fixtures
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status) VALUES
(1, 4, 2, '2026-06-07 15:00:00+00', 'scheduled'), -- Jagiellonia vs Lech
(1, 3, 1, '2026-06-14 17:30:00+00', 'scheduled'), -- Raków vs Legia
(1, 2, 4, '2026-06-21 17:30:00+00', 'scheduled'); -- Lech vs Jagiellonia

-- new Bundesliga fixtures
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status) VALUES
(3, 7, 8, '2026-06-08 17:30:00+00', 'scheduled'), -- Bayern vs Borussia
(3, 9, 7, '2026-06-15 15:30:00+00', 'scheduled'); -- Leverkusen vs Bayern

-- new Liga Mistrzów fixtures
INSERT INTO matches (league_id, home_team_id, away_team_id, kickoff_at, status) VALUES
(4, 12, 13, '2026-06-10 20:45:00+00', 'scheduled'), -- Real Madrid vs Barcelona
(4, 11, 12, '2026-06-17 20:00:00+00', 'scheduled'); -- PSG vs Real Madrid
