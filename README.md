# Testowanie oprogramownia - EPC Simulator - Grupa 5

## Autorzy:
- Sandra Wachowicz
- Zuzanna Zawartka 
- Kacper Zięba
- Bartłomiej Żądło

## Zawartość repozytorium
Repozytorium zawiera 31 testów wykonanych w Robot Framework.
- Testy zostały podzielone na 3 pliki w folderze `/tests`.
- Raporty i logi są umieszczone w folderze `/results`.
- Pełen raport w posciaci pliku .xlsx znajduje się w pliku `Raport_z_testow_gr5.xlsx`.

## Testy
Wykonaliśmy łącznie **31** testów z czego:
- **23** zakończone pozytywnie.
- **8** zakończonych niepowodzeniem.

## Defekty 
Znaleźliśmy łącznie 9 defektów:
- **DEF-001** - System odrzuca prawidłowy UE ID o wartości 0.
- **DEF-002** - Niewłaściwy komunikat błędu przy usuwaniu Bearera spoza zakresu.
- **DEF-003** - Akceptacja transferu powyżej limitu 100 Mbps przy użyciu parametru Mbps.
- **DEF-004** - Akceptacja fizycznie niemożliwych, ujemnych wartości prędkości transferu (np. -10 Mbps).
- **DEF-005** - Akceptacja transferu powyżej limitu 100 Mbps przy użyciu parametru kbps.
- **DEF-006** - Brak weryfikacji sumarycznego limitu 100 Mbps na całe urządzenie UE.
- **DEF-007** - Brak implementacji funkcjonalności „Stop all traffic”.
- **DEF-008** - Niespójność dokumentacji z API – brak informacji o konieczności przesyłania wymaganego parametru „protocol”.
- **DEF-009** - Brak implementacji statystyk sumarycznych dla wszystkich bearerów danego UE.
