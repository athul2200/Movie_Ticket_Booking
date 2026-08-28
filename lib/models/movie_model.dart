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
  final String trailerUrl; // YouTube trailer link

  const MovieModel({
    required this.id,
    required this.title,
    required this.description,
    this.genres = const [],
    required this.duration,
    required this.rating,
    required this.certification,
    required this.posterUrl,
    required this.bannerUrl,
    this.trailerUrl = '',
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      genres: List<String>.from(json['genres'] ?? []),
      duration: json['duration'] as String,
      rating: (json['rating'] as num).toDouble(),
      certification: json['certification'] as String,
      posterUrl: json['posterUrl'] as String,
      bannerUrl: json['bannerUrl'] as String,
      trailerUrl: json['trailerUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genres': genres,
      'duration': duration,
      'rating': rating,
      'certification': certification,
      'posterUrl': posterUrl,
      'bannerUrl': bannerUrl,
      'trailerUrl': trailerUrl,
    };
  }
}
