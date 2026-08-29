import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/models/seat_row_model.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/seat_selection/seat_selection_screen.dart';
import 'package:booking/services/seat_reservation_service.dart';

/// Detailed view for a single cinema screen in the Owner module.
///
/// Shows movie info, revenue, and a live seating occupancy map built
/// directly from [MockData.screenLayouts] — the same data that backs
/// the user-facing seat selection screen.
class OwnerScreenDetailsScreen extends StatefulWidget {
  final String theaterName;
  final String screenName;

  const OwnerScreenDetailsScreen({
    super.key,
    this.theaterName = 'Kairali',
    this.screenName = 'Screen 01',
  });

  @override
  State<OwnerScreenDetailsScreen> createState() =>
      _OwnerScreenDetailsScreenState();
}

class _OwnerScreenDetailsScreenState extends State<OwnerScreenDetailsScreen> {
  // Key used by SeatReservationService for this screen
  late final String _screenKey;

  // Seats permanently booked via confirmed bookings
  late final Set<String> _permanentlyBooked;

  @override
  void initState() {
    super.initState();
    // Use a fixed showtime key for the overview (we show aggregate status)
    _screenKey = SeatReservationService.screenKey(
      cinema: widget.theaterName,
      screen: widget.screenName,
      date: '24 Apr',
      showtime: '10:00 AM',
    );

    _permanentlyBooked = MockData.bookings
        .where((b) =>
            b.cinema == widget.theaterName ||
            b.cinema.startsWith('${widget.theaterName} •'))
        .expand((b) => b.seats)
        .toSet();
  }

  List<MovieModel> get _theaterMovies =>
      MockData.allMovies.where((m) => m.theaters.contains(widget.theaterName)).toList();

  List<SeatRow> get _rows =>
      MockData.getLayout(widget.theaterName, widget.screenName);

  int get _totalCapacity => _rows.fold(0, (s, r) => s + r.seatCount);

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final reservedSeats =
        SeatReservationService.instance.reservedSeats(_screenKey);
    final bookedCount = reservedSeats.length + _permanentlyBooked.length;
    final bookedPercent =
        _totalCapacity > 0 ? (bookedCount / _totalCapacity).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(
        title: widget.theaterName,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'AUDITORIUM DETAILS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.screenName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _buildBadge('LIVE NOW', AppColors.primary, AppColors.textWhite),
                const SizedBox(width: AppSpacing.sm),
                _buildBadge('2D', AppColors.divider, AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Movie Card ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _theaterMovies.isNotEmpty
                                  ? _theaterMovies.first.title
                                  : 'No Movie Listed',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '10:00 AM - 01:00 PM',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '(165 mins)',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.masks_outlined,
                                color: AppColors.textSecondary, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Sci-Fi, Adventure, Drama',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Revenue Card ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.local_activity,
                      size: 100,
                      color: AppColors.textWhite.withValues(alpha: 0.1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHOW REVENUE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '\$2,450.00',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quota Progress',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textWhite
                                      .withValues(alpha: 0.8),
                                ),
                          ),
                          Text(
                            '82%',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      LinearProgressIndicator(
                        value: 0.82,
                        backgroundColor: AppColors.primaryDark,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textWhite,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Seating Occupancy ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    'Seating\nOccupancy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegendItem(AppColors.background, 'Available',
                        isOutlined: true),
                    const SizedBox(width: AppSpacing.sm),
                    _buildLegendItem(AppColors.primaryDark, 'Booked'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildLegendItem(AppColors.divider, 'Reserved'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Live Seat Map ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Screen bar at top
                  Center(
                    child: Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'S C R E E N',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 3,
                      fontSize: 8,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Dynamic seat grid from MockData.screenLayouts
                  if (_rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl),
                      child: Column(
                        children: [
                          Icon(Icons.chair_outlined,
                              size: 36, color: AppColors.divider),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No seating layout defined.\nSet one up in the Layout Editor.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _rows.map((row) {
                          return _buildSeatRow(
                            context,
                            row,
                            reservedSeats,
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  const SizedBox(height: AppSpacing.sm),

                  // Link to open the full interactive seat selection screen
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeatSelectionScreen(
                            movieTitle: MockData.allMovies.isNotEmpty
                                ? MockData.allMovies.first.title
                                : 'No Movie Listed',
                            showtime: '10:00 AM',
                            cinema: widget.theaterName,
                            screen: widget.screenName,
                            format: '2D',
                            date: '24 Apr',
                            isReadOnly: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new,
                        size: 16, color: AppColors.primary),
                    label: Text(
                      'Open Full Interactive Seating Chart',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Availability Breakdown ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVAILABILITY BREAKDOWN',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_totalCapacity',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Total Capacity',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$bookedCount',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          Text(
                            'Booked (${(bookedPercent * 100).toStringAsFixed(0)}%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LinearProgressIndicator(
                    value: bookedPercent,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryDark,
                    ),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SEAT ROW
  // ─────────────────────────────────────────────

  Widget _buildSeatRow(
    BuildContext context,
    SeatRow row,
    Set<String> reservedSeats,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left label
          SizedBox(
            width: 18,
            child: Text(
              row.rowName,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Seat boxes
          ...List.generate(row.seatCount, (i) {
            final seatNum = i + 1;
            final seatId = '${row.rowName}-$seatNum';
            final formattedId = '${row.rowName}$seatNum';

            final isPermanentlyBooked =
                _permanentlyBooked.contains(formattedId);
            final isReserved =
                !isPermanentlyBooked && reservedSeats.contains(seatId);

            Color bgColor;
            Color textColor;
            bool isOutlined = false;

            if (isPermanentlyBooked) {
              bgColor = AppColors.primaryDark;
              textColor = Colors.white;
            } else if (isReserved) {
              bgColor = AppColors.divider;
              textColor = Colors.white;
            } else {
              bgColor = AppColors.background;
              textColor = AppColors.textSecondary;
              isOutlined = true;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(4),
                border: isOutlined
                    ? Border.all(color: AppColors.divider)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$seatNum',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(width: 4),
          // Right label
          SizedBox(
            width: 18,
            child: Text(
              row.rowName,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool isOutlined = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            border: isOutlined ? Border.all(color: AppColors.divider) : null,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
