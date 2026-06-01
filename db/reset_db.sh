#!/bin/bash
docker compose down -v
docker compose up -d

echo "Czekam na PostgreSQL..."
until PGPASSWORD=typer pg_isready -h localhost -U typer -d typer; do sleep 1; done

PGPASSWORD=typer psql -h localhost -U typer -d typer -f db/migrations/001_init.sql
PGPASSWORD=typer psql -h localhost -U typer -d typer -f db/migrations/002_seed.sql
echo "Gotowe."
