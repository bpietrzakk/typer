import os

from dotenv import load_dotenv
from psycopg2 import pool

# ladujemy zmienne z pliku .env zeby miec dane do polaczenia z baza
load_dotenv()

# zbieramy parametry polaczenia ze zmiennych srodowiskowych
_host     = os.getenv("POSTGRES_HOST", "localhost")
_port     = os.getenv("POSTGRES_PORT", "5432")
_user     = os.getenv("POSTGRES_USER", "typer")
_password = os.getenv("POSTGRES_PASSWORD", "typer")
_dbname   = os.getenv("POSTGRES_DB", "typer")

# tworzymy pule polaczen przy starcie aplikacji
# minconn=1 czyli zawsze trzymamy jedno gotowe polaczenie
# maxconn=5 czyli maksymalnie 5 jednoczesnych polaczen do bazy
_pool = pool.SimpleConnectionPool(
    minconn=1,
    maxconn=5,
    host=_host,
    port=_port,
    user=_user,
    password=_password,
    dbname=_dbname,
)


def get_conn():
    # pobieramy wolne polaczenie z puli i zwracamy do uzytku
    return _pool.getconn()


def release_conn(conn) -> None:
    # oddajemy polaczenie z powrotem do puli zeby inni mogli uzyc
    _pool.putconn(conn)
