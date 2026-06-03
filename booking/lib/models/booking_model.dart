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
}
