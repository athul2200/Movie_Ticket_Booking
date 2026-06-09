// ============================================================
// Theater Model — Data structure for theater & showtimes
// ============================================================

class TheaterModel {
  final String name;
  final String type; // "IMAX", "Standard"
  final List<String> showtimes; // e.g., ["14:30", "17:45", "21:00"]

  const TheaterModel({
    required this.name,
    required this.type,
    required this.showtimes,
  });
}
