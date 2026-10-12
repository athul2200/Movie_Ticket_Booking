import 'package:flutter/material.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/movies_management/add_movie_screen.dart';
import 'package:booking/screens/owner/schedule_management/owner_schedule_screen.dart';
import 'package:booking/screens/owner/schedule_management/edit_schedule_dialog.dart';
import 'package:booking/widgets/app_image.dart';

/// ============================================================
/// Owner Movies Screen — View movies added to theater catalog.
/// Shows added movies with filtering by theater and schedule status.
/// ============================================================

class OwnerMoviesScreen extends StatefulWidget {
  final String theaterName;
  final bool openAddOnLoad;

  const OwnerMoviesScreen({
    super.key,
    this.theaterName = 'Kairali',
    this.openAddOnLoad = false,
  });

  @override
  State<OwnerMoviesScreen> createState() => _OwnerMoviesScreenState();
}

class _OwnerMoviesScreenState extends State<OwnerMoviesScreen> {
  String _selectedScheduleFilter = 'All'; // 'All' | 'Scheduled' | 'Not Scheduled'

  @override
  void initState() {
    super.initState();
    if (widget.openAddOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openMovieForm();
      });
    }
  }

  @override
  void didUpdateWidget(covariant OwnerMoviesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  bool _belongsToThisTheater(MovieModel m) {
    final isAssigned = m.theaters.any((t) => MockData.theaterMatches(t, widget.theaterName));
    final isScheduledHere = MockData.isMovieScheduled(m.title, widget.theaterName);
    return isAssigned || isScheduledHere;
  }

  List<MovieModel> get _managedMovies {
    return MockData.allMovies.where((m) {
      // Only show movies assigned or scheduled to this owner's theater
      if (!_belongsToThisTheater(m)) return false;

      // Schedule filter
      final isScheduled = MockData.isMovieScheduled(m.title, widget.theaterName);
      if (_selectedScheduleFilter == 'Scheduled') return isScheduled;
      if (_selectedScheduleFilter == 'Not Scheduled') return !isScheduled;
      return true;
    }).toList();
  }

  int get _theaterMovieCount =>
      MockData.allMovies.where(_belongsToThisTheater).length;

  int get _scheduledCount =>
      MockData.allMovies.where((m) =>
        _belongsToThisTheater(m) &&
        MockData.isMovieScheduled(m.title, widget.theaterName)
      ).length;

  int get _notScheduledCount =>
      MockData.allMovies.where((m) =>
        _belongsToThisTheater(m) &&
        !MockData.isMovieScheduled(m.title, widget.theaterName)
      ).length;

  String get _sectionTitle {
    if (_selectedScheduleFilter == 'Scheduled') return 'Scheduled Movies';
    if (_selectedScheduleFilter == 'Not Scheduled') return 'Not Scheduled Movies';
    return 'All Added Movies';
  }

  Future<void> _openMovieForm([MovieModel? movieToEdit]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMovieScreen(
          theaterName: widget.theaterName,
          movieToEdit: movieToEdit,
        ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  /// Opens the schedule editing screen directly for a scheduled movie.
  Future<void> _openEditSchedule(MovieModel movie) async {
    final saved = await EditScheduleDialog.showMultiScreen(
      context,
      movieTitle: movie.title,
      theaterName: widget.theaterName,
    );
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Widget _buildScheduleFilterChip(String label, int count, {IconData? icon, Color? activeColor}) {
    final isSelected = _selectedScheduleFilter == label;
    final color = activeColor ?? AppColors.primary;
    final onSelectedColor = AppColors.textOn(color);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedScheduleFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? onSelectedColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? onSelectedColor : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? onSelectedColor.withValues(alpha: 0.25)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? onSelectedColor : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final movies = _managedMovies;
    final totalAdded = _theaterMovieCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: widget.theaterName),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await MockData.loadData();
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header with Add Movie Action ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Movie Management',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'All movies added to your theater catalog.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openMovieForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Movie'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Schedule Status Filters ──
              if (_theaterMovieCount > 0) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildScheduleFilterChip('All', _theaterMovieCount),
                      const SizedBox(width: AppSpacing.sm),
                      _buildScheduleFilterChip(
                        'Scheduled',
                        _scheduledCount,
                        icon: Icons.check_circle_outline,
                        activeColor: const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildScheduleFilterChip(
                        'Not Scheduled',
                        _notScheduledCount,
                        icon: Icons.schedule,
                        activeColor: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Added Movies Title & Count Badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _sectionTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${movies.length} ${movies.length == 1 ? "Movie" : "Movies"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Movies List ──
              if (movies.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedScheduleFilter == 'Scheduled'
                              ? Icons.event_busy_outlined
                              : _selectedScheduleFilter == 'Not Scheduled'
                                  ? Icons.task_alt_outlined
                                  : Icons.movie_outlined,
                          size: 56,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          totalAdded == 0
                              ? 'No movies added yet'
                              : _selectedScheduleFilter == 'Scheduled'
                                  ? 'No Scheduled Movies'
                                  : _selectedScheduleFilter == 'Not Scheduled'
                                      ? 'No Unscheduled Movies'
                                      : 'No movies found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          totalAdded == 0
                              ? 'Click "Add Movie" above to add titles to your theater catalog.'
                              : _selectedScheduleFilter == 'Scheduled'
                                  ? 'None of the movies in this view have scheduled showtimes.'
                                  : _selectedScheduleFilter == 'Not Scheduled'
                                      ? 'All movies in this view are currently scheduled with active showtimes!'
                                      : 'No movies match the selected filters.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (totalAdded == 0)
                          ElevatedButton.icon(
                            onPressed: () => _openMovieForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Movie'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textBlack,
                            ),
                          )
                        else if (_selectedScheduleFilter == 'Scheduled' && _notScheduledCount > 0)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OwnerScheduleScreen(theaterName: widget.theaterName),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Schedule Shows'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          )
                        else if (_selectedScheduleFilter != 'All')
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedScheduleFilter = 'All';
                              });
                            },
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Reset Filters'),
                          ),
                      ],
                    ),
                  ),
                )
              else
                ...movies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final movie = entry.value;
                  final isLive = MockData.isMovieScheduled(movie.title, widget.theaterName);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < movies.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: _buildManagedMovieCard(
                      movie: movie,
                      badgeText: isLive ? 'Scheduled' : 'Not Scheduled',
                      isLive: isLive,
                      onEdit: () => _openMovieForm(movie),
                      onEditSchedule: isLive ? () => _openEditSchedule(movie) : null,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Remove Movie'),
                            content: Text('Remove "${movie.title}" from catalog?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            MockData.allMovies.removeWhere((m) => m.id == movie.id);
                            MockData.featuredMovies.removeWhere((m) => m.id == movie.id);
                            MockData.movieSchedules.remove(movie.title);
                          });
                          await MockData.saveAll();
                        }
                      },
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagedMovieCard({
    required MovieModel movie,
    required String? badgeText,
    required bool isLive,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    VoidCallback? onEditSchedule,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: AppImage(
                  urlOrPath: movie.posterUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(Icons.movie, size: 40, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isLive
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ] else ...[
                          const Icon(
                            Icons.schedule,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          badgeText,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Remove button overlay
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${movie.duration} • ${movie.genres.isNotEmpty ? movie.genres.first : "General"}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (movie.theaters.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: movie.theaters.map((th) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  th,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                          // Schedule summary for scheduled movies
                          if (isLive) _buildScheduleSummary(movie),
                        ],
                      ),
                    ),
                    // Edit metadata button
                    ElevatedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
                // Edit Schedule button — only for scheduled movies
                if (onEditSchedule != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onEditSchedule,
                      icon: const Icon(Icons.edit_calendar_outlined, size: 16),
                      label: const Text('Edit Schedule'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFF16A34A), width: 1.2),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Compact schedule summary shown inside the movie card.
  Widget _buildScheduleSummary(MovieModel movie) {
    final sched = MockData.movieSchedules[movie.title] ?? {};
    final List<String> lines = [];
    sched.forEach((dateLabel, theaterMap) {
      theaterMap.forEach((th, screenMap) {
        if (MockData.theaterMatches(th, widget.theaterName)) {
          screenMap.forEach((screen, times) {
            if (times.isNotEmpty) {
              lines.add('$dateLabel · $screen · ${times.take(2).join(', ')}${times.length > 2 ? '…' : ''}');
            }
          });
        }
      });
    });
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.schedule, size: 12, color: Color(0xFF16A34A)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
}
