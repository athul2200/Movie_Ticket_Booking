import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/widgets/bottom_nav_bar.dart';
import 'package:booking/screens/my_bookings/my_bookings_screen.dart';

/// ============================================================
/// Profile Screen — Complete profile settings view with:
/// - Header matching the CinePremium theme
/// - Profile photo (Alexander Sterling) with red pencil edit icon
/// - Interactive form fields (Name, Email, Phone) and Save button
/// - Custom dashed-border browse banner that routes back to Home tab
/// - History list items reusing the HistoryBookingCard
/// ============================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Text editing controllers for the profile form
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter history bookings for history card list
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

            // ── Scrollable form and details ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // ── Profile Photo with edit badge ──
                    _buildProfileAvatar(context),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Title Header ──
                    Text(
                      'Profile Settings',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Profile Input Fields ──
                    _buildFormFields(context),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Save Changes Button ──
                    _buildSaveButton(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Section: My Bookings ──
                    _buildMyBookingsHeader(context),
                    const SizedBox(height: AppSpacing.md),

                    // ── History Bookings Cards ──
                    ...historyBookings.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: HistoryBookingCard(booking: booking),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Dashed Browse Banner ──
                    _buildBrowseBanner(context),
                    const SizedBox(height: AppSpacing.xxl),

                    // Switch to Admin Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/owner');
                        },
                        icon: const Icon(
                          Icons.admin_panel_settings,
                          color: AppColors.primary,
                        ),
                        label: const Text('Switch to Owner View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                    ),
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

  /// App Bar matching design: [CinePremium] [Search]
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Red Location icon & CinePremium centered
          const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: AppSizes.iconLg,
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

  /// Profile Circle avatar picture with red pencil edit overlay badge
  Widget _buildProfileAvatar(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Outer circular border/glow
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: AppColors.divider,
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!)) as ImageProvider
                  : const NetworkImage(
                      'https://picsum.photos/seed/alexander/200/200',
                    ),
            ),
          ),

          // Red Edit icon badge
          Positioned(
            right: 0,
            bottom: 4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2.0),
                ),
                child: const Icon(
                  Icons.edit,
                  color: AppColors.textWhite,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Input fields: Full Name, Email Address, Phone Number
  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          context,
          label: 'Full Name',
          controller: _nameController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          context,
          label: 'Email Address',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          context,
          label: 'Phone Number',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// Save button widget
  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.greenAccent,
            ),
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
        child: const Text('Save Changes'),
      ),
    );
  }

  /// Header row for bookings: "My Bookings" & "View History"
  Widget _buildMyBookingsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Bookings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Route to My Bookings tab (index 1 of BottomNavBar)
            context.findAncestorStateOfType<BottomNavBarState>()?.setIndex(1);
          },
          child: Text(
            'View History',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// Dashed border browse promo banner which navigates back to movie selection
  Widget _buildBrowseBanner(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.divider,
        strokeWidth: 1.0,
        gap: 4.0,
        dash: 6.0,
        radius: 12.0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 32,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No upcoming premieres? Time to find\nyour next movie.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            GestureDetector(
              onTap: () {
                // Navigate back to the Home/Discover Movies tab (index 0)
                context.findAncestorStateOfType<BottomNavBarState>()?.setIndex(
                  0,
                );
              },
              child: Text(
                'Browse Now',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw beautiful dashed borders around the promo card
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double radius;

  _DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dash = 6.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = _buildDashPath(path, dash, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashPath(Path source, double dash, double gap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? dash : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
