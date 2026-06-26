import 'dart:async';
import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/services/seat_reservation_service.dart';

/// ============================================================
/// Seat Selection Screen — 3-section cinema seat map:
///   Left (4 seats) | Aisle | Center (8 seats) | Aisle | Right (4 seats)
///
/// Seat reservation logic:
///   - Selecting a seat reserves it globally via SeatReservationService.
///   - Other users (or returning to this screen) see reserved seats as "Booked".
///   - Each reservation auto-cancels after 5 minutes.
///   - A countdown timer is displayed when seats are selected.
/// ============================================================

class SeatSelectionScreen extends StatefulWidget {
  final String movieTitle;
  final String showtime;
  final String cinema;
  final String screen;
  final String format;
  final String date;

  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.showtime,
    required this.cinema,
    required this.screen,
    required this.format,
    required this.date,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Seats selected by THIS user in this session
  final Set<String> _selectedSeats = {};

  // Key used for this specific show in the reservation service
  late final String _screenKey;

  // Countdown timer state
  Timer? _countdownTimer;
  int _secondsRemaining = SeatReservationService.reservationDuration.inSeconds;

  double get _seatPrice {
    final cinema = widget.cinema.toLowerCase();
    final screen = widget.screen.toLowerCase();
    if (cinema.contains('kairali')) {
      if (screen.contains('1')) return 130.00;
      if (screen.contains('2')) return 105.00;
    } else if (cinema.contains('nila')) {
      if (screen.contains('1')) return 105.00;
      if (screen.contains('2')) return 130.00;
    }
    return 140.00;
  }

  static const List<String> _rowLabels = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  ];

  @override
  void initState() {
    super.initState();
    _screenKey = SeatReservationService.screenKey(
      cinema: widget.cinema,
      screen: widget.screen,
      date: widget.date,
      showtime: widget.showtime,
    );
    // Listen to reservation changes (other users releasing seats, expiry, etc.)
    SeatReservationService.instance.addListener(_screenKey, _onReservationChanged);
  }

  @override
  void dispose() {
    SeatReservationService.instance.removeListener(_screenKey, _onReservationChanged);
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onReservationChanged() {
    if (mounted) setState(() {});
  }

  // ── Seat tap logic ───────────────────────────────────────────

  void _onSeatTap(String seatId) {
    final service = SeatReservationService.instance;

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        // Deselect → release reservation
        _selectedSeats.remove(seatId);
        service.releaseSeat(_screenKey, seatId);
      } else {
        // Select → reserve
        _selectedSeats.add(seatId);
        service.reserveSeat(_screenKey, seatId);
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _updateCountdown();
  }

  // ── Countdown timer ──────────────────────────────────────────

  void _updateCountdown() {
    _countdownTimer?.cancel();
    if (_selectedSeats.isEmpty) return;

    // Find the earliest expiry among selected seats
    _refreshCountdownValue();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _refreshCountdownValue();
      if (_secondsRemaining <= 0) {
        _countdownTimer?.cancel();
        // Any seats that expired are already released by the service timer.
        // Just sync selected seats with what's still reserved.
        setState(() {
          _selectedSeats.removeWhere((seatId) =>
              !SeatReservationService.instance.reservedSeats(_screenKey).contains(seatId));
        });
      }
    });
  }

  void _refreshCountdownValue() {
    if (_selectedSeats.isEmpty) {
      setState(() => _secondsRemaining = SeatReservationService.reservationDuration.inSeconds);
      return;
    }
    // Show minimum remaining time across selected seats
    int minRemaining = SeatReservationService.reservationDuration.inSeconds;
    for (final seatId in _selectedSeats) {
      final remaining = SeatReservationService.instance.secondsRemaining(_screenKey, seatId);
      if (remaining < minRemaining) minRemaining = remaining;
    }
    setState(() => _secondsRemaining = minRemaining);
  }

  String get _countdownText {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildMovieInfo(context),
                    const SizedBox(height: AppSpacing.xl),
                    // Countdown banner
                    if (_selectedSeats.isNotEmpty) _buildCountdownBanner(context),
                    if (_selectedSeats.isNotEmpty) const SizedBox(height: AppSpacing.md),
                    _buildSeatLegend(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSeatGrid(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildScreenIndicator(context),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              // Release all seats this user selected when going back
              for (final seatId in _selectedSeats) {
                SeatReservationService.instance.releaseSeat(_screenKey, seatId);
              }
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            'Movix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          const SizedBox(width: AppSizes.iconLg),
        ],
      ),
    );
  }

  Widget _buildCountdownBanner(BuildContext context) {
    final isUrgent = _secondsRemaining < 60;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isUrgent ? Colors.red : AppColors.primary,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isUrgent ? Colors.red : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Seats reserved for $_countdownText — complete your booking before time runs out!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUrgent ? Colors.red : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.movieTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.date} • ${widget.showtime} • ${widget.cinema} ${widget.screen}'
          '${widget.format.isNotEmpty ? ' • ${widget.format}' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            '₹${_seatPrice.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(context, AppColors.surface, 'Available'),
        const SizedBox(width: AppSpacing.xl),
        _legendItem(context, AppColors.primary, 'Selected'),
        const SizedBox(width: AppSpacing.xl),
        _legendItem(context, AppColors.divider, 'Booked'),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid(BuildContext context) {
    final reservedSeats = SeatReservationService.instance.reservedSeats(_screenKey);
    
    // Also include seats that were fully paid/booked in MockData.bookings
    final permanentlyBookedSeats = MockData.bookings
        .where((b) =>
            b.movieTitle == widget.movieTitle &&
            b.date == widget.date &&
            b.time == widget.showtime &&
            (b.cinema == widget.cinema || b.cinema.startsWith('${widget.cinema} •')))
        .expand((b) => b.seats)
        .toSet();

    return Column(
      children: List.generate(_rowLabels.length, (rowIndex) {
        final row = _rowLabels[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  row,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 3),
              _buildBlock(context, row, 'L', 4, 1, reservedSeats, permanentlyBookedSeats),
              const SizedBox(width: 10),
              _buildBlock(context, row, 'C', 8, 5, reservedSeats, permanentlyBookedSeats),
              const SizedBox(width: 10),
              _buildBlock(context, row, 'R', 4, 13, reservedSeats, permanentlyBookedSeats),
              const SizedBox(width: 3),
              SizedBox(
                width: 16,
                child: Text(
                  row,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBlock(
    BuildContext context,
    String row,
    String section,
    int count,
    int startCol,
    Set<String> reservedSeats,
    Set<String> permanentlyBookedSeats,
  ) {
    return Expanded(
      flex: count,
      child: Row(
        children: List.generate(count, (col) {
          final seatNumber = startCol + col;
          final seatId = '$row-$seatNumber';
          
          // Bookings are saved as A1 instead of A-1
          final formattedSeatId = '$row$seatNumber';

          final isSelectedByMe = _selectedSeats.contains(seatId);
          final isPermanentlyBooked = permanentlyBookedSeats.contains(formattedSeatId);
          // A seat is "booked" if someone else reserved it (not this user) or it is permanently booked
          final isBookedByOther = (!isSelectedByMe && reservedSeats.contains(seatId)) || isPermanentlyBooked;

          return Expanded(
            child: GestureDetector(
              onTap: isBookedByOther
                  ? null
                  : () => _onSeatTap(seatId),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelectedByMe
                      ? AppColors.primary
                      : isBookedByOther
                          ? AppColors.divider
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$seatNumber',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: isSelectedByMe || isBookedByOther
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScreenIndicator(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 22),
        const SizedBox(height: 2),
        SizedBox(
          height: 20,
          width: double.infinity,
          child: CustomPaint(painter: _ScreenCurvePainter()),
        ),
        const SizedBox(height: 6),
        Text(
          'SCREEN',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA(BuildContext context) {
    final seatCount = _selectedSeats.length;
    final total = seatCount * _seatPrice;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (seatCount > 0) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$seatCount seat${seatCount > 1 ? 's' : ''} selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedSeats.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one seat'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final matchingMovie = MockData.allMovies.firstWhere(
                    (m) => m.title == widget.movieTitle,
                    orElse: () => MockData.featuredMovies.firstWhere(
                      (m) => m.title == widget.movieTitle,
                      orElse: () => MockData.allMovies.first,
                    ),
                  );

                  final seatsList = _selectedSeats.map((seatId) {
                    final parts = seatId.split('-');
                    return '${parts[0]}${parts[1]}';
                  }).toList()
                    ..sort();

                  final totalAmount = seatsList.length * _seatPrice;

                  final booking = BookingModel(
                    id: 'CP-${1000 + DateTime.now().millisecond}-X${100 + DateTime.now().second}',
                    movieTitle: widget.movieTitle,
                    moviePosterUrl: matchingMovie.posterUrl,
                    date: widget.date,
                    time: widget.showtime,
                    cinema: widget.format.isNotEmpty
                        ? '${widget.cinema} • ${widget.format}'
                        : widget.cinema,
                    seats: seatsList,
                    totalAmount: totalAmount,
                    experience: 'EXPERIENCE',
                    isConfirmed: true,
                  );

                  // Release reservations once heading to payment
                  // (payment completion should finalize the booking)
                  _countdownTimer?.cancel();

                  Navigator.pushNamed(context, '/payment', arguments: booking);
                },
                icon: const Icon(Icons.confirmation_number_outlined, size: 20),
                label: const Text('Book Tickets Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the curved screen indicator line
class _ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width * 0.95,
        size.height * 0.9,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
