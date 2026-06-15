import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/widgets/dashed_divider.dart';

/// ============================================================
/// My Bookings Screen — Shows upcoming and past tickets.
/// Refactored with:
/// - Custom tab bar switcher ("Upcoming" and "History")
/// - Ticket Stub ticket card (with circular edge notches and QR code)
/// - Collapsed item list with right arrow navigations
/// - History list items matching the premium cinematic card style
/// ============================================================

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // Current active tab: 0 = Upcoming, 1 = History
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    // Filter bookings based on active tab
    final upcomingBookings = MockData.bookings
        .where((b) => !b.isHistory)
        .toList();
    final historyBookings = MockData.bookings
        .where((b) => b.isHistory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar Header ──
            _buildAppBar(context),

            // ── Custom Segmented Tabs ──
            _buildTabs(context),
            const SizedBox(height: AppSpacing.md),

            // ── Screen Content ──
            Expanded(
              child: _activeTab == 0
                  ? _buildUpcomingList(context, upcomingBookings)
                  : _buildHistoryList(context, historyBookings),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar matching layout: [Location Pin] [Movix] [Search]
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Red Location icon
          const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: AppSizes.iconLg,
          ),
          const Spacer(),

          // Centered Movix text logo
          Text(
            'Movix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),

          // Search icon
          const Icon(
            Icons.search,
            color: AppColors.textPrimary,
            size: AppSizes.iconLg,
          ),
        ],
      ),
    );
  }

  /// Custom tab bar with Upcoming and History options
  Widget _buildTabs(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabItem(
              context,
              label: 'Upcoming',
              isSelected: _activeTab == 0,
              onTap: () => setState(() => _activeTab = 0),
            ),
          ),
          Expanded(
            child: _tabItem(
              context,
              label: 'History',
              isSelected: _activeTab == 1,
              onTap: () => setState(() => _activeTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            height: 3,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        context,
        'No upcoming bookings',
        'Find your next movie premiere on the home tab',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: bookings.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return _TicketStubCard(booking: bookings[index]);
      },
    );
  }

  /// Historical Bookings Content List
  Widget _buildHistoryList(BuildContext context, List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        context,
        'No past bookings',
        'Your booking history will be saved here',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: bookings.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return HistoryBookingCard(booking: bookings[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// A Premium Ticket Stub Card with custom circular notches and a QR Code
class _TicketStubCard extends StatelessWidget {
  final BookingModel booking;

  const _TicketStubCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Base grey ticket container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF7E7E7E), // Figma slate-grey card background
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Ticket Section ──
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.network(
                        booking.moviePosterUrl,
                        width: 85,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 85,
                          height: 120,
                          color: Colors.black26,
                          child: const Icon(
                            Icons.movie,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Movie Info details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.movieTitle,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.textWhite,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'STANDARD',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.textWhite,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Date Info
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: AppColors.textWhite,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.date} • ${booking.time}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textWhite.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),

                          // Cinema & Seats Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CINEMA',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: AppColors.textWhite
                                                .withValues(alpha: 0.6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      booking.cinema,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textWhite,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SEATS',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: AppColors.textWhite
                                                .withValues(alpha: 0.6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      booking.seatsFormatted,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dashed Divider Segment ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: DashedDivider(
                  color: Colors.white30,
                  height: 1.5,
                  dashWidth: 6,
                  dashGap: 4,
                ),
              ),

              // ── Bottom QR Stub Section ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // White square containing QR icon
                      Container(
                        width: 130,
                        height: 130,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2,
                            size: 100,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Scan at the entrance of ${booking.cinema}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Circular Edge Notch Masking ──
        // Left Notch Cutout
        Positioned(
          left: -8,
          top: 147, // Centered precisely with the dashed divider
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Right Notch Cutout
        Positioned(
          right: -8,
          top: 147,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// History booking card featuring the horizontal split layout and "Details" button
class HistoryBookingCard extends StatelessWidget {
  final BookingModel booking;

  const HistoryBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF7E7E7E), // Medium slate-grey background
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Section (30% width) - Movie Poster
              SizedBox(
                width: 95,
                child: Image.network(
                  booking.moviePosterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black26,
                    child: const Icon(Icons.movie, color: AppColors.textWhite),
                  ),
                ),
              ),

              // Right Section (70% width) - Booking Info + CTA button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'STANDARD',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                ),
                              ),
                              const Icon(
                                Icons.qr_code,
                                size: 14,
                                color: AppColors.textWhite,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.movieTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textWhite,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 10,
                                color: AppColors.textWhite,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.date} • ${booking.time}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textWhite.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Seats & Details button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEATS',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 8,
                                      color: AppColors.textWhite.withValues(
                                        alpha: 0.6,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                booking.seatsFormatted,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textWhite,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),

                          // Details CTA button
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/booking-detail',
                                  arguments: booking,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.background
                                    .withValues(alpha: 0.2),
                                foregroundColor: AppColors.textWhite,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
