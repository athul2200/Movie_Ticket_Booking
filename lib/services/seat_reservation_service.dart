import 'dart:async';

/// ============================================================
/// Seat Reservation Service — Singleton
///
/// Tracks temporarily reserved seats per screen key.
/// Each reservation auto-expires after 5 minutes.
/// ============================================================

class SeatReservation {
  final String seatId;
  final DateTime reservedAt;
  Timer? _expiryTimer;

  SeatReservation({required this.seatId, required this.reservedAt});

  void cancel() {
    _expiryTimer?.cancel();
  }
}

class SeatReservationService {
  SeatReservationService._();
  static final SeatReservationService instance = SeatReservationService._();

  static const Duration reservationDuration = Duration(minutes: 5);

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

  /// Reserve a seat. Starts the 5-minute auto-cancel timer.
  /// Returns false if seat is already reserved.
  bool reserveSeat(String key, String seatId, {void Function()? onChange}) {
    _reservations[key] ??= {};
    if (_reservations[key]!.containsKey(seatId)) return false;

    final reservation = SeatReservation(
      seatId: seatId,
      reservedAt: DateTime.now(),
    );

    // Schedule auto-expiry
    reservation._expiryTimer = Timer(reservationDuration, () {
      _cancelReservation(key, seatId);
    });

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
    final seats = _reservations[key];
    if (seats == null) return;
    for (final r in seats.values) {
      r.cancel();
    }
    _reservations.remove(key);
    _notify(key);
  }

  /// Returns how many seconds remain on a reservation (0 if not found)
  int secondsRemaining(String key, String seatId) {
    final r = _reservations[key]?[seatId];
    if (r == null) return 0;
    final elapsed = DateTime.now().difference(r.reservedAt).inSeconds;
    final remaining = reservationDuration.inSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
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
    final r = _reservations[key]?.remove(seatId);
    r?.cancel();
    _notify(key);
  }

  void _notify(String key) {
    for (final l in (_listeners[key] ?? [])) {
      l();
    }
  }
}
