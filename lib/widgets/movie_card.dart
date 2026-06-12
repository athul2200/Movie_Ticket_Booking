import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/models/movie_model.dart';

/// ============================================================
/// Movie Card — Poster card for the grid with:
/// - Rounded poster image
/// - Star rating badge (bottom-left)
/// - Certification badge (bottom-right)
/// - Genre • Duration text below
/// ============================================================

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;

  const MovieCard({super.key, required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Poster image with rating & certification overlays ──
          Stack(
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppSizes.movieCardPosterRadius,
                ),
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          size: 40,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Star rating badge (bottom-left)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.starYellow,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        movie.rating.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Certification badge (bottom-right)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    movie.certification,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Genre • Duration ──
          Text(
            '${movie.genres.first} • ${movie.duration}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
