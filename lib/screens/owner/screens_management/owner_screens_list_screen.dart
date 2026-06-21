import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';
import 'package:booking/screens/owner/screens_management/owner_add_screen.dart';

class OwnerScreensListScreen extends StatefulWidget {
  const OwnerScreensListScreen({super.key});

  @override
  State<OwnerScreensListScreen> createState() => _OwnerScreensListScreenState();
}

class _OwnerScreensListScreenState extends State<OwnerScreensListScreen> {

  final TextEditingController _standardRateCtrl = TextEditingController(
    text: '14.00',
  );

  @override
  void dispose() {
    _standardRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminAppBar(noLeading: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header (Screens & Add Button) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Screens',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OwnerAddScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: AppSizes.iconMd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Screens List ──
            _buildScreenCard(title: 'Screen 01', seats: 124, isActive: true),
            const SizedBox(height: AppSpacing.md),
            _buildScreenCard(title: 'Screen 02', seats: 88, isActive: false),
            const SizedBox(height: AppSpacing.xl),

            // ── Set Pricing Section ──
            Text(
              'Set Pricing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Rate (₹)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            AdminTextField(
              controller: _standardRateCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AdminButton(text: 'Update Rates', onPressed: () {}),
            const SizedBox(height: AppSpacing.xxl),

            // ── Layout Editor Section ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Layout Editor',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Screen 01\nConfiguration',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Adjust the seating chart for the main\nauditorium hall.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Legend
                  Row(
                    children: [
                      _buildLegendItem(Colors.transparent, '2D', true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Screen visual
                  Center(
                    child: Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      'S C R E E N   T H I S   W A Y',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(letterSpacing: 2.0),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Seating grid (mock)
                  _buildSeatingGrid(),

                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(
                        'Reset\nLayout',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Capacity summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CAPACITY',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '124 ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                    ),
                                    TextSpan(
                                      text: 'seats',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenCard({
    required String title,
    required int seats,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isActive ? null : Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActive) ...[
                  Text(
                    'NOW EDITING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isActive
                        ? AppColors.textWhite
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.chair_outlined,
                      size: AppSizes.iconSm,
                      color: isActive
                          ? AppColors.textWhite
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$seats Seats Total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isActive
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.grid_view_rounded : Icons.grid_view_outlined,
            color: isActive ? AppColors.textWhite : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, [bool isOutlined = false]) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isOutlined ? Border.all(color: AppColors.divider) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSeatingGrid() {
    // This is a static visual representation of the seating grid from Figma
    return Column(
      children: [
        _buildRow('A', 6),
        _buildRow('', 3, offset: 2),
        _buildRow('B', 6),
        _buildRow('', 3, offset: 2),
        _buildRow('C', 6),
        _buildRow('', 2, offset: 3),
        _buildRow('D', 6),
        _buildRow('', 2, offset: 3),
        _buildRow('E', 6),
        _buildRow('', 2, offset: 3),
      ],
    );
  }

  Widget _buildRow(
    String label,
    int count, {
    int offset = 0,
  }) {
    List<Widget> seats = [];
    for (int i = 0; i < count; i++) {
      seats.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.divider),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: offset * 32.0), // Spacer
          ...seats,
          SizedBox(
            width: 20,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
