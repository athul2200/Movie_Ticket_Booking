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
  final List<String> theaters; // Theaters where this movie is added

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
    this.theaters = const ['Kairali', 'Nila'],
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
      theaters: List<String>.from(json['theaters'] ?? ['Kairali', 'Nila']),
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
      'theaters': theaters,
    };
  }

  MovieModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? genres,
    String? duration,
    double? rating,
    String? certification,
    String? posterUrl,
    String? bannerUrl,
    String? trailerUrl,
    List<String>? theaters,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      certification: certification ?? this.certification,
      posterUrl: posterUrl ?? this.posterUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      theaters: theaters ?? this.theaters,
    );
  }
}
