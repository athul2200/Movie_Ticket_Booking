// ============================================================
// Booking Model — Data structure for a confirmed booking
// ============================================================

class BookingModel {
  final String id;
  final String movieTitle;
  final String moviePosterUrl;
  final String date;
  final String time;
  final String cinema;
  final List<String> seats;
  final double totalAmount;
  final String experience; // e.g., "IMAX 3D EXPERIENCE"
  final bool isConfirmed;
  final bool isHistory;

  const BookingModel({
    required this.id,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.date,
    required this.time,
    required this.cinema,
    required this.seats,
    required this.totalAmount,
    required this.experience,
    this.isConfirmed = true,
    this.isHistory = false,
  });

  /// Seats formatted as a comma-separated string (e.g., "H12, H13")
  String get seatsFormatted => seats.join(', ');

  BookingModel copyWith({
    String? id,
    String? movieTitle,
    String? moviePosterUrl,
    String? date,
    String? time,
    String? cinema,
    List<String>? seats,
    double? totalAmount,
    String? experience,
    bool? isConfirmed,
    bool? isHistory,
  }) {
    return BookingModel(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      cinema: cinema ?? this.cinema,
      seats: seats ?? this.seats,
      totalAmount: totalAmount ?? this.totalAmount,
      experience: experience ?? this.experience,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isHistory: isHistory ?? this.isHistory,
    );
  }
}
