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
  final String screen; // e.g., "Screen 01"
  final List<String> seats;
  final double totalAmount;
  final String experience; // e.g., "IMAX 3D EXPERIENCE"
  final bool isConfirmed;
  final bool isHistory;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String status; // 'Confirmed', 'Pending', 'Cancelled'
  final String? createdAt; // ISO string or formatted timestamp

  const BookingModel({
    required this.id,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.date,
    required this.time,
    required this.cinema,
    this.screen = '',
    required this.seats,
    required this.totalAmount,
    required this.experience,
    this.isConfirmed = true,
    this.isHistory = false,
    this.userName = 'Guest User',
    this.userEmail = 'guest@example.com',
    this.userPhone = '+91 9876543210',
    this.status = 'Confirmed',
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      movieTitle: json['movieTitle'] as String,
      moviePosterUrl: json['moviePosterUrl'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      cinema: json['cinema'] as String,
      screen: json['screen'] as String? ?? '',
      seats: List<String>.from(json['seats'] ?? []),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      experience: json['experience'] as String,
      isConfirmed: json['isConfirmed'] as bool? ?? true,
      isHistory: json['isHistory'] as bool? ?? false,
      userName: json['userName'] as String? ?? 'Guest User',
      userEmail: json['userEmail'] as String? ?? 'guest@example.com',
      userPhone: json['userPhone'] as String? ?? '+91 9876543210',
      status: json['status'] as String? ?? 'Confirmed',
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'date': date,
      'time': time,
      'cinema': cinema,
      'screen': screen,
      'seats': seats,
      'totalAmount': totalAmount,
      'experience': experience,
      'isConfirmed': isConfirmed,
      'isHistory': isHistory,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status,
      'createdAt': createdAt,
    };
  }

  /// Seats formatted as a comma-separated string (e.g., "H12, H13")
  String get seatsFormatted => seats.join(', ');

  BookingModel copyWith({
    String? id,
    String? movieTitle,
    String? moviePosterUrl,
    String? date,
    String? time,
    String? cinema,
    String? screen,
    List<String>? seats,
    double? totalAmount,
    String? experience,
    bool? isConfirmed,
    bool? isHistory,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? status,
    String? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      cinema: cinema ?? this.cinema,
      screen: screen ?? this.screen,
      seats: seats ?? this.seats,
      totalAmount: totalAmount ?? this.totalAmount,
      experience: experience ?? this.experience,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isHistory: isHistory ?? this.isHistory,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
