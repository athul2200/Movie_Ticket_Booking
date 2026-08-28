// ============================================================
// Cast Model — Data structure for cast & crew members
// ============================================================

class CastModel {
  final String name;
  final String role; // e.g., "ACTOR", "DIRECTOR"
  final String imageUrl; // Network image URL for avatar

  const CastModel({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      name: json['name'] as String,
      role: json['role'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
    };
  }
}
