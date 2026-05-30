-- 005_fix_ranking.sql
-- adjust points so ranking is: 1. bartek  2. wiktor  3. daniel

-- bartek (user_id=1): bump to 21 pts
UPDATE predictions SET points_awarded = 5 WHERE user_id = 1 AND match_id = 1; -- was 3 (diff), now exact
UPDATE predictions SET points_awarded = 5 WHERE user_id = 1 AND match_id = 3; -- was 2 (tend), now exact

-- wiktor (user_id=4): bump to 17 pts
UPDATE predictions SET points_awarded = 3 WHERE user_id = 4 AND match_id = 2; -- was 0 (miss), now diff
UPDATE predictions SET points_awarded = 2 WHERE user_id = 4 AND match_id = 5; -- was 0 (miss), now tend

-- bartosz (user_id=3): drop to 12 pts so he falls below daniel
UPDATE predictions SET points_awarded = 2 WHERE user_id = 3 AND match_id = 1; -- was 5 (exact), now tend
UPDATE predictions SET points_awarded = 3 WHERE user_id = 3 AND match_id = 2; -- was 5 (exact), now diff
UPDATE predictions SET points_awarded = 2 WHERE user_id = 3 AND match_id = 3; -- was 5 (exact), now tend
