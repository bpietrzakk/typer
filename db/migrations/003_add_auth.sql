-- 003_add_auth.sql
-- add password_hash column to users
-- existing seed users get password = their nick (sha256)

ALTER TABLE users ADD COLUMN password_hash VARCHAR(64);

UPDATE users SET password_hash = '08d19e7c57f32436fcef026c56bf2c3332549b4ced8ae29e60b34e385dfca747' WHERE nick = 'janek';
UPDATE users SET password_hash = 'af212e2d0a13e2dc41c2529dfaa032429b891ce580e7d763f164647e0f3c79f0' WHERE nick = 'kasia';
UPDATE users SET password_hash = 'ab811996cd311d9572634ccde116addce0631d9c122ca89cae6c3b2b055c45fe' WHERE nick = 'marek';
UPDATE users SET password_hash = '77a5669d1fa6b1b64a4eb95d8ec93bfde20477b2398c740870e04ea48d238ce9' WHERE nick = 'zofia';

ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL;
