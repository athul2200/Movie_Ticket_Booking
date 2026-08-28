import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/widgets/hero_banner.dart';
import 'package:booking/widgets/category_chips.dart';
import 'package:booking/widgets/movie_card.dart';

/// ============================================================
/// Home Screen — Main landing screen with:
/// - Custom app bar (location, logo, search)
/// - Hero carousel banner
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
    final uniqueMovies = MockData.deduplicateMovies(MockData.allMovies);
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
    final featured = MockData.deduplicateMovies(
      MockData.featuredMovies.isNotEmpty ? MockData.featuredMovies : MockData.allMovies,
    );

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
                  Navigator.pushNamed(
                    context,
                    '/movie-detail',
                    arguments: movie,
                  );
                },
              ),
            ),

            // ── Spacing ──
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
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
            child: const Icon(
              Icons.arrow_back,
              size: AppSizes.iconMd,
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
}
