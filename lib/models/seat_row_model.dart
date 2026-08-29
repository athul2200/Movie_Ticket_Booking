/// Represents a single row in a cinema screen's seating layout.
/// Held purely in memory — no persistence.
class SeatRow {
  /// The label shown on the left/right of the row, e.g. "A", "B", "VIP".
  String rowName;

  /// How many seats are in this row.
  int seatCount;

  SeatRow({required this.rowName, required this.seatCount});

  /// Returns a deep copy of this row.
  SeatRow copyWith({String? rowName, int? seatCount}) {
    return SeatRow(
      rowName: rowName ?? this.rowName,
      seatCount: seatCount ?? this.seatCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'rowName': rowName,
        'seatCount': seatCount,
      };

  factory SeatRow.fromJson(Map<String, dynamic> json) => SeatRow(
        rowName: json['rowName'] as String,
        seatCount: json['seatCount'] as int,
      );
}
