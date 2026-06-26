import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';

/// ============================================================
/// My Bookings Screen — Shows booking history only.
/// ============================================================

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allBookings = MockData.bookings.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: allBookings.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: allBookings.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) =>
                          BookingCard(booking: allBookings[index]),
                    ),
            ),
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
          const Icon(Icons.location_on, color: AppColors.primary, size: AppSizes.iconLg),
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
          const Icon(Icons.search, color: AppColors.textPrimary, size: AppSizes.iconLg),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will be saved here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Booking card featuring the horizontal split layout and "Details" button
class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF7E7E7E),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Section — Movie Poster
              SizedBox(
                width: 95,
                child: Image.network(
                  booking.moviePosterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.black26,
                    child: const Icon(Icons.movie, color: AppColors.textWhite),
                  ),
                ),
              ),

              // Right Section — Booking Info + CTA button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'STANDARD',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                              const Icon(Icons.qr_code, size: 14, color: AppColors.textWhite),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.movieTitle,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                              const Icon(Icons.calendar_today, size: 10, color: AppColors.textWhite),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.date} • ${booking.time}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textWhite.withValues(alpha: 0.8),
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
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 8,
                                  color: AppColors.textWhite.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                booking.seatsFormatted,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
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
                                backgroundColor: AppColors.background.withValues(alpha: 0.2),
                                foregroundColor: AppColors.textWhite,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              child: const Text(
                                'Details',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
