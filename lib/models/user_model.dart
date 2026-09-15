// ============================================================
// User Model — Data structure for application users
// ============================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status; // 'ACTIVE', 'PENDING', 'BANNED'
  final String tier; // 'Platinum', 'Gold', 'Silver', 'Standard'
  final String lastActive;
  final int moviesSeenCount;
  final int totalBookingsCount;
  final String favGenre;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '+91 9876543210',
    this.status = 'ACTIVE',
    this.tier = 'Silver',
    this.lastActive = 'Just now',
    this.moviesSeenCount = 0,
    this.totalBookingsCount = 0,
    this.favGenre = 'Action',
    this.avatarUrl = '',
  });

  String get initials {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '+91 9876543210',
      status: json['status'] as String? ?? 'ACTIVE',
      tier: json['tier'] as String? ?? 'Silver',
      lastActive: json['lastActive'] as String? ?? 'Just now',
      moviesSeenCount: (json['moviesSeenCount'] as num?)?.toInt() ?? 0,
      totalBookingsCount: (json['totalBookingsCount'] as num?)?.toInt() ?? 0,
      favGenre: json['favGenre'] as String? ?? 'Action',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'tier': tier,
      'lastActive': lastActive,
      'moviesSeenCount': moviesSeenCount,
      'totalBookingsCount': totalBookingsCount,
      'favGenre': favGenre,
      'avatarUrl': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    String? tier,
    String? lastActive,
    int? moviesSeenCount,
    int? totalBookingsCount,
    String? favGenre,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      lastActive: lastActive ?? this.lastActive,
      moviesSeenCount: moviesSeenCount ?? this.moviesSeenCount,
      totalBookingsCount: totalBookingsCount ?? this.totalBookingsCount,
      favGenre: favGenre ?? this.favGenre,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
