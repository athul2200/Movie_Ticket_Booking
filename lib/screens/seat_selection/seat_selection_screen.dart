import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';

/// ============================================================
/// Seat Selection Screen — 3-section cinema seat map:
///   Left (3 seats) | Aisle | Center (6 seats) | Aisle | Right (3 seats)
/// ============================================================

class SeatSelectionScreen extends StatefulWidget {
  final String movieTitle;
  final String showtime;
  final String cinema;
  final String format;

  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.showtime,
    required this.cinema,
    required this.format,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  // Track selected seats as "row-section-col"
  final Set<String> _selectedSeats = {};

  // Row labels top → bottom (J to A)
  static const List<String> _rowLabels = [
    'A','B','C','D','E','F','G','H','I','J',
  ];

  // Pre-booked seats
  final Set<String> _bookedSeats = {};

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
            onTap: () => Navigator.pop(context),
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
          'Today, ${widget.showtime} • ${widget.cinema} • ${widget.format}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
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

  /// Full seat grid — 3 blocks per row: Left(3) | Center(6) | Right(3)
  Widget _buildSeatGrid(BuildContext context) {
    return Column(
      children: List.generate(_rowLabels.length, (rowIndex) {
        final row = _rowLabels[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Row label left
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

              // Left block — 4 seats
              _buildBlock(context, row, 'L', 4, 1),

              // Aisle gap
              const SizedBox(width: 10),

              // Center block — 8 seats
              _buildBlock(context, row, 'C', 8, 5),

              // Aisle gap
              const SizedBox(width: 10),

              // Right block — 4 seats
              _buildBlock(context, row, 'R', 4, 13),

              const SizedBox(width: 3),
              // Row label right
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
      BuildContext context, String row, String section, int count, int startCol) {
    return Expanded(
      flex: count,
      child: Row(
        children: List.generate(count, (col) {
          final seatNumber = startCol + col;
          final seatId = '$row-$seatNumber';
          final isBooked = _bookedSeats.contains(seatId);
          final isSelected = _selectedSeats.contains(seatId);

          return Expanded(
            child: GestureDetector(
              onTap: isBooked
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _selectedSeats.remove(seatId);
                        } else {
                          _selectedSeats.add(seatId);
                        }
                      });
                    },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isBooked
                          ? AppColors.divider
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$seatNumber',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: isSelected || isBooked ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Screen indicator at the bottom (matching the image — downward arrow + curve)
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
    final total = seatCount * 16.00;

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
                  '\$${total.toStringAsFixed(2)}',
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
                        backgroundColor: AppColors.primary,
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

                  final totalAmount = seatsList.length * 16.00;

                  final booking = BookingModel(
                    id: 'CP-${1000 + DateTime.now().millisecond}-X${100 + DateTime.now().second}',
                    movieTitle: widget.movieTitle,
                    moviePosterUrl: matchingMovie.posterUrl,
                    date: 'Today, Oct 12',
                    time: widget.showtime,
                    cinema: '${widget.cinema} • ${widget.format}',
                    seats: seatsList,
                    totalAmount: totalAmount,
                    experience: 'STANDARD EXPERIENCE',
                    isConfirmed: true,
                  );

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
