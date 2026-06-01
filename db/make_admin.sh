#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Uzycie: ./db/make_admin.sh <nick>"
    exit 1
fi

NICK="$1"

EXISTS=$(PGPASSWORD=typer psql -h localhost -U typer -d typer -tAc \
    "SELECT COUNT(*) FROM users WHERE nick = '$NICK';")

if [ "$EXISTS" -eq 0 ]; then
    echo "Blad: uzytkownik '$NICK' nie istnieje."
    exit 1
fi

PGPASSWORD=typer psql -h localhost -U typer -d typer -c \
    "UPDATE users SET is_admin = TRUE WHERE nick = '$NICK';"

echo "Uzytkownik '$NICK' jest teraz adminem."
