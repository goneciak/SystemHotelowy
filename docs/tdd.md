# Opis TDD

Projekt byl rozwijany zgodnie z podejsciem TDD, czyli Test Driven Development.

## Na czym polegalo TDD

Kazda wieksza funkcjonalnosc byla tworzona w cyklu:

1. Napisanie testu opisujacego oczekiwane zachowanie.
2. Uruchomienie testu i otrzymanie bledu.
3. Dodanie minimalnej implementacji.
4. Ponowne uruchomienie testu.
5. Refaktoryzacja lub doprecyzowanie kodu.

Ten cykl odpowiada zasadzie:

```text
red -> green -> refactor
```

## Przyklad 1: Rezerwacja

Najpierw powstal test dla `Rezerwacja.obliczDlugoscPobytu()`.

Test oczekiwal, ze rezerwacja od 10.06.2026 do 13.06.2026 ma dlugosc 3 dni.
Dopiero pozniej dodano model `Rezerwacja` i metode `obliczDlugoscPobytu()`.

Testy dla rezerwacji sprawdzaja tez:

- potwierdzenie rezerwacji
- anulowanie rezerwacji
- modyfikacje dat
- obliczanie dlugosci pobytu
- powiazania z gosciem, pokojami, platnoscia i ocena pobytu

## Przyklad 2: Pokoj

Dla `Pokoj` najpierw powstaly testy dostepnosci:

- pokoj jest dostepny bez rezerwacji
- pokoj nie jest dostepny, gdy termin koliduje z inna rezerwacja
- pokoj jest dostepny, gdy nowy pobyt zaczyna sie w dniu wymeldowania
- anulowana rezerwacja nie blokuje dostepnosci
- pokoj `wylaczony` nie jest dostepny
- pokoj `czyszczenie` nie jest dostepny

Dopiero potem dopracowano `Pokoj.czyDostepny(...)`.

## Przyklad 3: SerwisRezerwacji

Testy dla `SerwisRezerwacji` opisaly:

- utworzenie rezerwacji dla dostepnego pokoju
- brak rezerwacji, gdy pokoj jest zajety
- brak rezerwacji przy niepoprawnym zakresie dat
- wyszukiwanie dostepnych pokoi
- anulowanie rezerwacji
- modyfikacje dat rezerwacji
- integracje z lokalnym repozytorium demo

Dzieki temu serwis zostal napisany jako odpowiedz na konkretne przypadki
uzycia z diagramow.

## Przyklad 4: SerwisZameldowania

Testy dla `SerwisZameldowania` opisaly:

- zameldowanie i zwrocenie PIN-u
- brak zameldowania dla anulowanej rezerwacji
- wymeldowanie i dezaktywacje PIN-u
- brak wymeldowania dla anulowanej rezerwacji

Nastepnie powstala implementacja uzywajaca `ISystemOtwieraniaDrzwi`.

## Przyklad 5: Platnosc

Testy dla `Platnosc` sprawdzaja:

- poprawne wykonanie platnosci przez `ISystemPlatnosci`
- odrzucenie platnosci przez fake system
- odrzucenie kwoty mniejszej lub rownej zero

## Przyklad 6: HotelController

Po zbudowaniu modeli i serwisow dodano `HotelController`. Jego testy
sprawdzaja pelne przeplywy uzywane pozniej przez UI:

- tworzenie rezerwacji na danych demonstracyjnych
- wyszukiwanie pokoi
- zmiane statusu pokoju
- zameldowanie i wymeldowanie
- platnosc
- modyfikacje dat
- anulowanie rezerwacji
- dodanie oceny pobytu

## Testy fake systemow

Dodano tez testy dla fake implementacji:

- `FakeSerwisEmail`
- `FakeSystemPlatnosci`
- `FakeSystemOtwieraniaDrzwi`

Fake systemy sa wazne, poniewaz projekt nie ma prawdziwych integracji.

## Test UI

Na koncu dodano test widgetowy:

- `test/ui/hotel_app_test.dart`

Sprawdza on, czy aplikacja startuje i wyswietla glowny ekran klienta.

## Uruchamianie testow

Wszystkie testy mozna uruchomic poleceniem:

```bash
flutter test
```

Analize statyczna mozna uruchomic poleceniem:

```bash
flutter analyze
```

Aktualny wynik projektu:

- wszystkie testy przechodza
- analiza statyczna nie zglasza problemow

