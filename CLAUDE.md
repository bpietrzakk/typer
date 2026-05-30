# Typer Ligowy

Aplikacja do typowania wyników meczów piłkarskich (Ekstraklasa, Bundesliga, Liga Mistrzów) z systemem punktacji i rankingiem. Projekt zaliczeniowy z baz danych — własny schemat (5–9 tabel) + interfejs graficzny.

---

## ŻELAZNE ZASADY (czytaj na początku każdej sesji)

1. **Funkcja punktująca jest czysta** — bez bazy, bez UI, bez side effects. Mieszka w `domain/scoring.py`. Każda zmiana logiki = nowe asercje w `tests/test_scoring.py` **przed** zmianą implementacji.
2. **Warstwy się nie krzyżują.** Logika domenowa nie importuje `streamlit` ani `psycopg2`. UI nie wykonuje SQL — chodzi przez funkcje z `db/`.
3. **Sekrety przez `.env`** (hasło do bazy, w przyszłości klucze API). NIGDY w kodzie ani w repo. `.env` jest w `.gitignore`, `.env.example` w repo.
4. **Migracje schematu są wersjonowane** w `db/migrations/NNN_nazwa.sql`. Zmieniasz schemat → nowy plik migracji, nie edytuj wcześniejszych.
5. **Małe kroki.** Jedno zadanie z MVP-checklisty naraz. Po skończeniu — odpal, sprawdź, dopiero potem następne.

---

## Stack

- **Baza:** PostgreSQL 16 (w Dockerze)
- **Język:** Python 3.11+
- **UI:** Streamlit
- **Dostęp do DB:** `psycopg2-binary` + jawne SQL-e (bez ORM — chodzi o to, żeby było widać SQL na zaliczeniu i w sprawozdaniu)
- **Testy:** pytest
- **Format/lint:** ruff

---

## Reguły biznesowe — Punktacja

Trzy progi, **liczy się najwyższy**, do którego trafienie się łapie. Punkty NIE sumują się.

| Próg | Punkty | Warunek |
|------|--------|---------|
| Dokładny wynik | 5 | `th == rh AND ta == ra` |
| Trafiona różnica bramek | 3 | `th - ta == rh - ra` (i nie dokładny) |
| Trafiony tylko rezultat | 2 | `sign(th - ta) == sign(rh - ra)` (i nie różnica) |
| Pudło | 0 | inaczej |

(`th, ta` = typowane bramki gospodarz/gość; `rh, ra` = rzeczywiste.)

**Remisy:** każdy trafiony remis, który nie jest dokładny, łapie się od razu na "różnicę" (0 = 0), więc dostaje 3, nigdy 2. To jest zamierzone.

Wartości punktów są **konfigurowalne** — trzymane w tabeli `scoring_rules`. Funkcja punktująca przyjmuje je jako argument, nie hardkoduje 5/3/2.

### Przykłady (= testy jednostkowe do `tests/test_scoring.py`)

| Typ | Wynik | Oczekiwane punkty |
|-----|-------|-------------------|
| 2:1 | 2:1 | 5 |
| 2:1 | 3:2 | 3 |
| 2:1 | 1:0 | 3 |
| 2:1 | 4:0 | 2 |
| 1:1 | 2:2 | 3 |
| 1:1 | 0:0 | 3 |
| 2:1 | 0:2 | 0 |
| 0:0 | 1:0 | 0 |

---

## Reguły biznesowe — Deadline typowania

- Typ można dodać/edytować **tylko jeśli `kickoff_at > teraz`**. Po rozpoczęciu meczu UI blokuje formularz, a walidacja w warstwie domenowej dodatkowo odrzuca taki zapis (defense in depth).
- Mecz ma status: `scheduled` → `finished`. Tylko `finished` ma wpisane `home_goals`/`away_goals`.
- Operacja "ustaw wynik meczu" przelicza punkty wszystkim typom danego meczu i zmienia status na `finished`. Jedna funkcja w `domain/match_results.py` — to jedyne miejsce, w którym powstaje `points_awarded`.

---

## Architektura — warstwy

```
UI (Streamlit, ui/)
   ↓ wywołuje
Logika domenowa (domain/)        ← czysta, testowana, przenośna do Javy
   ↓ używa
Dostęp do danych (db/)            ← funkcje opakowujące SQL
   ↓
PostgreSQL
```

UI nigdy nie sięga do `db/` z pominięciem `domain/`. To pozwoli później wystawić REST API (np. w Spring Boot) na tej samej warstwie domenowej.

---

## Model danych (~8 tabel)

- `users` — gracze: `id, nick, email, created_at`
- `leagues` — rozgrywki: `id, name, country, season`
- `teams` — drużyny: `id, name, short_name, league_id`
- `matches` — mecze: `id, league_id, home_team_id, away_team_id, kickoff_at, home_goals, away_goals, status`
- `predictions` — typy: `id, user_id, match_id, pred_home, pred_away, points_awarded, created_at`. UNIQUE `(user_id, match_id)`.
- `scoring_rules` — konfiguracja punktów: `id, name, exact_pts, diff_pts, tendency_pts`
- `private_leagues` — prywatne ligi: `id, name, owner_user_id, join_code, scoring_rules_id`
- `private_league_members` — łącząca M:N: `private_league_id, user_id, joined_at`

**Ranking** to zapytanie, nie tabela: `SELECT user_id, SUM(points_awarded) FROM predictions JOIN matches WHERE matches.status='finished' GROUP BY user_id ORDER BY SUM DESC` — opcjonalnie scope'owane do prywatnej ligi/sezonu.

---

## Układ katalogów

```
typer/
├── CLAUDE.md
├── README.md
├── .env.example
├── .gitignore
├── requirements.txt
├── docker-compose.yml          # PostgreSQL
├── app.py                      # entry point Streamlit
├── domain/
│   ├── __init__.py
│   ├── scoring.py              # CZYSTA funkcja punktująca
│   ├── match_results.py        # ustaw wynik + przelicz punkty
│   └── predictions.py          # walidacja deadline'u
├── db/
│   ├── __init__.py
│   ├── connection.py           # pool / get_conn()
│   ├── queries.py              # parametryzowane SQL-e
│   └── migrations/
│       ├── 001_init.sql
│       └── 002_seed.sql
├── ui/
│   ├── matches_view.py         # ekran typowania
│   ├── ranking_view.py
│   └── admin_view.py           # wpisywanie wyników
└── tests/
    ├── test_scoring.py
    └── test_predictions.py
```

---

## Konwencje

- Polskie nazwy w UI (etykiety, komunikaty), **angielskie w kodzie** (zmienne, funkcje, kolumny DB).
- `snake_case` w Pythonie i SQL.
- Funkcje w `domain/` — pure, bez I/O. Cały I/O robi `db/` i `ui/`.
- SQL trzymany w `db/queries.py` jako stałe stringi, parametryzowany przez `%s` (NIGDY f-stringi z danymi użytkownika — SQL injection).
- Importy: `domain` nie importuje z `db` ani `ui`. `db` nie importuje z `ui`.

---

## Jak odpalić lokalnie

```bash
# 1. baza
docker compose up -d

# 2. migracje
psql -h localhost -U typer -d typer -f db/migrations/001_init.sql
psql -h localhost -U typer -d typer -f db/migrations/002_seed.sql

# 3. środowisko Pythona
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt

# 4. aplikacja
streamlit run app.py

# 5. testy
pytest
```

---

## MVP — definicja "gotowe"

- [ ] Schemat z 7-8 tabelami + skrypt seed (jedna kolejka meczów, 3-4 userów, kilka typów).
- [ ] Funkcja `oblicz_punkty(pred_home, pred_away, real_home, real_away, rules) -> int` w `domain/scoring.py`, z 8 testami z tabeli wyżej.
- [ ] Ekran w Streamlit: lista nadchodzących meczów + formularz typu (zablokowany po kickoffie).
- [ ] Ekran rankingu: tabela userów posortowana po sumie punktów (z możliwością filtrowania po lidze).
- [ ] Panel admina: wpisz wynik meczu → automatyczne przeliczenie punktów wszystkim typom.
- [ ] `README.md` z opisem uruchomienia + diagram ER (np. dbdiagram.io) do sprawozdania.

---

## Workflow z Claude Code

- **Plan mode** (`Shift+Tab` dwa razy) dla każdego zadania, które dotyka > 1 pliku. Przeczytaj plan, popraw jeśli trzeba, dopiero wtedy zatwierdź.
- Jedno zadanie z MVP-checklisty naraz. Po każdym — odpal, kliknij ręcznie, dopiero potem następne.
- Zmiana logiki punktacji = **najpierw test, potem implementacja**.
- Po większym kawałku poproś o wytłumaczenie diffa ("czemu tak, jakie kompromisy") — to mój sposób na naukę, nie pomijaj tego.
- `/clear` między zupełnie różnymi zadaniami, żeby kontekst nie zaśmiecał.

---

## Co NIE wchodzi w MVP (zaplanowane do "rozwijania" później)

- Logowanie/rejestracja (na razie userzy ustawiani w seedzie).
- Auto-pobieranie wyników z football-data.org API.
- Prywatne ligi z kodem dołączania (schemat już to przewiduje).
- Wykresy, statystyki historyczne, widok per-kolejka.
- REST API wystawione z `domain/` (kandydat na przepisanie do Spring Boot w Javie).