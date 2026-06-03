import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/booking_model.dart';

/// ============================================================
/// Payment Screen — Checkout screen with:
/// - Header matching the theme
/// - Step indicator (Seats -> Payment -> Ticket)
/// - Interactive payment method cards (UPI vs Credit/Debit Card)
/// - Movie booking detail summary card with cinematic projection graphic
/// - Pay Securely action button which appends the ticket to mock data bookings
/// ============================================================

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Track the selected payment method: 0 = UPI, 1 = Credit/Debit Card
  int _selectedPaymentMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            _buildAppBar(context),

            // ── Main Content Area ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),

                    // ── Step Indicator ──
                    _buildStepIndicator(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Payment Methods Selector ──
                    _buildPaymentMethods(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Booking Summary Card ──
                    _buildBookingSummary(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Pay Securely Button ──
                    _buildPayButton(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar matching design: [Back] [CinePremium] [Location] [Search]
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),

          // Title
          Text(
            'CinePremium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
          ),
          const Spacer(),

          // Location Pin
          const Icon(
            Icons.location_on_outlined,
            size: AppSizes.iconLg,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.md),

          // Search Icon
          const Icon(
            Icons.search,
            size: AppSizes.iconLg,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  /// 3-Step Checkout Indicator: Seats (Checked) -> Payment (Active) -> Ticket (Inactive)
  Widget _buildStepIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1: Seats (Completed)
        _buildStepCircle(
          context,
          icon: Icons.check,
          label: 'Seats',
          isActive: true,
          isCompleted: true,
        ),
        
        // Connecting Line 1 (Red)
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            color: AppColors.primary,
          ),
        ),

        // Step 2: Payment (Active)
        _buildStepCircle(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Payment',
          isActive: true,
          isCompleted: false,
        ),

        // Connecting Line 2 (Grey)
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            color: AppColors.divider,
          ),
        ),

        // Step 3: Ticket (Inactive)
        _buildStepCircle(
          context,
          icon: Icons.confirmation_number_outlined,
          label: 'Ticket',
          isActive: false,
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildStepCircle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive 
                ? (isCompleted ? AppColors.primary : AppColors.primary)
                : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.divider,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.textWhite : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  /// Payment Methods List Card
  Widget _buildPaymentMethods(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF7E7E7E), // Figma slate-grey card background
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Option 1: UPI
          _buildPaymentMethodOption(
            context,
            index: 0,
            icon: Icons.account_balance_wallet_outlined,
            title: 'UPI',
            subtitle: 'GPay, PhonePe, Paytm',
          ),
          const SizedBox(height: AppSpacing.md),

          // Option 2: Card
          _buildPaymentMethodOption(
            context,
            index: 1,
            icon: Icons.credit_card_outlined,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, AMEX',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFEEBED).withValues(alpha: 0.15) // Highlighted transparent red
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: isSelected 
                              ? AppColors.textWhite.withValues(alpha: 0.8) 
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Custom radio button circle
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected 
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Movie booking summary card showing projector graphic + price details
  Widget _buildBookingSummary(BuildContext context) {
    // Generate cinema text Row H (2 Seats) etc.
    final rowLetter = widget.booking.seats.isNotEmpty ? widget.booking.seats.first[0] : 'H';
    final seatsCount = widget.booking.seats.length;
    final formattedDetail = '${widget.booking.cinema.replaceAll(' • ', ' • ')} • Row $rowLetter ($seatsCount Seats)';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF7E7E7E), // Figma slate-grey card background
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top projection image banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: Image.network(
              'https://picsum.photos/seed/projector/600/300',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.black26,
                child: const Center(
                  child: Icon(Icons.videocam_outlined, color: AppColors.textWhite, size: 40),
                ),
              ),
            ),
          ),

          // Detail Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Info block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.booking.movieTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDetail,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Amount details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${widget.booking.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Secure action button which saves ticket and navigates to Booking Details
  Widget _buildPayButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Add the newly created booking record to MockData
          MockData.bookings.insert(0, widget.booking);

          // Route to booking detail screen (representing step 3: ticket)
          Navigator.pushNamed(
            context,
            '/booking-detail',
            arguments: widget.booking,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
        ),
        child: const Text('Pay Securely'),
      ),
    );
  }
}
