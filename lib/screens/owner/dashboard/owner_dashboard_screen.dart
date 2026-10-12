import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';
import 'package:booking/screens/owner/movies_management/add_movie_screen.dart';
import 'package:booking/screens/owner/schedule_management/owner_schedule_screen.dart';
import 'package:booking/screens/owner/screens_management/owner_screens_status_screen.dart';
import 'package:booking/data/mock_data.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMovies;
  final String theaterName;

  const OwnerDashboardScreen({
    super.key,
    this.onNavigateToMovies,
    this.theaterName = 'Kairali',
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(title: widget.theaterName),
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
              'Welcome back,\n${widget.theaterName}',
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMovieScreen(theaterName: widget.theaterName),
                        ),
                      );
                      if (result == true) {
                        setState(() {});
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
                          builder: (_) => OwnerScheduleScreen(theaterName: widget.theaterName),
                        ),
                      ).then((_) => setState(() {}));
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
              value: '2',
              badgeText: 'Real-time',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerScreensStatusScreen(theaterName: widget.theaterName),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Builder(
              builder: (context) {
                final totalMoviesCount = MockData.allMovies.where((m) =>
                  m.theaters.any((t) => MockData.theaterMatches(t, widget.theaterName)) ||
                  MockData.isMovieScheduled(m.title, widget.theaterName),
                ).length;
                return _buildStatCard(
                  icon: Icons.movie_creation_outlined,
                  title: 'Active Movies',
                  value: totalMoviesCount.toString().padLeft(2, '0'),
                  badgeText: 'In Catalog',
                  onTap: widget.onNavigateToMovies,
                );
              },
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
                            color: AppColors.textBlack,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Total Revenue',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textBlack.withValues(
                                    alpha: 0.85,
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
                              color: AppColors.textBlack,
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
                      color: AppColors.textBlack.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'Daily Est',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textBlack,
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
}
