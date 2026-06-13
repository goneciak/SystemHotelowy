# Opis architektury

Projekt jest aplikacja Flutter dzialajaca lokalnie, bez backendu i bez bazy
danych. Architektura zostala podzielona na kilka warstw.

## Warstwa UI

Pliki:

- `lib/main.dart`
- `lib/ui/hotel_app.dart`
- `lib/ui/screens/hotel_dashboard_screen.dart`

Odpowiedzialnosc:

- wyswietlanie ekranow
- obsluga formularzy
- wywolanie metod `HotelController`
- prezentacja danych z modeli

UI nie zawiera logiki biznesowej. Nie sprawdza samodzielnie dostepnosci pokoju
ani nie oblicza kosztow pobytu. Te zadania sa w modelach i serwisach.

## Warstwa kontrolera

Plik:

- `lib/controllers/hotel_controller.dart`

Odpowiedzialnosc:

- laczy UI z serwisami
- przechowuje referencje do lokalnego repozytorium
- tworzy i konfiguruje fake systemy
- udostepnia proste metody dla UI

`HotelController` jest dodatkiem technicznym poza diagramami. Zostal dodany,
aby UI nie musial bezposrednio laczyc wielu serwisow i list danych.

## Warstwa danych

Plik:

- `lib/data/lokalne_repozytorium_hotelu.dart`

Odpowiedzialnosc:

- przechowuje lokalne dane demonstracyjne
- udostepnia liste pokoi
- udostepnia liste uzytkownikow
- udostepnia liste rezerwacji
- pozwala wyszukac pokoj lub goscia po id

Ta warstwa zastepuje baze danych w projekcie pokazowym.

## Warstwa serwisow

Pliki:

- `lib/services/serwis_rezerwacji.dart`
- `lib/services/serwis_zameldowania.dart`

Odpowiedzialnosc `SerwisRezerwacji`:

- utworzenie rezerwacji
- znalezienie dostepnych pokoi
- anulowanie rezerwacji
- modyfikacja dat rezerwacji
- wyslanie potwierdzenia przez `ISerwisEmail`

Odpowiedzialnosc `SerwisZameldowania`:

- zameldowanie
- wygenerowanie PIN-u
- wymeldowanie
- dezaktywacja PIN-u
- zmiana statusu pokoju

## Warstwa modeli

Pliki:

- `lib/models/uzytkownik.dart`
- `lib/models/gosc.dart`
- `lib/models/recepcjonista.dart`
- `lib/models/rezerwacja.dart`
- `lib/models/pokoj.dart`
- `lib/models/platnosc.dart`
- `lib/models/ocena_pobytu.dart`

Odpowiedzialnosc:

- przechowywanie danych domenowych
- prosta logika zwiazana bezposrednio z dana klasa

Przyklady:

- `Pokoj.czyDostepny(...)`
- `Pokoj.obliczKoszt(...)`
- `Rezerwacja.obliczDlugoscPobytu()`
- `Platnosc.wykonajPlatnosc()`
- `Gosc.dodajPunktyLojalnosciowe(...)`

## Warstwa interfejsow

Pliki:

- `lib/interfaces/i_serwis_email.dart`
- `lib/interfaces/i_system_platnosci.dart`
- `lib/interfaces/i_system_otwierania_drzwi.dart`

Interfejsy wynikaja z diagramu klas. Oddzielaja logike aplikacji od systemow,
ktore w prawdziwym projekcie bylyby zewnetrzne.

## Warstwa fake implementacji

Pliki:

- `lib/fakes/fake_serwis_email.dart`
- `lib/fakes/fake_system_platnosci.dart`
- `lib/fakes/fake_system_otwierania_drzwi.dart`

Odpowiedzialnosc:

- symulacja systemu email
- symulacja systemu platnosci
- symulacja systemu otwierania drzwi

Fake implementacje sa potrzebne, bo projekt ma dzialac lokalnie bez backendu.

## Przeplyw danych

Typowy przeplyw wyglada tak:

```text
UI
  -> HotelController
    -> SerwisRezerwacji / SerwisZameldowania
      -> Modele
      -> Interfejsy
        -> Fake implementacje
    -> LokalneRepozytoriumHotelu
```

Przyklad tworzenia rezerwacji:

```text
UI formularza rezerwacji
  -> HotelController.utworzRezerwacje(...)
    -> SerwisRezerwacji.stworzRezerwacje(...)
      -> Pokoj.czyDostepny(...)
      -> Rezerwacja(...)
      -> FakeSerwisEmail.wyslijPotwierdzenie(...)
    -> zapis w lokalnej liscie rezerwacji
```

## Brak backendu i bazy danych

Aplikacja nie laczy sie z zadnym serwerem. Wszystko dziala w pamieci aplikacji.
Po ponownym uruchomieniu dane wracaja do stanu demonstracyjnego.

