import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';
import 'package:booking/screens/owner/movies_management/owner_movies_screen.dart';
import 'package:booking/screens/owner/schedule_management/owner_schedule_screen.dart';
import 'package:booking/screens/owner/screens_management/owner_screens_status_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMovies;

  const OwnerDashboardScreen({super.key, this.onNavigateToMovies});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const AdminAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'THEATER MANAGER DASHBOARD',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Welcome back,\nGrand Cinema',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: AdminButton(
                    text: 'Add Movie',
                    onPressed: () {
                      if (widget.onNavigateToMovies != null) {
                        widget.onNavigateToMovies!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OwnerMoviesScreen(),
                          ),
                        );
                      }
                    },
                    icon: Icons.add,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerScheduleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                    label: Text(
                      'Schedule\nShows',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Stats Grid ──
            _buildStatCard(
              icon: Icons.grid_view_rounded,
              title: 'Total Screens',
              value: '12',
              badgeText: 'Real-time',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerScreensStatusScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatCard(
              icon: Icons.movie_creation_outlined,
              title: 'Active Movies',
              value: '08',
              badgeText: 'In Rotation',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatCard(
              icon: Icons.calendar_today_outlined,
              title: 'Today\'s Shows',
              value: '42',
              badgeText: 'Today',
            ),
            const SizedBox(height: AppSpacing.md),

            // Total Revenue Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.textWhite,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Total Revenue',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textWhite.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '\$14.2k',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Daily Est',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Current Screen Status ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Screen\nStatus',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All\nScreens',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildScreenStatusCard(
              movieTitle: 'Dune: Part Two',
              screenName: 'SCREEN 01 - IMAX',
              imageUrl:
                  'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=1000&auto=format&fit=crop', // Sand dunes visual
              occupancy: 0.73,
              timeLabel: 'Ends at',
              timeValue: '14:45',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildScreenStatusCard(
              movieTitle: 'Oppenheimer',
              screenName: 'SCREEN 02 - STANDARD',
              imageUrl:
                  'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1000&auto=format&fit=crop', // Abstract lights visual
              occupancy: 0.30,
              timeLabel: 'Next Show',
              timeValue: '15:15',
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Staff on Duty ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff on Duty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '12 Active',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildStaffItem(
                    'JD',
                    'Jane Doe',
                    'Floor Manager • Screen 01-04',
                    'ON SHIFT',
                    AppColors.greenAccent,
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                  _buildStaffItem(
                    'MS',
                    'Marcus Smith',
                    'Technician • Projection Room',
                    'ON SHIFT',
                    AppColors.greenAccent,
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                  _buildStaffItem(
                    'SL',
                    'Sarah Lee',
                    'Concessions • Main Lobby',
                    'BREAK',
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Daily Insights ──
            Text(
              'Daily Insights',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
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
                children: [
                  _buildInsightBar(
                    'Concessions Revenue',
                    '\$3,420',
                    0.8,
                    AppColors.primaryDark,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInsightBar(
                    'Ticket Sales Target',
                    '620/1000',
                    0.62,
                    AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Top Performing Movie ──
            Text(
              'Top Performing Movie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      'https://picsum.photos/seed/bladerunner/100/100', // Placeholder
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blade Runner 2049',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RE-RELEASE • IMAX',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '98% Satisfaction',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Support Alert ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Support Alert',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Maintenance scheduled for Screen 02 projector at 02:00 AM tonight.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      side: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: Text(
                      'Acknowledge',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String badgeText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                badgeText,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenStatusCard({
    required String movieTitle,
    required String screenName,
    required String imageUrl,
    required double occupancy,
    required String timeLabel,
    required String timeValue,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
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
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        screenName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      movieTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          const Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Occupancy',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: occupancy,
                              backgroundColor: AppColors.divider,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryDark,
                              ),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(occupancy * 100).toInt()}%',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeValue,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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

  Widget _buildStaffItem(
    String initials,
    String name,
    String role,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE0E0E0),
            radius: 20,
            child: Text(
              initials,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(role, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBar(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.divider,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
