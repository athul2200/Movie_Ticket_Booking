import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/screens_management/owner_screen_details_screen.dart';

// ── Data model for a screen's current schedule ──
class _ScreenSchedule {
  final String screenName;
  final String movieTitle;
  final String genre;
  final String currentShowTime;   // The show time that is "NOW PLAYING"
  final List<String> allShowTimes;
  final double occupancy;          // 0.0 – 1.0
  final bool isActive;

  const _ScreenSchedule({
    required this.screenName,
    required this.movieTitle,
    required this.genre,
    required this.currentShowTime,
    required this.allShowTimes,
    required this.occupancy,
    this.isActive = true,
  });
}

class OwnerScreensStatusScreen extends StatefulWidget {
  final String theaterName;
  const OwnerScreensStatusScreen({super.key, this.theaterName = 'Kairali'});

  @override
  State<OwnerScreensStatusScreen> createState() =>
      _OwnerScreensStatusScreenState();
}

class _OwnerScreensStatusScreenState extends State<OwnerScreensStatusScreen> {
  List<_ScreenSchedule> get _schedules {
    final movie1 = MockData.allMovies.isNotEmpty ? MockData.allMovies.first.title : 'No Movie Scheduled';
    final movie2 = MockData.allMovies.length > 1 ? MockData.allMovies[1].title : (MockData.allMovies.isNotEmpty ? MockData.allMovies.first.title : 'No Movie Scheduled');

    return [
      _ScreenSchedule(
        screenName: 'Screen 01',
        movieTitle: movie1,
        genre: 'Active Listing',
        currentShowTime: '10:00 AM',
        allShowTimes: const ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
        occupancy: MockData.allMovies.isNotEmpty ? 0.73 : 0.0,
        isActive: MockData.allMovies.isNotEmpty,
      ),
      _ScreenSchedule(
        screenName: 'Screen 02',
        movieTitle: movie2,
        genre: 'Active Listing',
        currentShowTime: '11:00 AM',
        allShowTimes: const ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
        occupancy: MockData.allMovies.length > 1 ? 0.45 : 0.0,
        isActive: MockData.allMovies.length > 1,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _schedules.where((s) => s.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(
        title: widget.theaterName,
        showBackButton: Navigator.canPop(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sub-header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SCREENS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$activeCount',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            'active',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildIconBtn(Icons.filter_list, filled: true),
                    const SizedBox(width: AppSpacing.sm),
                    _buildIconBtn(Icons.search),
                  ],
                ),
              ],
            ),
          ),

          // ── Legend ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _buildLegend(AppColors.primary, 'Now Playing'),
                const SizedBox(width: AppSpacing.lg),
                _buildLegend(AppColors.textHint, 'Upcoming'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Screen Cards List ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: _schedules.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) =>
                  _buildScreenCard(_schedules[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Screen card ──
  Widget _buildScreenCard(_ScreenSchedule schedule) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OwnerScreenDetailsScreen(theaterName: widget.theaterName),
          ),
        );
      },
      onLongPress: () => _showDeleteDialog(schedule.screenName),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header (screen name + badges) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.live_tv_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.screenName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule.genre,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // ACTIVE badge
                  if (schedule.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ACTIVE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: AppColors.divider.withValues(alpha: 0.5),
            ),

            // ── Now Playing movie ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      width: 44,
                      height: 60,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'NOW PLAYING',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          schedule.movieTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Occupancy bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: schedule.occupancy,
                                  backgroundColor: AppColors.surface,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryDark,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${(schedule.occupancy * 100).toInt()}% full',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                    fontSize: 10,
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

            const SizedBox(height: AppSpacing.md),

            // ── Show Times ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'TODAY\'S SHOW TIMES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: schedule.allShowTimes.map((time) {
                  final bool isNow = time == schedule.currentShowTime;
                  return _buildTimeChip(time, isNow);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Time chip ──
  Widget _buildTimeChip(String time, bool isNow) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: isNow
            ? AppColors.primary
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isNow
              ? AppColors.primary
              : AppColors.divider.withValues(alpha: 0.7),
          width: isNow ? 1.5 : 1,
        ),
        boxShadow: isNow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNow) ...[
            const Icon(
              Icons.play_circle_filled,
              color: AppColors.textWhite,
              size: 11,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isNow ? AppColors.textWhite : AppColors.textSecondary,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Icon button helper ──
  Widget _buildIconBtn(IconData icon, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: filled ? null : Border.all(color: AppColors.divider),
      ),
      child: Icon(
        icon,
        color: filled ? AppColors.textWhite : AppColors.textPrimary,
        size: 20,
      ),
    );
  }

  // ── Legend item ──
  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── Delete confirmation dialog ──
  void _showDeleteDialog(String screenName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Remove Screen'),
        content: Text('Are you sure you want to remove $screenName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
