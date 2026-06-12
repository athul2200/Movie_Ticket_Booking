import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';

class OwnerScreenDetailsScreen extends StatefulWidget {
  const OwnerScreenDetailsScreen({super.key});

  @override
  State<OwnerScreenDetailsScreen> createState() =>
      _OwnerScreenDetailsScreenState();
}

class _OwnerScreenDetailsScreenState extends State<OwnerScreenDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AdminAppBar(showBackButton: true),
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
              'Screen 01',
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
                _buildBadge(
                  '4K LASER',
                  AppColors.divider,
                  AppColors.textSecondary,
                ),
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
                              'Dune: Part Two',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: Theme.of(context).textTheme.titleSmall
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
                            const Icon(
                              Icons.access_time,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '02:45 PM - 05:30 PM',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '(165 mins)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            const Icon(
                              Icons.masks_outlined,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Sci-Fi, Adventure, Drama',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
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

            // ── Show Revenue Card ──
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
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
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
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textWhite.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                          ),
                          Text(
                            '82%',
                            style: Theme.of(context).textTheme.labelSmall
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
                    _buildLegendItem(
                      AppColors.background,
                      'Available',
                      isOutlined: true,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildLegendItem(AppColors.primaryDark, 'Booked'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildLegendItem(AppColors.divider, 'Occupied'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

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
                  Center(
                    child: Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'STANDARD SCREEN',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Seating Rows
                  _buildSeatingRow('A', [1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0]),
                  const SizedBox(height: AppSpacing.md),
                  _buildSeatingRow('B', [1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1]),
                  const SizedBox(height: AppSpacing.md),
                  _buildSeatingRow('C', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),

                  const SizedBox(height: AppSpacing.xl),
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: AppColors.primary,
                    ),
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
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(letterSpacing: 1.0),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '120',
                            style: Theme.of(context).textTheme.headlineMedium
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
                            '85',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          Text(
                            'Booked (71%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LinearProgressIndicator(
                    value: 0.71,
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

  Widget _buildLegendItem(
    Color color,
    String label, {
    bool isOutlined = false,
  }) {
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSeatingRow(String rowLabel, List<int> seatStatuses) {
    // 0 = Available, 1 = Booked, 2 = Occupied
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Text(rowLabel, style: Theme.of(context).textTheme.labelSmall),
        ),
        ...seatStatuses.map((status) {
          Color bgColor;
          bool isOutlined = false;

          if (status == 1) {
            bgColor = AppColors.primaryDark;
          } else if (status == 2) {
            bgColor = AppColors.divider; // Grey for occupied
          } else {
            bgColor = AppColors.background;
            isOutlined = true;
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: bgColor,
              border: isOutlined ? Border.all(color: AppColors.divider) : null,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ],
    );
  }
}
