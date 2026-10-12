import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/widgets/hero_banner.dart';
import 'package:booking/widgets/category_chips.dart';
import 'package:booking/widgets/movie_card.dart';
import 'package:booking/widgets/app_image.dart';
import 'package:booking/screens/upcoming/upcoming_screen.dart';

/// ============================================================
/// Home Screen — Main landing screen with:
/// - Custom app bar (location, logo, search)
/// - Hero carousel banner
/// - Upcoming movies card
/// - Category filter chips
/// - Movie grid (2 columns)
/// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  late List<MovieModel> _displayedMovies;

  @override
  void initState() {
    super.initState();
    _updateDisplayedMovies();
  }

  void _updateDisplayedMovies() {
    final scheduledMovies = MockData.activeScheduledMovies;
    final uniqueMovies = MockData.deduplicateMovies(scheduledMovies);
    final selectedCategory = MockData.categories[_selectedCategoryIndex];
    _displayedMovies = selectedCategory == 'All Movies'
        ? uniqueMovies
        : uniqueMovies
            .where((m) => m.genres.any((g) => g.trim() == selectedCategory.trim()))
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    _updateDisplayedMovies();
    final scheduledMovies = MockData.activeScheduledMovies;
    final activeScheduledTitles = scheduledMovies.map((m) => m.title.trim().toLowerCase()).toSet();
    
    // Cross-reference featuredMovies with latest allMovies data to enforce isActive & scheduled filters
    final scheduledFeatured = MockData.featuredMovies
        .map((m) {
          return MockData.allMovies.firstWhere(
            (am) => am.id == m.id || am.title.trim().toLowerCase() == m.title.trim().toLowerCase(),
            orElse: () => m,
          );
        })
        .where((m) => m.isActive && activeScheduledTitles.contains(m.title.trim().toLowerCase()))
        .toList();

    final featuredRaw = scheduledFeatured.isNotEmpty ? scheduledFeatured : scheduledMovies;
    final featured = MockData.deduplicateMovies(featuredRaw);

    // Active unscheduled movies for the Upcoming Movies section
    final unscheduledMovies = MockData.allMovies.where((m) {
      final isOwnerAddedActive = m.isActive;
      final isNotScheduled = !MockData.isMovieScheduled(m.title);
      return isOwnerAddedActive && isNotScheduled;
    }).toList();
    final upcomingMovies = MockData.deduplicateMovies(unscheduledMovies);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverToBoxAdapter(child: _buildAppBar(context)),

            // ── Hero Carousel Banner ──
            SliverToBoxAdapter(
              child: HeroBanner(
                movies: featured,
                onBookNow: (movie) {
                  if (movie.isActive) {
                    Navigator.pushNamed(
                      context,
                      '/movie-detail',
                      arguments: movie,
                    );
                  }
                },
              ),
            ),

            // ── Spacing ──
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // ── Upcoming Movies Card ──
            SliverToBoxAdapter(
              child: _buildUpcomingMoviesCard(context, upcomingMovies),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

            // ── Category Chips ──
            SliverToBoxAdapter(
              child: CategoryChips(
                categories: MockData.categories,
                selectedIndex: _selectedCategoryIndex,
                onSelected: (index) {
                  if (_selectedCategoryIndex != index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                      _updateDisplayedMovies();
                    });
                  }
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // ── Movie Grid (2 columns) or Empty State ──
            if (_displayedMovies.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.movie_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No movies available',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Check back later for new releases and showtimes.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.51,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final movie = _displayedMovies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/movie-detail',
                          arguments: movie,
                        );
                      },
                    );
                  }, childCount: _displayedMovies.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // ── Bottom padding ──
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  /// Custom App Bar matching Figma:
  /// [Location pin + "Los Angeles, CA"]  [Movix logo]  [Search icon]
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // ── Back Button ──
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: const Icon(
              Icons.arrow_back,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // ── Location ──
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: AppSizes.iconMd,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Los Angeles, CA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Movix Logo (text) ──
          Text(
            'Movix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),

          const Spacer(),

          // ── Search Icon ──
          GestureDetector(
            onTap: () {
              // TODO: Navigate to search
            },
            child: const Icon(
              Icons.search,
              size: AppSizes.iconLg,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Upcoming Movies Section represented as a sleek Card
  Widget _buildUpcomingMoviesCard(BuildContext context, List<MovieModel> movies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UpcomingScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header Row ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.upcoming,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Upcoming Movies',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${movies.length}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          movies.isNotEmpty
                              ? '${movies.length} ${movies.length == 1 ? "movie" : "movies"} coming soon to theaters'
                              : 'Explore releases coming soon to theaters',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),

              // ── Preview Posters Row (if movies exist) ──
              if (movies.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    // Preview posters
                    Expanded(
                      child: Row(
                        children: movies.take(4).map((m) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: SizedBox(
                                width: 44,
                                height: 58,
                                child: AppImage(
                                  urlOrPath: m.posterUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.cardBackground,
                                    child: const Icon(
                                      Icons.movie,
                                      size: 16,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
