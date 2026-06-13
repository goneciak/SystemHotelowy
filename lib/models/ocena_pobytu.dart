class OcenaPobytu {
  OcenaPobytu({
    required this.idOceny,
    required this.liczbaGwiazdek,
    required this.komentarz,
    required this.dataDodania,
  }) {
    if (liczbaGwiazdek < 1 || liczbaGwiazdek > 5) {
      throw ArgumentError.value(
        liczbaGwiazdek,
        'liczbaGwiazdek',
        'Ocena musi byc w zakresie 1-5.',
      );
    }
  }

  final int idOceny;
  final int liczbaGwiazdek;
  final String komentarz;
  final DateTime dataDodania;

  int getLiczbaGwiazdek() {
    return liczbaGwiazdek;
  }
}
