# Instrukcja krok po kroku

Dokument opisuje kolejnosc prac wykonanych w projekcie Flutter aplikacji hotelowej.

## 1. Analiza diagramow

Na poczatku przeanalizowano diagram klas oraz diagramy sekwencji. Z diagramow
wynikaly glowne klasy domenowe:

- `Uzytkownik`
- `Gosc`
- `Recepcjonista`
- `Rezerwacja`
- `Pokoj`
- `Platnosc`
- `OcenaPobytu`
- `SerwisRezerwacji`
- `SerwisZameldowania`
- `ISerwisEmail`
- `ISystemPlatnosci`
- `ISystemOtwieraniaDrzwi`

Ustalono tez, ze aplikacja ma byc projektem pokazowym, bez backendu i bez bazy
danych. Dane maja byc przechowywane lokalnie w pamieci aplikacji.

## 2. Przygotowanie struktury plikow

Utworzono strukture zgodna z diagramem i typowa dla Fluttera:

- `lib/models/` - klasy modelu domenowego
- `lib/enums/` - statusy rezerwacji i pokoju
- `lib/interfaces/` - interfejsy systemow zewnetrznych z diagramu
- `lib/services/` - serwisy realizujace procesy biznesowe
- `lib/fakes/` - lokalne implementacje interfejsow
- `lib/data/` - lokalne dane demonstracyjne
- `lib/controllers/` - warstwa laczaca UI z logika
- `lib/ui/` - interfejs uzytkownika
- `test/` - testy jednostkowe i test UI

## 3. Implementacja modeli

Najpierw dodano modele z diagramu:

- `uzytkownik.dart`
- `gosc.dart`
- `recepcjonista.dart`
- `rezerwacja.dart`
- `pokoj.dart`
- `platnosc.dart`
- `ocena_pobytu.dart`

Dodano tez enumy:

- `status_rezerwacji.dart`
- `status_pokoju.dart`

Modele zawieraja pola i metody wynikajace z diagramow, np.:

- `Rezerwacja.obliczDlugoscPobytu()`
- `Rezerwacja.modyfikujDaty(...)`
- `Rezerwacja.potwierdzRezerwacje()`
- `Rezerwacja.anulujRezerwacje()`
- `Pokoj.czyDostepny(...)`
- `Pokoj.obliczKoszt(...)`
- `Pokoj.zmienStatus(...)`
- `Platnosc.wykonajPlatnosc()`

## 4. Implementacja interfejsow i fake systemow

Z diagramu wynikaly interfejsy:

- `ISerwisEmail`
- `ISystemPlatnosci`
- `ISystemOtwieraniaDrzwi`

Poniewaz projekt nie ma backendu ani zewnetrznych integracji, dodano lokalne
fake implementacje:

- `FakeSerwisEmail`
- `FakeSystemPlatnosci`
- `FakeSystemOtwieraniaDrzwi`

Fake systemy zapisuja informacje w pamieci, dzieki czemu mozna je testowac.

## 5. Implementacja serwisu rezerwacji

Dodano `SerwisRezerwacji`, ktory obsluguje:

- tworzenie rezerwacji
- sprawdzanie dostepnosci pokoju
- wysylanie potwierdzenia
- anulowanie rezerwacji
- wyszukiwanie dostepnych pokoi
- modyfikacje dat rezerwacji

Serwis uzywa lokalnej listy pokoi i gosci, a potwierdzenia wysyla przez
`ISerwisEmail`.

## 6. Implementacja serwisu zameldowania

Dodano `SerwisZameldowania`, ktory obsluguje:

- zameldowanie
- wygenerowanie kodu PIN
- wymeldowanie
- dezaktywacje kodu PIN
- zmiane statusu pokoju

Serwis korzysta z `ISystemOtwieraniaDrzwi`.

## 7. Lokalne dane demonstracyjne

Dodano `LokalneRepozytoriumHotelu`, ktore przechowuje:

- pokoje
- uzytkownikow
- gosci
- recepcjonistow
- rezerwacje

Jest to dodatek techniczny, poniewaz aplikacja nie ma backendu ani bazy danych.

## 8. Warstwa kontrolera

Dodano `HotelController`. Nie wystepuje on na diagramach, ale jest potrzebny
w aplikacji Flutter jako jedno miejsce, przez ktore UI wywoluje logike.

Kontroler udostepnia operacje:

- `utworzRezerwacje(...)`
- `znajdzDostepnePokoje(...)`
- `zmienStatusPokoju(...)`
- `anulujRezerwacje(...)`
- `modyfikujDatyRezerwacji(...)`
- `zamelduj(...)`
- `wymelduj(...)`
- `wykonajPlatnosc(...)`
- `dodajOcenePobytu(...)`

## 9. Usuniecie elementow szablonu Fluttera

Usunieto domyslny licznik Fluttera oraz test szablonowy. `main.dart` uruchamia
teraz aplikacje `HotelApp`.

## 10. Implementacja UI

Dodano UI w katalogu `lib/ui/`:

- `hotel_app.dart`
- `screens/hotel_dashboard_screen.dart`

Interfejs jest aplikacja klienta hotelu i zawiera:

- ekran startowy
- widok pokoi
- widok pobytu/rezerwacji
- formularz rezerwacji
- formularz zmiany dat
- formularz oceny pobytu
- akcje: rezerwuj, plac, pobierz PIN, wymelduj, anuluj, ocen

UI korzysta z jasnego tla, brazow, szalwii i chlodnego niebieskoszarego akcentu.

## 11. Walidacja koncowa

Na koncu uruchomiono:

```bash
flutter test
flutter analyze
```

Wynik:

- testy przechodza
- analiza statyczna nie zglasza problemow

