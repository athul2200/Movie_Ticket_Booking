import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
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

  @override
  Widget build(BuildContext context) {
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
                movies: MockData.featuredMovies,
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
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
              ),
            ),

            // ── "View All" Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all movies
                    },
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Movie Grid (2 columns) ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = MockData.allMovies[index];
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
                }, childCount: MockData.allMovies.length),
              ),
            ),

            // ── Bottom padding ──
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  /// Custom App Bar matching Figma:
  /// [Location pin + "Los Angeles, CA"]  [CinePremium logo]  [Search icon]
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
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

          // ── CinePremium Logo (text) ──
          Text(
            'CinePremium',
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
