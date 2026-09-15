// ============================================================
// Review Model — Data structure for user reviews and feedback
// ============================================================

class ReviewModel {
  final String id;
  final String movieTitle;
  final String userName;
  final String userInitials;
  final int rating; // 1 to 5
  final String comment;
  final String timeAgo;
  final bool isApproved;

  const ReviewModel({
    required this.id,
    required this.movieTitle,
    required this.userName,
    required this.userInitials,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    this.isApproved = false,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      movieTitle: json['movieTitle'] as String? ?? 'General Review',
      userName: json['userName'] as String,
      userInitials: json['userInitials'] as String? ?? 'U',
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      timeAgo: json['timeAgo'] as String? ?? 'Recently',
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieTitle': movieTitle,
      'userName': userName,
      'userInitials': userInitials,
      'rating': rating,
      'comment': comment,
      'timeAgo': timeAgo,
      'isApproved': isApproved,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? movieTitle,
    String? userName,
    String? userInitials,
    int? rating,
    String? comment,
    String? timeAgo,
    bool? isApproved,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      movieTitle: movieTitle ?? this.movieTitle,
      userName: userName ?? this.userName,
      userInitials: userInitials ?? this.userInitials,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timeAgo: timeAgo ?? this.timeAgo,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
