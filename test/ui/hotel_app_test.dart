import 'package:flutter_test/flutter_test.dart';
import 'package:hotel/ui/hotel_app.dart';

void main() {
  testWidgets('wyswietla glowny panel aplikacji', (tester) async {
    await tester.pumpWidget(const HotelApp());

    expect(find.text('Spokojny pobyt blisko miasta'), findsOneWidget);
    expect(find.text('Start'), findsWidgets);
    expect(find.text('Pokoje'), findsWidgets);
    expect(find.text('Pobyt'), findsWidgets);
  });

  testWidgets('po wyszukaniu pokazuje dostepne pokoje', (tester) async {
    await tester.pumpWidget(const HotelApp());

    await tester.tap(find.text('Szukaj'));
    await tester.pumpAndSettle();

    expect(find.text('Pokoj 101'), findsOneWidget);
    expect(find.text('Wybierz pokoj'), findsWidgets);
  });

  testWidgets('pozwala przelaczyc widok goscia i recepcjonisty', (tester) async {
    await tester.pumpWidget(const HotelApp());

    await tester.tap(find.text('Konto'));
    await tester.pumpAndSettle();

    expect(find.text('Widok konta'), findsOneWidget);
    expect(find.text('Gosc hotelowy'), findsOneWidget);
    expect(find.text('Recepcjonista'), findsOneWidget);
  });

  testWidgets('pokazuje osobna nawigacje recepcjonisty', (tester) async {
    await tester.pumpWidget(const HotelApp());

    await tester.tap(find.text('Konto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recepcjonista'));
    await tester.pumpAndSettle();

    expect(find.text('Panel recepcji'), findsOneWidget);
    expect(find.text('Rezerwacje'), findsWidgets);
    expect(find.text('Zarzadzanie pokojami'), findsOneWidget);
  });

  testWidgets('widok goscia nie pokazuje panelu recepcji', (tester) async {
    await tester.pumpWidget(const HotelApp());

    expect(find.text('Spokojny pobyt blisko miasta'), findsOneWidget);
    expect(find.text('Panel recepcji'), findsNothing);
    expect(find.text('Zarzadzanie pokojami'), findsNothing);
  });
}
