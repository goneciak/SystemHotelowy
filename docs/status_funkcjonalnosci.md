# Status funkcjonalnosci

Projekt ma zakonczony rdzen funkcjonalny oraz docelowy pierwszy interfejs
uzytkownika dla aplikacji hotelowej dla klientow.

## Zaimplementowane elementy z diagramow

- `Uzytkownik`
- `Gosc`
- `Recepcjonista`
- `Rezerwacja`
- `Pokoj`
- `Platnosc`
- `OcenaPobytu`
- `StatusRezerwacji`
- `StatusPokoju`
- `SerwisRezerwacji`
- `SerwisZameldowania`
- `ISerwisEmail`
- `ISystemPlatnosci`
- `ISystemOtwieraniaDrzwi`

## Zaimplementowane przeplywy

- przegladanie dostepnych pokoi dla zakresu dat i liczby gosci
- tworzenie rezerwacji
- wyslanie potwierdzenia rezerwacji
- anulowanie rezerwacji
- modyfikacja dat rezerwacji
- zmiana statusu pokoju
- zameldowanie i wygenerowanie kodu PIN
- wymeldowanie i dezaktywacja kodu PIN
- wykonanie platnosci
- dodanie oceny pobytu

## Dodatki techniczne poza diagramami

Te elementy istnieja po to, aby aplikacja mogla dzialac lokalnie bez backendu i bazy danych:

- `LokalneRepozytoriumHotelu`
- `HotelController`
- `FakeSerwisEmail`
- `FakeSystemPlatnosci`
- `FakeSystemOtwieraniaDrzwi`

## Swiadome doprecyzowania

- `Pokoj.zmienStatus(...)` przyjmuje `StatusPokoju`, bo tak wynika z diagramu sekwencji zarzadzania pokojami.
- `wyslijFakture(...)` zostalo usuniete zgodnie z decyzja projektowa.
- `HotelController` nie wystepuje na diagramach, ale jest potrzebny jako warstwa posrednia miedzy UI i logika.
- `LokalneRepozytoriumHotelu` nie wystepuje na diagramach, ale zastepuje backend i baze danych w projekcie lokalnym.

## UI

- aplikacja ma ekran startowy klienta
- aplikacja ma widok pokoi
- aplikacja ma widok pobytu/rezerwacji
- UI korzysta z `HotelController`
- UI nie uzywa backendu ani bazy danych

## Do zrobienia opcjonalnie

- uruchomienie na konkretnym emulatorze Android/iOS i ewentualne drobne poprawki wizualne
- przygotowanie screenow do dokumentacji lub prezentacji
