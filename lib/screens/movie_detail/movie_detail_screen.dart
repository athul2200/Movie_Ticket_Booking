import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/widgets/cast_avatar.dart';
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

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final List<String> _availableDates = ['Jun 15 ', 'Jun 16 ', 'Jun 17 ', 'Jun 18 '];
  String? _selectedDate;
  String? _selectedCinema;
  String? _selectedShowtime;
  String? _selectedScreen;
  String _selectedFormat = '';

  // Mock theater → screens → times data
  static const Map<String, Map<String, List<String>>> _theaterData = {
    'Kairali': {
      'Screen 1': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM','09:30 PM'],
      'Screen 2': ['11:00 AM', '02:30 PM','05:30 PM', '08:30 PM','11:20 PM'],
    },
    'Nila': {
      'Screen 1': ['11:00 AM', '02:30 PM','05:30 PM', '08:30 PM','11:20 PM'],
      'Screen 2': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM','09:30 PM'],
    },
  };

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
              SliverToBoxAdapter(child: _buildHeroBanner(context)),

              // ── Main content ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
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

                      Text(
                        widget.movie.description.isNotEmpty
                            ? widget.movie.description
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
            widget.movie.bannerUrl,
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
                        color: Colors.white,
                        size: AppSizes.iconLg,
                      ),
                    ),

                    // Movix logo
                    // Text(
                    //   'Movix',
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
                        color: Colors.white,
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

  /// Genre tags
  Widget _buildGenreTags(BuildContext context) {
    // Use the movie's genres, or fallback to an empty list
    final genres = widget.movie.genres.length > 1
        ? widget.movie.genres
        : <String>[];

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
          '${widget.movie.rating} / 10',
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
          widget.movie.duration,
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

  /// Available Showtimes section — 3-step progressive disclosure
  Widget _buildShowtimes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Step 1: Date Selector ──
        _buildSectionHeader(context, 'Select Date'),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _availableDates.map((date) {
              final isSelected = _selectedDate == date;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Unselecting the date clears everything
                        _selectedDate = null;
                        _selectedCinema = null;
                        _selectedScreen = null;
                        _selectedShowtime = null;
                      } else {
                        // Selecting a new date preserves existing theater/time selections
                        _selectedDate = date;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Text(
                      date,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Step 2: Theaters (visible after date selection) ──
        if (_selectedDate != null) ...[
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(context, 'Select Theater'),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_selectedDate),
              children: _theaterData.keys.map((cinema) {
                final isSelected = _selectedCinema == cinema;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildTheaterCard(context, cinema: cinema, isSelected: isSelected),
                );
              }).toList(),
            ),
          ),
        ],

        // ── Step 3: Screens & Times (visible after theater selection) ──
        if (_selectedCinema != null) ...[
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(context, 'Select Screen & Time'),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_selectedCinema),
              children: _theaterData[_selectedCinema]!.entries.map((entry) {
                final screenName = entry.key;
                final times = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildScreenCard(context, screenName: screenName, times: times),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTheaterCard(
    BuildContext context, {
    required String cinema,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCinema = isSelected ? null : cinema;
          // Reset downstream
          _selectedScreen = null;
          _selectedShowtime = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                Icons.theater_comedy_outlined,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cinema,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_theaterData[cinema]!.length} screens available',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenCard(
    BuildContext context, {
    required String screenName,
    required List<String> times,
  }) {
    final isScreenSelected = _selectedScreen == screenName;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isScreenSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen label
          Row(
            children: [
              const Icon(Icons.monitor_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                screenName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Time slots
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: times.map((time) {
              final isTimeSelected = _selectedScreen == screenName && _selectedShowtime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isTimeSelected) {
                      // Unselect if already selected
                      _selectedScreen = null;
                      _selectedShowtime = null;
                      _selectedFormat = '';
                    } else {
                      // Select new time
                      _selectedScreen = screenName;
                      _selectedShowtime = time;
                      _selectedFormat = screenName.contains('IMAX')
                          ? 'IMAX'
                          : screenName.contains('Dolby')
                              ? 'Dolby'
                              : screenName.contains('4DX')
                                  ? '4DX'
                                  : screenName.contains('MX4D')
                                      ? 'MX4D'
                                      : '';
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTimeSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isTimeSelected ? AppColors.primary : AppColors.divider,
                      width: isTimeSelected ? 2 : 1,
                    ),
                    boxShadow: isTimeSelected
                        ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isTimeSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isTimeSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
              child: ElevatedButton(
                onPressed: _selectedShowtime != null
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/seat-selection',
                          arguments: {
                            'movieTitle': widget.movie.title,
                            'showtime': _selectedShowtime!,
                            'cinema': _selectedCinema!,
                            'screen': _selectedScreen!,
                            'format': _selectedFormat,
                            'date': _selectedDate!.trim(),
                          },
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedShowtime != null
                      ? AppColors.primary
                      : AppColors.surface,
                  foregroundColor: _selectedShowtime != null
                      ? AppColors.textWhite
                      : AppColors.textSecondary,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(
                      color: _selectedShowtime != null
                          ? Colors.transparent
                          : AppColors.divider,
                    ),
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _selectedShowtime != null ? 'Select Seats' : 'Pick a Date & Time',
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
