import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/widgets/cast_avatar.dart';
import 'package:booking/widgets/showtime_card.dart';
import 'package:booking/widgets/rating_badge.dart';

/// ============================================================
/// Movie Detail Screen — Full movie info page with:
/// - Hero banner with gradient
/// - Genre tags, rating, duration
/// - Play Trailer link
/// - Synopsis
/// - Cast & Crew
/// - Available Showtimes
/// - Rating scores (Rotten, IMDB, Metacritic, Fan Favorite)
/// - Book Tickets Now CTA
/// ============================================================

class MovieDetailScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            slivers: [
              // ── Hero banner with app bar overlay ──
              SliverToBoxAdapter(
                child: _buildHeroBanner(context),
              ),

              // ── Main content ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // ── Genre tags ──
                      _buildGenreTags(context),
                      const SizedBox(height: AppSpacing.md),

                      // ── Rating & Duration row ──
                      _buildRatingDurationRow(context),
                      const SizedBox(height: AppSpacing.md),

                      // ── Play Trailer ──
                      _buildPlayTrailer(context),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Synopsis ──
                      Text(
                        movie.description.isNotEmpty
                            ? movie.description
                            : 'In a world where memories can be bought and sold, a detective uncovers a long-buried secret that could plunge what\'s left of society into chaos. Neon Echoes is a visually stunning journey through a future that feels all too real, exploring the boundaries of humanity and artificial existence in a high-stakes race against time.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Cast & Crew ──
                      _buildCastCrew(context),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Available Showtimes ──
                      _buildShowtimes(context),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Rating Scores ──
                      _buildRatingScores(context),

                      // Bottom padding for the fixed CTA button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Fixed bottom CTA bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCTA(context),
          ),
        ],
      ),
    );
  }

  /// Hero banner with poster image, gradient overlay, and app bar
  Widget _buildHeroBanner(BuildContext context) {
    return SizedBox(
      height: AppSizes.heroDetailBannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──
          Image.network(
            movie.bannerUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.textPrimary,
              child: const Center(
                child: Icon(Icons.movie, size: 64, color: AppColors.textHint),
              ),
            ),
          ),

          // ── Gradient overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Colors.transparent,
                  Color(0x99000000),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── App bar overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textWhite,
                        size: AppSizes.iconLg,
                      ),
                    ),

                    // CinePremium logo
                    // Text(
                    //   'CinePremium',
                    //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    //         color: AppColors.primary,
                    //         fontWeight: FontWeight.w800,
                    //         fontSize: 18,
                    //       ),
                    // ),

                    // Share button
                    GestureDetector(
                      onTap: () {
                        // TODO: Share functionality
                      },
                      child: const Icon(
                        Icons.share_outlined,
                        color: AppColors.textWhite,
                        size: AppSizes.iconLg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Genre tags (SCI-FI, ADVENTURE, 4K UHD)
  Widget _buildGenreTags(BuildContext context) {
    // Use the movie's genres, or fallback to detail-screen genres
    final genres = movie.genres.length > 1
        ? movie.genres
        : ['SCI-FI', 'ADVENTURE', '4K UHD'];

    return Wrap(
      spacing: AppSpacing.sm,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            genre.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
          ),
        );
      }).toList(),
    );
  }

  /// Rating (star + 9.2/10) and Duration (clock + 2h 44m) row
  Widget _buildRatingDurationRow(BuildContext context) {
    return Row(
      children: [
        // ── Rating ──
        const Icon(Icons.star, size: 18, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '${movie.rating} / 10',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(width: AppSpacing.lg),

        // ── Duration ──
        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          movie.duration,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
        ),
      ],
    );
  }

  /// Play Trailer link
  Widget _buildPlayTrailer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Play trailer
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            size: 22,
            color: AppColors.greenAccent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Play Trailer',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.greenAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  /// Cast & Crew section
  Widget _buildCastCrew(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cast & Crew',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Horizontal list of cast avatars
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.lg),
            itemBuilder: (context, index) {
              return CastAvatar(cast: MockData.cast[index]);
            },
          ),
        ),
      ],
    );
  }

  /// Available Showtimes section
  Widget _buildShowtimes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Showtimes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
            ),
            Text(
              'Today, Oct 12',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Theater showtime cards ──
        ...MockData.theaters.asMap().entries.map((entry) {
          final index = entry.key;
          final theater = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < MockData.theaters.length - 1
                  ? AppSpacing.md
                  : 0,
            ),
            child: ShowtimeCard(
              theater: theater,
              // First theater has the last time slot selected (21:00)
              initialSelectedIndex: index == 0 ? 2 : -1,
            ),
          );
        }),
      ],
    );
  }

  /// Rating scores grid (Rotten, IMDB, Metacritic, Fan Favorite)
  Widget _buildRatingScores(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RatingBadge(value: '92%', label: 'ROTTEN'),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: RatingBadge(value: '8.8', label: 'IMDB'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: RatingBadge(value: '82', label: 'METACRITIC'),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: RatingBadge(
                value: '',
                label: 'FAN FAVORITE',
                icon: Icons.favorite,
                iconColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Fixed bottom CTA bar with "Book Tickets Now" button + bookmark icon
  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Book Tickets Now button ──
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/seat-selection',
                    arguments: {
                      'movieTitle': movie.title,
                      'showtime': '20:30',
                      'cinema': 'Cinema 4',
                      'format': 'IMAX',
                    },
                  );
                },
                // icon: const Icon(Icons.confirmation_number_outlined, size: 20), 
                label: const Text('Select Seats'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // ── Bookmark icon ──
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Icon(
                Icons.bookmark_border,
                size: AppSizes.iconLg,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
