import 'package:flutter/material.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/movies_management/add_movie_screen.dart';
import 'package:booking/widgets/app_image.dart';

/// ============================================================
/// Owner Movies Screen — View movies added to theater catalog.
/// Shows added movies with editing options.
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
  @override
  void initState() {
    super.initState();
    if (widget.openAddOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openMovieForm();
      });
    }
  }

  List<MovieModel> get _managedMovies {
    return MockData.allMovies
        .where((m) => m.theaters.contains(widget.theaterName))
        .toList();
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

  @override
  Widget build(BuildContext context) {
    final movies = _managedMovies;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: widget.theaterName),
      body: SingleChildScrollView(
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
                        'Movies listed for ${widget.theaterName}.',
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
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Added Movies Title ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Added Movies',
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
                      const Icon(
                        Icons.movie_outlined,
                        size: 56,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No movies added yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Click "Add Movie" above to add titles for ${widget.theaterName}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () => _openMovieForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Movie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...movies.asMap().entries.map((entry) {
                final index = entry.key;
                final movie = entry.value;
                final isLive = MockData.movieSchedules.containsKey(movie.title) &&
                    (MockData.movieSchedules[movie.title]?.values.any((dates) => dates.containsKey(widget.theaterName)) ?? false);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < movies.length - 1 ? AppSpacing.md : 0,
                  ),
                  child: _buildManagedMovieCard(
                    movie: movie,
                    badgeText: isLive ? 'Running Now' : null,
                    isLive: isLive,
                    onEdit: () => _openMovieForm(movie),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove Movie'),
                          content: Text('Remove "${movie.title}" from ${widget.theaterName}?'),
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
                          final remainingTheaters = List<String>.from(movie.theaters)..remove(widget.theaterName);
                          if (remainingTheaters.isEmpty) {
                            MockData.allMovies.removeWhere((m) => m.id == movie.id);
                            MockData.featuredMovies.removeWhere((m) => m.id == movie.id);
                          } else {
                            final idx = MockData.allMovies.indexWhere((m) => m.id == movie.id);
                            if (idx != -1) {
                              MockData.allMovies[idx] = movie.copyWith(theaters: remainingTheaters);
                            }
                          }
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
    );
  }

  Widget _buildManagedMovieCard({
    required MovieModel movie,
    required String? badgeText,
    required bool isLive,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
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
                          : AppColors.textWhite.withValues(alpha: 0.9),
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
                        ],
                        Text(
                          badgeText,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isLive
                                ? Colors.white
                                : AppColors.textSecondary,
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
            child: Row(
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
                    ],
                  ),
                ),
                // Edit button
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
          ),
        ],
      ),
    );
  }
}
