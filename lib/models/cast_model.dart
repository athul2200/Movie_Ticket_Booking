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
}
