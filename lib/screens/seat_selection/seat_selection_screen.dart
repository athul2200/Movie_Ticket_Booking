import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';

/// ============================================================
/// Seat Selection Screen — Cinema seat map with:
/// - Movie info header (title, time, cinema, format)
/// - Curved screen indicator
/// - Seat legend (Available, Selected, Booked)
/// - Interactive seat grid (rows A-J, two sections)
/// - Bottom navigation bar
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
  // Track selected seats as set of "row-col" strings
  final Set<String> _selectedSeats = {};

  // Predefined booked seats (simulating already-booked seats)
  final Set<String> _bookedSeats = {
    '0-J-2',
    '0-J-3',
    '0-H-1',
    '0-H-4',
    '0-H-5',
    '0-F-1',
    '0-F-2',
    '0-F-5',
    '0-F-6',
    '0-E-0',
    '0-E-1',
    '0-E-2',
    '0-E-3',
    '0-E-4',
    '0-E-5',
    '0-E-6',
    '0-E-7',
    '0-D-2',
    '0-D-3',
    '0-D-4',
    '0-D-5',
    '0-C-0',
    '0-C-3',
    '0-C-4',
    '0-B-0',
    '0-B-1',
    '0-B-2',
    '0-B-3',
    '0-B-4',
    '0-B-5',
    '0-B-6',
    '0-B-7',
    '0-A-0',
    '0-A-1',
    '0-A-4',
    '0-A-5',
    '0-A-6',
    '0-A-7',
    '1-J-2',
    '1-J-3',
    '1-J-4',
    '1-I-0',
    '1-I-3',
    '1-I-4',
    '1-H-3',
    '1-H-4',
    '1-H-5',
    '1-G-0',
    '1-G-1',
    '1-G-2',
    '1-G-3',
    '1-G-4',
    '1-G-5',
    '1-G-6',
    '1-G-7',
    '1-F-0',
    '1-F-1',
    '1-F-4',
    '1-F-5',
    '1-F-6',
    '1-F-7',
    '1-E-0',
    '1-E-1',
    '1-E-2',
    '1-E-3',
    '1-E-5',
    '1-E-6',
    '1-E-7',
    '1-D-2',
    '1-D-3',
    '1-D-4',
    '1-D-5',
    '1-C-0',
    '1-C-1',
    '1-C-2',
    '1-C-3',
    '1-C-4',
    '1-C-5',
    '1-C-6',
    '1-C-7',
    '1-B-0',
    '1-B-1',
    '1-B-2',
    '1-B-3',
    '1-B-4',
    '1-B-5',
    '1-B-6',
    '1-B-7',
    '1-A-0',
    '1-A-1',
    '1-A-2',
    '1-A-3',
    '1-A-4',
    '1-A-5',
    '1-A-6',
    '1-A-7',
  };

  // Row labels from top to bottom per section
  static const List<String> _rowLabels = [
    'J',
    'I',
    'H',
    'G',
    'F',
    'E',
    'D',
    'C',
    'B',
    'A',
  ];
  static const int _seatsPerRow = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            _buildAppBar(context),

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    // ── Movie info ──
                    _buildMovieInfo(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Screen indicator ──
                    _buildScreenIndicator(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Seat legend ──
                    _buildSeatLegend(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Seat grid — Upper section ──
                    _buildSeatSection(context, 0),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Seat grid — Lower section ──
                    _buildSeatSection(context, 1),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),

            // ── Bottom Book Tickets CTA ──
            _buildBottomCTA(context),
          ],
        ),
      ),
    );
  }

  /// App Bar: back arrow + CinePremium
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
            'CinePremium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          // Empty space to balance the back arrow
          const SizedBox(width: AppSizes.iconLg),
        ],
      ),
    );
  }

  /// Movie info: title, date, time, cinema, format
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

  /// Curved screen indicator
  Widget _buildScreenIndicator(BuildContext context) {
    return Column(
      children: [
        // Curved line representing the screen
        SizedBox(
          height: 24,
          width: double.infinity,
          child: CustomPaint(painter: _ScreenCurvePainter()),
        ),
        const SizedBox(height: 6),
        Text(
          'SCREEN',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  /// Seat legend: Available, Selected, Booked
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

  /// Build one seat section (upper or lower half of theater)
  Widget _buildSeatSection(BuildContext context, int sectionIndex) {
    return Column(
      children: List.generate(_rowLabels.length, (rowIndex) {
        final rowLabel = _rowLabels[rowIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              // Row label (left)
              SizedBox(
                width: 18,
                child: Text(
                  rowLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),

              // Seats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_seatsPerRow, (colIndex) {
                    final seatId = '$sectionIndex-$rowLabel-$colIndex';
                    final isBooked = _bookedSeats.contains(seatId);
                    final isSelected = _selectedSeats.contains(seatId);

                    return GestureDetector(
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
                        width: 28,
                        height: 28,
                        margin: EdgeInsets.only(
                          right: colIndex < _seatsPerRow - 1 ? 4 : 0,
                          // Add extra gap for aisle in the middle
                          left: colIndex == _seatsPerRow ~/ 2 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isBooked
                              ? AppColors.divider
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(width: 4),
              // Row label (right)
              SizedBox(
                width: 18,
                child: Text(
                  rowLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
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

  /// Fixed bottom CTA bar with "Book Tickets Now" button + ticket icon
  Widget _buildBottomCTA(BuildContext context) {
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
      child: SizedBox(
        width: double.infinity,
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

            // Create mock booking model using selected seats
            final matchingMovie = MockData.allMovies.firstWhere(
              (m) => m.title == widget.movieTitle,
              orElse: () => MockData.featuredMovies.firstWhere(
                (m) => m.title == widget.movieTitle,
                orElse: () => MockData.allMovies.first,
              ),
            );

            final seatsList = _selectedSeats.map((seatId) {
              final parts = seatId.split('-');
              final row = parts[1];
              final col = int.parse(parts[2]) + 1;
              return '$row$col';
            }).toList();
            seatsList.sort();

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
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width * 0.9,
        size.height * 0.8,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
