
/// ============================================================
/// Seat Reservation Service — Singleton
///
/// Tracks temporarily reserved seats per screen key.
/// Each reservation auto-expires after 5 minutes.
/// ============================================================

class SeatReservation {
  final String seatId;
  final DateTime reservedAt;

  SeatReservation({required this.seatId, required this.reservedAt});
}

class SeatReservationService {
  SeatReservationService._();
  static final SeatReservationService instance = SeatReservationService._();

  // Key: "<cinema>|<screen>|<date>|<showtime>"  →  Set of reserved seatIds
  final Map<String, Map<String, SeatReservation>> _reservations = {};

  // Listeners notified whenever reservations change
  final Map<String, List<void Function()>> _listeners = {};

  // ── Public API ──────────────────────────────────────────────

  /// Compose a canonical key for a specific screen/show
  static String screenKey({
    required String cinema,
    required String screen,
    required String date,
    required String showtime,
  }) =>
      '$cinema|$screen|$date|$showtime';

  /// Returns the set of currently reserved seat IDs for a screen
  Set<String> reservedSeats(String key) {
    return _reservations[key]?.keys.toSet() ?? {};
  }

  /// Reserve a seat.
  /// Returns false if seat is already reserved.
  bool reserveSeat(String key, String seatId, {void Function()? onChange}) {
    _reservations[key] ??= {};
    if (_reservations[key]!.containsKey(seatId)) return false;

    final reservation = SeatReservation(
      seatId: seatId,
      reservedAt: DateTime.now(),
    );

    _reservations[key]![seatId] = reservation;
    _notify(key);
    return true;
  }

  /// Manually release a seat (e.g. user deselects or completes booking)
  void releaseSeat(String key, String seatId) {
    _cancelReservation(key, seatId);
  }

  /// Release all seats for a given screen key (e.g. after payment)
  void releaseAll(String key) {
    _reservations.remove(key);
    _notify(key);
  }

  // ── Listener management ─────────────────────────────────────

  void addListener(String key, void Function() listener) {
    _listeners[key] ??= [];
    _listeners[key]!.add(listener);
  }

  void removeListener(String key, void Function() listener) {
    _listeners[key]?.remove(listener);
  }

  // ── Internal ────────────────────────────────────────────────

  void _cancelReservation(String key, String seatId) {
    _reservations[key]?.remove(seatId);
    _notify(key);
  }

  void _notify(String key) {
    for (final l in (_listeners[key] ?? [])) {
      l();
    }
  }
}
