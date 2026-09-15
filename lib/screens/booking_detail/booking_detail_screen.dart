import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/models/booking_model.dart';
import 'package:booking/widgets/app_image.dart';
import 'package:booking/services/ticket_pdf_service.dart';
import 'package:booking/core/utils/ist_time_utils.dart';

/// ============================================================
/// Booking Detail Screen — Confirmed ticket view with:
/// - Hero banner with movie poster
/// - Booking card (NOW PLAYING, title, confirmed status)
/// - Date, Time, Cinema, Seats info
/// - QR Code
/// - Booking ID
/// - Total amount + experience badge
/// - Download Ticket button (functional PDF download)
/// - Cancel Booking link
/// - Important Information section
/// ============================================================

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownloadTicket() async {
    if (_isDownloading) return;

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isDownloading = true;
    });

    try {
      final result = await TicketPdfService.downloadTicket(widget.booking);

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      messenger.clearSnackBars();
      if (result.success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ticket downloaded successfully.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to download ticket. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
      });

      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to download ticket. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
                child: Column(
                  children: [
                    // ── Hero banner with booking card overlay ──
                    _buildHeroBannerWithCard(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Booking details card ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildBookingInfoCard(context),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Download Ticket button ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildDownloadButton(context),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Done Button ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildDoneButton(context),
                    ),

                    // ── Important Information ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: _buildImportantInfo(context),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App bar: back arrow, Movix, share icon
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Movix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Share booking
            },
            child: const Icon(
              Icons.share_outlined,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Hero banner image with overlaid booking card
  Widget _buildHeroBannerWithCard(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Banner image ──
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppImage(
                    urlOrPath: widget.booking.moviePosterUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Overlaid booking card ──
          Positioned(
            bottom: 0,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Movie poster thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: AppImage(
                      urlOrPath: widget.booking.moviePosterUrl,
                      width: 70,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 90,
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.movie,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Movie info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // NOW PLAYING badge
                        Text(
                          'NOW PLAYING',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                        ),
                        const SizedBox(height: 4),

                        // Movie title
                        Text(
                          widget.booking.movieTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Confirmed Booking status
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Confirmed Booking',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
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
          ),
        ],
      ),
    );
  }

  /// Booking info card with date, time, cinema, seats, QR, amount, and IST timestamp
  Widget _buildBookingInfoCard(BuildContext context) {
    final istNow = IstTimeUtils.nowInIst();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    int hour = istNow.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minute = istNow.minute.toString().padLeft(2, '0');
    final formattedIst = '${istNow.day.toString().padLeft(2, '0')} ${months[istNow.month - 1]} ${istNow.year}, ${hour.toString().padLeft(2, '0')}:$minute $period IST';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // ── Date & Time row ──
          Row(
            children: [
              Expanded(child: _infoColumn(context, 'DATE', widget.booking.date)),
              Expanded(
                child: _infoColumn(
                  context,
                  'TIME',
                  widget.booking.time,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Divider ──
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.xl),

          // ── Cinema & Seats row ──
          Row(
            children: [
              Expanded(child: _infoColumn(context, 'THEATER', widget.booking.cinema)),
              Expanded(
                child: _infoColumn(
                  context,
                  'SEATS (${widget.booking.seats.length})',
                  widget.booking.seatsFormatted,
                  valueColor: AppColors.primary,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Screen row ──
          if (widget.booking.screen.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.xl),
            _infoColumn(context, 'SCREEN', widget.booking.screen),
          ],
          const SizedBox(height: AppSpacing.xxl),

          // ── QR Code placeholder ──
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2,
                size: 80,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Booking ID ──
          Text(
            'ID: ${widget.booking.id}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          // ── IST Booking Timestamp ──
          Text(
            'Booked on: $formattedIst',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Divider ──
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.lg),

          // ── Total amount row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount Paid',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${widget.booking.totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              // Experience badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  widget.booking.experience,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable info column (label + value)
  Widget _infoColumn(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Download Ticket button
  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isDownloading ? null : _handleDownloadTicket,
        icon: _isDownloading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite,
                ),
              )
            : const Icon(Icons.download, size: 20),
        label: Text(_isDownloading ? 'Downloading...' : 'Download Ticket'),
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
    );
  }

  /// Important Information section
  Widget _buildImportantInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Important Information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Info text
          Text(
            'Please arrive at least 15 minutes before the showtime. You can present this digital ticket at the entrance for scanning. Cancellations are permitted up to 2 hours before the movie starts.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Done button to go to home page
  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        child: const Text('Done'),
      ),
    );
  }
}
