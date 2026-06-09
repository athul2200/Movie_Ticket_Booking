// ============================================================
// Movie Model — Data structure for movie information
// ============================================================

class MovieModel {
  final String id;
  final String title;
  final String description;
  final List<String> genres;
  final String duration;
  final double rating;
  final String certification; // UA, U, A
  final String posterUrl; // Network image URL
  final String bannerUrl; // Network image URL for hero banner

  const MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.genres,
    required this.duration,
    required this.rating,
    required this.certification,
    required this.posterUrl,
    required this.bannerUrl,
  });
}
