from domain.scoring import calculate_points

# standardowe reguly punktacji — takie same jak w tabeli scoring_rules w bazie
RULES = {"exact_pts": 5, "diff_pts": 3, "tendency_pts": 2}


# dokladny wynik — typujemy 2:1 trafiamy 2:1
def test_dokladny_wynik():
    assert calculate_points(2, 1, 2, 1, RULES) == 5


# trafiona roznica bramek — typujemy 2:1 rzeczywisty 3:2 (roznica +1 = +1)
def test_roznica_bramek_przesuniete():
    assert calculate_points(2, 1, 3, 2, RULES) == 3


# trafiona roznica bramek — typujemy 2:1 rzeczywisty 1:0 (roznica +1 = +1)
def test_roznica_bramek_inna_skala():
    assert calculate_points(2, 1, 1, 0, RULES) == 3


# trafiony tylko rezultat — typujemy 2:1 rzeczywisty 4:0 (wygrana gospod ale roznica inna)
def test_trafiony_rezultat():
    assert calculate_points(2, 1, 4, 0, RULES) == 2


# remis trafiony ale nie dokladny — dostaje roznice (0=0) a nie rezultat
def test_remis_niedokladny_wyzszy_wynik():
    assert calculate_points(1, 1, 2, 2, RULES) == 3


# remis trafiony ale nie dokladny — 0:0 zamiast 1:1
def test_remis_niedokladny_nizszy_wynik():
    assert calculate_points(1, 1, 0, 0, RULES) == 3


# pudlo — typujemy wygrana gospod a wygral gosc
def test_pudlo_odwrocony_rezultat():
    assert calculate_points(2, 1, 0, 2, RULES) == 0


# pudlo — typujemy remis a wygrali gospodarze
def test_pudlo_remis_zamiast_wygranej():
    assert calculate_points(0, 0, 1, 0, RULES) == 0
