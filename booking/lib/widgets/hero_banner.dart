import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/models/movie_model.dart';

/// ============================================================
/// Hero Banner — Full-width carousel with movie poster,
/// gradient overlay, genre tags, title, description & CTA
/// ============================================================

class HeroBanner extends StatefulWidget {
  final List<MovieModel> movies;
  final void Function(MovieModel movie)? onBookNow;

  const HeroBanner({
    super.key,
    required this.movies,
    this.onBookNow,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.heroBannerHeight,
      child: Stack(
        children: [
          // ── Page view of movie banners ──
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _BannerSlide(
                movie: movie,
                onBookNow: () => widget.onBookNow?.call(movie),
              );
            },
          ),

          // ── Page indicator dots ──
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: widget.movies.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.textHint,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual banner slide
class _BannerSlide extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onBookNow;

  const _BannerSlide({
    required this.movie,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background image ──
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.network(
            movie.bannerUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.textPrimary,
              child: const Center(
                child: Icon(Icons.movie, size: 64, color: AppColors.textHint),
              ),
            ),
          ),
        ),

        // ── Gradient overlay (dark at bottom) ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x33000000),
                Color(0xCC000000),
              ],
              stops: [0.3, 0.6, 1.0],
            ),
          ),
        ),

        // ── Content overlay ──
        Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genre tags
              Wrap(
                spacing: AppSpacing.sm,
                children: movie.genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.genreTagBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      genre,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.genreTagText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Movie title
              Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Description
              Text(
                movie.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Book Now button
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: onBookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 0,
                  ),
                  child: Text(
                    'Book Now',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
