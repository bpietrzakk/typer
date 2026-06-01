"""
mongo_seed.py — synchronizuje dane z PostgreSQL do MongoDB

Czyta aktualne dane z PostgreSQL i wgrywa je do MongoDB.
Uruchom po kazdej zmianie danych w PostgreSQL:
    uv run python db/mongo_seed.py
"""

import os
import psycopg2
import psycopg2.extras
from pymongo import MongoClient

# ── połączenia ─────────────────────────────────────────────────────────────
pg = psycopg2.connect(
    host=os.getenv("POSTGRES_HOST", "localhost"),
    dbname=os.getenv("POSTGRES_DB", "typer"),
    user=os.getenv("POSTGRES_USER", "typer"),
    password=os.getenv("POSTGRES_PASSWORD", "typer"),
)
cur = pg.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

mongo = MongoClient(os.getenv("MONGO_URL", "mongodb://localhost:27017"))
db = mongo["typer"]

def sync(collection_name, rows):
    db[collection_name].drop()
    if rows:
        # PostgreSQL id → MongoDB _id
        docs = [{**dict(r), "_id": r["id"]} for r in rows]
        for d in docs:
            del d["id"]
        db[collection_name].insert_many(docs)
    print(f"  {collection_name}: {len(rows)} dokumentów")

# ── scoring_rules ──────────────────────────────────────────────────────────
cur.execute("SELECT * FROM scoring_rules ORDER BY id")
sync("scoring_rules", cur.fetchall())

# ── leagues ────────────────────────────────────────────────────────────────
cur.execute("SELECT * FROM leagues ORDER BY id")
sync("leagues", cur.fetchall())

# ── teams ──────────────────────────────────────────────────────────────────
cur.execute("SELECT * FROM teams ORDER BY id")
sync("teams", cur.fetchall())

# ── users (bez password_hash — nie ma sensu trzymac hashy w drugiej bazie) ─
cur.execute("SELECT id, nick, email, is_admin, created_at FROM users ORDER BY id")
sync("users", cur.fetchall())

# ── matches (z osadzonymi nazwami drużyn — typowe dla MongoDB) ─────────────
cur.execute("""
    SELECT
        m.id,
        m.league_id,
        l.name  AS league_name,
        m.home_team_id,
        ht.name AS home_team,
        m.away_team_id,
        at.name AS away_team,
        m.kickoff_at,
        m.home_goals,
        m.away_goals,
        m.status
    FROM matches m
    JOIN leagues l  ON m.league_id    = l.id
    JOIN teams ht   ON m.home_team_id = ht.id
    JOIN teams at   ON m.away_team_id = at.id
    ORDER BY m.kickoff_at
""")
rows = cur.fetchall()
db["matches"].drop()
if rows:
    docs = []
    for r in rows:
        d = dict(r)
        d["_id"] = d.pop("id")
        # kickoff_at to datetime — MongoDB go przyjmuje bezpośrednio
        docs.append(d)
    db["matches"].insert_many(docs)
print(f"  matches: {len(rows)} dokumentów")

# ── predictions (z osadzonymi danymi gracza i meczu) ──────────────────────
cur.execute("""
    SELECT
        p.id,
        p.user_id,
        u.nick AS user_nick,
        p.match_id,
        ht.name AS home_team,
        at.name AS away_team,
        m.kickoff_at,
        m.status,
        p.pred_home,
        p.pred_away,
        p.points_awarded,
        p.created_at
    FROM predictions p
    JOIN users u    ON p.user_id  = u.id
    JOIN matches m  ON p.match_id = m.id
    JOIN teams ht   ON m.home_team_id = ht.id
    JOIN teams at   ON m.away_team_id = at.id
    ORDER BY p.id
""")
rows = cur.fetchall()
db["predictions"].drop()
if rows:
    docs = [{**dict(r), "_id": r["id"]} for r in rows]
    for d in docs:
        del d["id"]
    db["predictions"].insert_many(docs)
print(f"  predictions: {len(rows)} dokumentów")

cur.close()
pg.close()
mongo.close()
print("Synchronizacja zakończona.")
