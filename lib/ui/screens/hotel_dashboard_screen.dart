import 'package:flutter/material.dart';

import '../../controllers/hotel_controller.dart';
import '../../enums/status_pokoju.dart';
import '../../enums/status_rezerwacji.dart';
import '../../models/gosc.dart';
import '../../models/pokoj.dart';
import '../../models/recepcjonista.dart';
import '../../models/rezerwacja.dart';
import '../../models/uzytkownik.dart';

class HotelDashboardScreen extends StatefulWidget {
  const HotelDashboardScreen({super.key});

  @override
  State<HotelDashboardScreen> createState() => _HotelDashboardScreenState();
}

class _HotelDashboardScreenState extends State<HotelDashboardScreen> {
  late final HotelController _controller;
  int _selectedIndex = 0;
  DateTime _startDate = DateTime(2026, 6, 10);
  DateTime _endDate = DateTime(2026, 6, 12);
  int _guestCount = 2;
  _AccountRole _role = _AccountRole.gosc;
  late Uzytkownik _activeUser;

  @override
  void initState() {
    super.initState();
    _controller = HotelController.demo();
    _activeUser = _controller.repozytorium.goscie.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _page()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: _navigationDestinations(),
      ),
    );
  }

  List<NavigationDestination> _navigationDestinations() {
    return switch (_role) {
      _AccountRole.gosc => const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Start',
          ),
          NavigationDestination(
            icon: Icon(Icons.king_bed_outlined),
            selectedIcon: Icon(Icons.king_bed_rounded),
            label: 'Pokoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage_rounded),
            label: 'Pobyt',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle_rounded),
            label: 'Konto',
          ),
        ],
      _AccountRole.recepcjonista => const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Rezerwacje',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Pokoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle_rounded),
            label: 'Konto',
          ),
        ],
    };
  }

  Widget _page() {
    return switch (_role) {
      _AccountRole.gosc => _guestPage(),
      _AccountRole.recepcjonista => _receptionPage(),
    };
  }

  Widget _guestPage() {
    return switch (_selectedIndex) {
      0 => _HomePage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        onFiltersChanged: _setFilters,
        onReserve: _showReservationDialog,
        onOpenRooms: _openRooms,
      ),
      1 => _RoomsPage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        role: _role,
        onFiltersChanged: _setFilters,
        onSearch: _openRooms,
        onReserve: (room) => _showReservationDialog(initialRoom: room),
        onStatusChanged: _changeRoomStatus,
      ),
      2 => _StayPage(
        controller: _controller,
        role: _role,
        onPay: _payReservation,
        onCheckIn: _checkInReservation,
        onCheckOut: _checkOutReservation,
        onCancel: _cancelReservation,
        onReview: _showReviewDialog,
        onModifyDates: _showDateEditDialog,
      ),
      _ => _AccountPage(
        controller: _controller,
        role: _role,
        activeUser: _activeUser,
        onRoleChanged: _changeRole,
        onUserChanged: _changeUser,
      ),
    };
  }

  Widget _receptionPage() {
    return switch (_selectedIndex) {
      0 => _ReceptionDashboardPage(
        controller: _controller,
        onOpenReservations: () => setState(() => _selectedIndex = 1),
        onOpenRooms: () => setState(() => _selectedIndex = 2),
      ),
      1 => _StayPage(
        controller: _controller,
        role: _role,
        onPay: _payReservation,
        onCheckIn: _checkInReservation,
        onCheckOut: _checkOutReservation,
        onCancel: _cancelReservation,
        onReview: _showReviewDialog,
        onModifyDates: _showDateEditDialog,
      ),
      2 => _RoomsPage(
        controller: _controller,
        startDate: _startDate,
        endDate: _endDate,
        guestCount: _guestCount,
        role: _role,
        onFiltersChanged: _setFilters,
        onSearch: _openRooms,
        onReserve: (room) => _showReservationDialog(initialRoom: room),
        onStatusChanged: _changeRoomStatus,
      ),
      _ => _AccountPage(
        controller: _controller,
        role: _role,
        activeUser: _activeUser,
        onRoleChanged: _changeRole,
        onUserChanged: _changeUser,
      ),
    };
  }

  void _openRooms() {
    setState(() => _selectedIndex = 1);
  }

  void _setFilters(DateTime startDate, DateTime endDate, int guestCount) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _guestCount = guestCount;
    });
  }

  void _changeRole(_AccountRole role) {
    setState(() {
      _role = role;
      _selectedIndex = 0;
      _activeUser = switch (role) {
        _AccountRole.gosc => _controller.repozytorium.goscie.first,
        _AccountRole.recepcjonista =>
          _controller.repozytorium.recepcjonisci.first,
      };
    });
  }

  void _changeUser(Uzytkownik user) {
    setState(() => _activeUser = user);
  }

  void _changeRoomStatus(Pokoj room, StatusPokoju status) {
    setState(() {
      _controller.zmienStatusPokoju(
        idPokoju: room.idPokoju,
        nowyStatus: status,
      );
    });
    _message('Status pokoju ${room.nrPokoju}: ${_roomStatusLabel(status)}');
  }

  Future<void> _showReservationDialog({Pokoj? initialRoom}) async {
    final result = await showModalBottomSheet<_ReservationDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _ReservationSheet(
          guests: _controller.repozytorium.goscie,
          rooms: _controller.repozytorium.pokoje,
          initialRoom: initialRoom,
          initialStartDate: _startDate,
          initialEndDate: _endDate,
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      setState(() {
        _controller.utworzRezerwacje(
          idGoscia: result.guest.idUzytkownika,
          idPokoju: result.room.idPokoju,
          dataPoczatkowa: result.startDate,
          dataKoncowa: result.endDate,
        );
        _selectedIndex = 2;
      });
      _message('Rezerwacja zostala zapisana');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _payReservation(Rezerwacja reservation) {
    setState(() {
      _controller.wykonajPlatnosc(idRezerwacji: reservation.idRezerwacji);
    });
    _message(
      reservation.platnosc?.czyPoprawna == true
          ? 'Platnosc przyjeta'
          : 'Platnosc odrzucona',
    );
  }

  void _checkInReservation(Rezerwacja reservation) {
    try {
      late final String pin;
      setState(() {
        pin = _controller.zamelduj(idRezerwacji: reservation.idRezerwacji);
      });
      _message('Kod PIN do pokoju: $pin');
    } on StateError catch (error) {
      _message(error.message);
    }
  }

  void _checkOutReservation(Rezerwacja reservation) {
    final checkedOut = _controller.wymelduj(
      idRezerwacji: reservation.idRezerwacji,
    );
    if (checkedOut) {
      setState(() {});
    }
    _message(checkedOut ? 'Wymeldowanie zakonczone' : 'Nie mozna wymeldowac');
  }

  void _cancelReservation(Rezerwacja reservation) {
    final cancelled = _controller.anulujRezerwacje(
      idRezerwacji: reservation.idRezerwacji,
      powod: 'Anulowano przez klienta',
    );
    if (cancelled) {
      setState(() {});
    }
    _message(cancelled ? 'Rezerwacja anulowana' : 'Nie znaleziono rezerwacji');
  }

  Future<void> _showReviewDialog(Rezerwacja reservation) async {
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _ReviewSheet(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _controller.dodajOcenePobytu(
        idRezerwacji: reservation.idRezerwacji,
        liczbaGwiazdek: result.stars,
        komentarz: result.comment,
        dataDodania: DateTime.now(),
      );
    });
    _message('Dziekujemy za opinie');
  }

  Future<void> _showDateEditDialog(Rezerwacja reservation) async {
    final result = await showModalBottomSheet<_DateRangeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _DateEditSheet(
          startDate: reservation.dataPoczatkowa,
          endDate: reservation.dataKoncowa,
        );
      },
    );

    if (result == null) {
      return;
    }

    final changed = _controller.modyfikujDatyRezerwacji(
      idRezerwacji: reservation.idRezerwacji,
      nowaDataPoczatkowa: result.startDate,
      nowaDataKoncowa: result.endDate,
    );
    if (changed) {
      setState(() {});
    }
    _message(
      changed ? 'Termin zaktualizowany' : 'Wybrany termin jest niedostepny',
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _AccountRole { gosc, recepcjonista }

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.onFiltersChanged,
    required this.onReserve,
    required this.onOpenRooms,
  });

  final HotelController controller;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final void Function(DateTime startDate, DateTime endDate, int guestCount)
  onFiltersChanged;
  final VoidCallback onReserve;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final availableRooms = controller.znajdzDostepnePokoje(
      dataPoczatkowa: startDate,
      dataKoncowa: endDate,
      liczbaGosci: guestCount,
    );
    final reservations = controller.rezerwacje;

    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroPanel(
            onReserve: onReserve,
            onOpenRooms: onOpenRooms,
          ),
          const SizedBox(height: 18),
          _BookingCard(
            startDate: startDate,
            endDate: endDate,
            guestCount: guestCount,
            onChanged: onFiltersChanged,
            onSearch: onOpenRooms,
          ),
          const SizedBox(height: 22),
          _SectionTitle(
            title: 'Polecane pokoje',
            actionLabel: 'Zobacz wszystkie',
            onAction: onOpenRooms,
          ),
          const SizedBox(height: 12),
          if (availableRooms.isEmpty)
            const _EmptyCard(
              icon: Icons.king_bed_outlined,
              title: 'Brak pokoi w tym terminie',
            )
          else
            SizedBox(
              height: 268,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableRooms.take(3).length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final room = availableRooms[index];
                  return SizedBox(
                    width: 290,
                    child: _RoomOfferCard(
                      room: room,
                      available: true,
                      role: _AccountRole.gosc,
                      onReserve: () => onReserve(),
                      onStatusChanged: (_) {},
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Twoj pobyt'),
          const SizedBox(height: 12),
          if (reservations.isEmpty)
            const _EmptyCard(
              icon: Icons.luggage_outlined,
              title: 'Nie masz jeszcze rezerwacji',
            )
          else
            _StaySummaryCard(reservation: reservations.last),
        ],
      ),
    );
  }
}

class _ReceptionDashboardPage extends StatelessWidget {
  const _ReceptionDashboardPage({
    required this.controller,
    required this.onOpenReservations,
    required this.onOpenRooms,
  });

  final HotelController controller;
  final VoidCallback onOpenReservations;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final reservations = controller.rezerwacje;
    final rooms = controller.repozytorium.pokoje;
    final activeReservations = reservations
        .where((reservation) => reservation.status != StatusRezerwacji.anulowana)
        .length;
    final cleaningRooms = rooms
        .where((room) => room.statusPokoju == StatusPokoju.czyszczenie)
        .length;

    return _Page(
      title: 'Panel recepcji',
      subtitle: 'Obsluga rezerwacji i statusow pokoi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisExtent: 128,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            children: [
              _MetricCard(
                icon: Icons.event_available_rounded,
                label: 'Rezerwacje',
                value: '$activeReservations',
              ),
              _MetricCard(
                icon: Icons.meeting_room_rounded,
                label: 'Pokoje',
                value: '${rooms.length}',
              ),
              _MetricCard(
                icon: Icons.cleaning_services_rounded,
                label: 'Do sprzatania',
                value: '$cleaningRooms',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'Zadania recepcji'),
          const SizedBox(height: 12),
          _ReceptionActionCard(
            icon: Icons.edit_calendar_rounded,
            title: 'Zarzadzaj rezerwacjami',
            subtitle: 'Modyfikuj daty rezerwacji zgodnie z diagramem.',
            buttonLabel: 'Otworz rezerwacje',
            onPressed: onOpenReservations,
          ),
          const SizedBox(height: 12),
          _ReceptionActionCard(
            icon: Icons.meeting_room_rounded,
            title: 'Zarzadzanie pokojami',
            subtitle: 'Zmieniaj status: dostepny, zajety, czyszczenie, wylaczony.',
            buttonLabel: 'Otworz pokoje',
            onPressed: onOpenRooms,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF6F8F83)),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3A2922),
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF75665B),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceptionActionCard extends StatelessWidget {
  const _ReceptionActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFECE1D4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF5B4033)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF75665B),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceptionRoomSummary extends StatelessWidget {
  const _ReceptionRoomSummary({required this.rooms});

  final List<Pokoj> rooms;

  @override
  Widget build(BuildContext context) {
    int count(StatusPokoju status) {
      return rooms.where((room) => room.statusPokoju == status).length;
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: StatusPokoju.values.map((status) {
        return _StatusPill(
          text: '${_roomStatusLabel(status)}: ${count(status)}',
          color: status == StatusPokoju.dostepny
              ? const Color(0xFF4E7B63)
              : const Color(0xFF8B4C4C),
        );
      }).toList(),
    );
  }
}

class _RoomsPage extends StatelessWidget {
  const _RoomsPage({
    required this.controller,
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.role,
    required this.onFiltersChanged,
    required this.onSearch,
    required this.onReserve,
    required this.onStatusChanged,
  });

  final HotelController controller;
  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final _AccountRole role;
  final void Function(DateTime startDate, DateTime endDate, int guestCount)
  onFiltersChanged;
  final VoidCallback onSearch;
  final void Function(Pokoj room) onReserve;
  final void Function(Pokoj room, StatusPokoju status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final rooms = controller.repozytorium.pokoje;
    final availableRooms = controller.znajdzDostepnePokoje(
      dataPoczatkowa: startDate,
      dataKoncowa: endDate,
      liczbaGosci: guestCount,
    );
    final isReception = role == _AccountRole.recepcjonista;

    return _Page(
      title: isReception ? 'Zarzadzanie pokojami' : 'Pokoje',
      subtitle: isReception
          ? 'Statusy pokoi wedlug pracy recepcji'
          : 'Wybierz pokoj dopasowany do pobytu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReception) ...[
            _ReceptionRoomSummary(rooms: rooms),
            const SizedBox(height: 20),
          ] else ...[
            _BookingCard(
              startDate: startDate,
              endDate: endDate,
              guestCount: guestCount,
              onChanged: onFiltersChanged,
              onSearch: onSearch,
            ),
            const SizedBox(height: 20),
          ],
          ...rooms.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: role == _AccountRole.recepcjonista ? 318 : 258,
                child: _RoomOfferCard(
                  room: room,
                  available: availableRooms.contains(room),
                  role: role,
                  onReserve: () => onReserve(room),
                  onStatusChanged: (status) => onStatusChanged(room, status),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StayPage extends StatelessWidget {
  const _StayPage({
    required this.controller,
    required this.role,
    required this.onPay,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
    required this.onReview,
    required this.onModifyDates,
  });

  final HotelController controller;
  final _AccountRole role;
  final void Function(Rezerwacja reservation) onPay;
  final void Function(Rezerwacja reservation) onCheckIn;
  final void Function(Rezerwacja reservation) onCheckOut;
  final void Function(Rezerwacja reservation) onCancel;
  final void Function(Rezerwacja reservation) onReview;
  final void Function(Rezerwacja reservation) onModifyDates;

  @override
  Widget build(BuildContext context) {
    final reservations = controller.rezerwacje;
    final isReception = role == _AccountRole.recepcjonista;

    return _Page(
      title: isReception ? 'Rezerwacje' : 'Pobyt',
      subtitle: isReception
          ? 'Zmiana terminow rezerwacji'
          : 'Rezerwacje, platnosci i opinie',
      child: reservations.isEmpty
          ? const _EmptyCard(
              icon: Icons.luggage_outlined,
              title: 'Brak aktywnych rezerwacji',
            )
          : Column(
              children: reservations.reversed
                  .map(
                    (reservation) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ReservationCard(
                        reservation: reservation,
                        role: role,
                        onPay: () => onPay(reservation),
                        onCheckIn: () => onCheckIn(reservation),
                        onCheckOut: () => onCheckOut(reservation),
                        onCancel: () => onCancel(reservation),
                        onReview: () => onReview(reservation),
                        onModifyDates: () => onModifyDates(reservation),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.child,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF3A2922),
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF75665B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.onReserve,
    required this.onOpenRooms,
  });

  final VoidCallback onReserve;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B4033),
            Color(0xFF7A5A45),
            Color(0xFF6F8F83),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa_rounded, color: Colors.white, size: 34),
          const SizedBox(height: 28),
          Text(
            'Spokojny pobyt blisko miasta',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Zarezerwuj pokoj, oplac pobyt i zarzadzaj rezerwacja w jednym miejscu.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onReserve,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Zarezerwuj'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5B4033),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onOpenRooms,
                icon: const Icon(Icons.king_bed_rounded),
                label: const Text('Pokoje'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.startDate,
    required this.endDate,
    required this.guestCount,
    required this.onChanged,
    required this.onSearch,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int guestCount;
  final void Function(DateTime startDate, DateTime endDate, int guestCount)
  onChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Szukaj pobytu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DateButton(
                  label: 'Od',
                  date: startDate,
                  onPicked: (date) => onChanged(date, endDate, guestCount),
                ),
                _DateButton(
                  label: 'Do',
                  date: endDate,
                  onPicked: (date) => onChanged(startDate, date, guestCount),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<int>(
                    initialValue: guestCount,
                    decoration: const InputDecoration(
                      labelText: 'Goscie',
                      prefixIcon: Icon(Icons.group_rounded),
                    ),
                    items: [1, 2, 3, 4]
                        .map(
                          (count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(startDate, endDate, value);
                      }
                    },
                  ),
                ),
                FilledButton.icon(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Szukaj'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomOfferCard extends StatelessWidget {
  const _RoomOfferCard({
    required this.room,
    required this.available,
    required this.role,
    required this.onReserve,
    required this.onStatusChanged,
  });

  final Pokoj room;
  final bool available;
  final _AccountRole role;
  final VoidCallback onReserve;
  final ValueChanged<StatusPokoju> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 92,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _roomVisualColors(room.nrPokoju),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  bottom: 12,
                  child: Icon(
                    Icons.king_bed_rounded,
                    color: Colors.white.withValues(alpha: 0.82),
                    size: 54,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 14,
                  child: _StatusPill(
                    text: available
                        ? 'Dostepny'
                        : _roomStatusLabel(room.statusPokoju),
                    color: available
                        ? const Color(0xFF4E7B63)
                        : const Color(0xFF8B4C4C),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pokoj ${room.nrPokoju}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3A2922),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 7,
                  children: [
                    _IconText(
                      icon: Icons.group_rounded,
                      text: '${room.pojemnoscPokoju} os.',
                    ),
                    _IconText(
                      icon: Icons.nights_stay_rounded,
                      text: '${_formatMoney(room.cenaZaDobe)} / noc',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (role == _AccountRole.gosc)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: available ? onReserve : null,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('Wybierz pokoj'),
                    ),
                  )
                else
                  _RoomStatusSelector(
                    status: room.statusPokoju,
                    onChanged: onStatusChanged,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomStatusSelector extends StatelessWidget {
  const _RoomStatusSelector({
    required this.status,
    required this.onChanged,
  });

  final StatusPokoju status;
  final ValueChanged<StatusPokoju> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: StatusPokoju.values.map((value) {
        final selected = value == status;
        return ChoiceChip(
          label: Text(_roomStatusLabel(value)),
          selected: selected,
          onSelected: selected ? null : (_) => onChanged(value),
        );
      }).toList(),
    );
  }
}

class _AccountPage extends StatelessWidget {
  const _AccountPage({
    required this.controller,
    required this.role,
    required this.activeUser,
    required this.onRoleChanged,
    required this.onUserChanged,
  });

  final HotelController controller;
  final _AccountRole role;
  final Uzytkownik activeUser;
  final ValueChanged<_AccountRole> onRoleChanged;
  final ValueChanged<Uzytkownik> onUserChanged;

  @override
  Widget build(BuildContext context) {
    final users = switch (role) {
      _AccountRole.gosc => controller.repozytorium.goscie,
      _AccountRole.recepcjonista => controller.repozytorium.recepcjonisci,
    };

    return _Page(
      title: 'Konto',
      subtitle: 'Wybierz widok i uprawnienia',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widok konta',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<_AccountRole>(
                    segments: const [
                      ButtonSegment(
                        value: _AccountRole.gosc,
                        icon: Icon(Icons.person_rounded),
                        label: Text('Gosc hotelowy'),
                      ),
                      ButtonSegment(
                        value: _AccountRole.recepcjonista,
                        icon: Icon(Icons.badge_rounded),
                        label: Text('Recepcjonista'),
                      ),
                    ],
                    selected: {role},
                    onSelectionChanged: (selection) {
                      onRoleChanged(selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Uzytkownik>(
                    initialValue: activeUser,
                    decoration: const InputDecoration(
                      labelText: 'Aktywne konto',
                      prefixIcon: Icon(Icons.account_circle_rounded),
                    ),
                    items: users
                        .map(
                          (user) => DropdownMenuItem<Uzytkownik>(
                            value: user,
                            child: Text('${user.imie} ${user.nazwisko}'),
                          ),
                        )
                        .toList(),
                    onChanged: (user) {
                      if (user != null) {
                        onUserChanged(user);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PermissionCard(role: role, user: activeUser),
        ],
      ),
    );
  }
}

class _StaySummaryCard extends StatelessWidget {
  const _StaySummaryCard({required this.reservation});

  final Rezerwacja reservation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _ReservationHeader(reservation: reservation),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.role,
    required this.onPay,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
    required this.onReview,
    required this.onModifyDates,
  });

  final Rezerwacja reservation;
  final _AccountRole role;
  final VoidCallback onPay;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;
  final VoidCallback onReview;
  final VoidCallback onModifyDates;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReservationHeader(reservation: reservation),
            const Divider(height: 26),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (role == _AccountRole.gosc) ...[
                  FilledButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.credit_card_rounded),
                    label: const Text('Oplac'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCheckIn,
                    icon: const Icon(Icons.key_rounded),
                    label: const Text('PIN'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCheckOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Wymelduj'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Ocena'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Anuluj'),
                  ),
                ] else
                  OutlinedButton.icon(
                    onPressed: onModifyDates,
                    icon: const Icon(Icons.edit_calendar_rounded),
                    label: const Text('Zmien daty'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationHeader extends StatelessWidget {
  const _ReservationHeader({required this.reservation});

  final Rezerwacja reservation;

  @override
  Widget build(BuildContext context) {
    final roomNumbers = reservation.pokoje
        .map((room) => room.nrPokoju)
        .join(', ');
    final payment = reservation.platnosc;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFECE1D4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.hotel_rounded, color: Color(0xFF5B4033)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Rezerwacja #${reservation.idRezerwacji}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _StatusPill(
                    text: _reservationStatusLabel(reservation.status),
                    color: _reservationStatusColor(reservation.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${reservation.gosc?.imie ?? 'Gosc'} ${reservation.gosc?.nazwisko ?? ''} · pokoj $roomNumbers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 7,
                children: [
                  _IconText(
                    icon: Icons.calendar_month_rounded,
                    text:
                        '${_formatDate(reservation.dataPoczatkowa)} - ${_formatDate(reservation.dataKoncowa)}',
                  ),
                  _IconText(
                    icon: Icons.nights_stay_rounded,
                    text: '${reservation.obliczDlugoscPobytu()} noce',
                  ),
                  _IconText(
                    icon: Icons.payments_rounded,
                    text: _formatMoney(reservation.calkowitaCena),
                  ),
                  _IconText(
                    icon: payment?.czyPoprawna == true
                        ? Icons.verified_rounded
                        : Icons.hourglass_bottom_rounded,
                    text: payment == null
                        ? 'Nieoplacona'
                        : payment.czyPoprawna
                        ? 'Oplacona'
                        : 'Odrzucona',
                  ),
                  if (reservation.ocenaPobytu != null)
                    _IconText(
                      icon: Icons.star_rounded,
                      text: '${reservation.ocenaPobytu!.liczbaGwiazdek}/5',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReservationSheet extends StatefulWidget {
  const _ReservationSheet({
    required this.guests,
    required this.rooms,
    required this.initialStartDate,
    required this.initialEndDate,
    this.initialRoom,
  });

  final List<Gosc> guests;
  final List<Pokoj> rooms;
  final Pokoj? initialRoom;
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  @override
  State<_ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<_ReservationSheet> {
  late Gosc _guest = widget.guests.first;
  late Pokoj _room = widget.initialRoom ?? widget.rooms.first;
  late DateTime _startDate = widget.initialStartDate;
  late DateTime _endDate = widget.initialEndDate;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Rezerwacja pokoju',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Gosc>(
            initialValue: _guest,
            decoration: const InputDecoration(
              labelText: 'Gosc',
              prefixIcon: Icon(Icons.person_rounded),
            ),
            items: widget.guests
                .map(
                  (guest) => DropdownMenuItem(
                    value: guest,
                    child: Text('${guest.imie} ${guest.nazwisko}'),
                  ),
                )
                .toList(),
            onChanged: (guest) {
              if (guest != null) {
                setState(() => _guest = guest);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Pokoj>(
            initialValue: _room,
            decoration: const InputDecoration(
              labelText: 'Pokoj',
              prefixIcon: Icon(Icons.king_bed_rounded),
            ),
            items: widget.rooms
                .map(
                  (room) => DropdownMenuItem(
                    value: room,
                    child: Text('Pokoj ${room.nrPokoju}'),
                  ),
                )
                .toList(),
            onChanged: (room) {
              if (room != null) {
                setState(() => _room = room);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Od',
                  date: _startDate,
                  onPicked: (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'Do',
                  date: _endDate,
                  onPicked: (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _ReservationDraft(
                    guest: _guest,
                    room: _room,
                    startDate: _startDate,
                    endDate: _endDate,
                  ),
                );
              },
              child: const Text('Potwierdz rezerwacje'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateEditSheet extends StatefulWidget {
  const _DateEditSheet({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<_DateEditSheet> createState() => _DateEditSheetState();
}

class _DateEditSheetState extends State<_DateEditSheet> {
  late DateTime _startDate = widget.startDate;
  late DateTime _endDate = widget.endDate;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Zmien termin',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'Od',
                  date: _startDate,
                  onPicked: (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateButton(
                  label: 'Do',
                  date: _endDate,
                  onPicked: (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _DateRangeDraft(startDate: _startDate, endDate: _endDate),
                );
              },
              child: const Text('Zapisz termin'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet();

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _stars = 5;
  final _commentController = TextEditingController(text: 'Bardzo dobry pobyt');

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: 'Ocena pobytu',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _stars,
            decoration: const InputDecoration(
              labelText: 'Gwiazdki',
              prefixIcon: Icon(Icons.star_rounded),
            ),
            items: [1, 2, 3, 4, 5]
                .map(
                  (stars) => DropdownMenuItem(
                    value: stars,
                    child: Text('$stars'),
                  ),
                )
                .toList(),
            onChanged: (stars) {
              if (stars != null) {
                setState(() => _stars = stars);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Komentarz',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _ReviewDraft(stars: _stars, comment: _commentController.text),
                );
              },
              child: const Text('Dodaj ocene'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD6C8BA),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2922),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2025),
          lastDate: DateTime(2028),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      icon: const Icon(Icons.calendar_month_rounded),
      label: Text('$label ${_formatDate(date)}'),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A2922),
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6F8F83)),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6E5D52),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF6F8F83)),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.role,
    required this.user,
  });

  final _AccountRole role;
  final Uzytkownik user;

  @override
  Widget build(BuildContext context) {
    final permissions = switch (role) {
      _AccountRole.gosc => const [
        'Przegladanie pokoi',
        'Rezerwacja pokoju',
        'Platnosc za rezerwacje',
        'Zameldowanie i wymeldowanie',
        'Anulowanie rezerwacji',
        'Ocena pobytu',
      ],
      _AccountRole.recepcjonista => const [
        'Modyfikacja dat rezerwacji',
        'Zmiana statusu pokoju',
      ],
    };
    final employeeInfo = user is Recepcjonista
        ? 'Pracownik #${(user as Recepcjonista).idPracownika}'
        : 'Klient #${user.idUzytkownika}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE1D4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    role == _AccountRole.gosc
                        ? Icons.person_rounded
                        : Icons.badge_rounded,
                    color: const Color(0xFF5B4033),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.imie} ${user.nazwisko}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        employeeInfo,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF75665B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: permissions
                  .map(
                    (permission) => Chip(
                      avatar: const Icon(Icons.check_rounded, size: 18),
                      label: Text(permission),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationDraft {
  const _ReservationDraft({
    required this.guest,
    required this.room,
    required this.startDate,
    required this.endDate,
  });

  final Gosc guest;
  final Pokoj room;
  final DateTime startDate;
  final DateTime endDate;
}

class _DateRangeDraft {
  const _DateRangeDraft({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

class _ReviewDraft {
  const _ReviewDraft({
    required this.stars,
    required this.comment,
  });

  final int stars;
  final String comment;
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

String _formatMoney(double value) {
  return '${value.toStringAsFixed(0)} zl';
}

String _roomStatusLabel(StatusPokoju status) {
  return switch (status) {
    StatusPokoju.dostepny => 'Dostepny',
    StatusPokoju.zajety => 'Zajety',
    StatusPokoju.czyszczenie => 'Czyszczenie',
    StatusPokoju.wylaczony => 'Wylaczony',
  };
}

String _reservationStatusLabel(StatusRezerwacji status) {
  return switch (status) {
    StatusRezerwacji.oczekujaca => 'Oczekujaca',
    StatusRezerwacji.potwierdzona => 'Potwierdzona',
    StatusRezerwacji.anulowana => 'Anulowana',
    StatusRezerwacji.aktywna => 'Aktywna',
    StatusRezerwacji.zakonczona => 'Zakonczona',
  };
}

Color _reservationStatusColor(StatusRezerwacji status) {
  return switch (status) {
    StatusRezerwacji.oczekujaca => const Color(0xFF9A6B35),
    StatusRezerwacji.potwierdzona => const Color(0xFF4E7B63),
    StatusRezerwacji.anulowana => const Color(0xFF8B4C4C),
    StatusRezerwacji.aktywna => const Color(0xFF6E7794),
    StatusRezerwacji.zakonczona => const Color(0xFF5B4033),
  };
}

List<Color> _roomVisualColors(int roomNumber) {
  return switch (roomNumber % 4) {
    0 => const [Color(0xFF5B4033), Color(0xFF9C7B62)],
    1 => const [Color(0xFF6F8F83), Color(0xFFB7C9BD)],
    2 => const [Color(0xFF6E7794), Color(0xFFB8C0D3)],
    _ => const [Color(0xFF8A5A44), Color(0xFFD0B09A)],
  };
}
