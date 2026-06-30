// ============================================================
// IST Time Utilities — Indian Standard Time (Asia/Kolkata, UTC+5:30)
//
// Flutter does not ship a timezone database, so we derive IST
// directly from UTC by adding a fixed offset of +05:30.
// This is correct and will never be affected by the device's
// local timezone setting.
// ============================================================

class IstTimeUtils {
  /// Fixed IST offset: UTC + 5 hours 30 minutes.
  static const Duration _istOffset = Duration(hours: 5, minutes: 30);

  /// Abbreviated month names (1-indexed via [month - 1]).
  static const List<String> _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Returns the current date-time in Indian Standard Time (IST).
  static DateTime nowInIst() {
    return DateTime.now().toUtc().add(_istOffset);
  }

  // ── Date helpers ─────────────────────────────────────────────

  /// Formats a [DateTime] as a short date label, e.g. "Jun 30" or "Jul 1".
  static String _formatDateLabel(DateTime date) {
    return '${_monthAbbr[date.month - 1]} ${date.day}';
  }

  /// Returns three IST-based date labels:
  ///   [0] = Today, [1] = Tomorrow, [2] = Day after tomorrow.
  static List<String> generateAvailableDates() {
    final today = nowInIst();
    return List.generate(3, (i) => _formatDateLabel(
      DateTime(today.year, today.month, today.day + i),
    ));
  }

  /// Returns `true` if [dateLabel] (e.g. "Jun 30") matches today's IST date.
  static bool isDateToday(String dateLabel) {
    final today = nowInIst();
    return dateLabel.trim() == _formatDateLabel(today);
  }

  // ── Showtime helpers ──────────────────────────────────────────

  /// Parses a showtime string such as "10:00 AM", "01:30 PM", "09:15 PM"
  /// into a [DateTime] on today's date (in IST).
  ///
  /// Returns `null` if the string cannot be parsed.
  static DateTime? parseShowtime(String showtime) {
    try {
      final now = nowInIst();

      // Normalise: collapse multiple spaces, trim.
      final parts = showtime.trim().toUpperCase().split(RegExp(r'\s+'));
      if (parts.length != 2) return null;

      final timePart = parts[0]; // e.g. "10:00"
      final period = parts[1]; // "AM" or "PM"

      final timePieces = timePart.split(':');
      if (timePieces.length != 2) return null;

      int hour = int.parse(timePieces[0]);
      final int minute = int.parse(timePieces[1]);

      // Convert to 24-hour
      if (period == 'AM') {
        if (hour == 12) hour = 0; // 12:xx AM → 00:xx
      } else {
        if (hour != 12) hour += 12; // 1:xx PM → 13:xx, but 12 PM stays 12
      }

      // Build the show's datetime on today's IST date.
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// Returns `true` if the [showtime] string is still visible to users
  /// **when the selected date is today**.
  ///
  /// A show is hidden when the current IST time is ≥ (show start − 30 min).
  /// In other words, it disappears exactly 30 minutes before it starts.
  static bool isShowtimeVisible(String showtime) {
    final showDt = parseShowtime(showtime);
    if (showDt == null) return true; // if unparseable, show it rather than hide it

    final now = nowInIst();
    final hideAfter = showDt.subtract(const Duration(minutes: 30));

    // The show is visible as long as now is strictly before hideAfter.
    return now.isBefore(hideAfter);
  }

  /// Filters a list of showtime strings, keeping only those that are
  /// still visible (i.e. have not yet passed the 30-minute cutoff).
  /// Only applies the cutoff for **today**; future dates return all showtimes.
  ///
  /// [dateLabel] should be one of the labels from [generateAvailableDates].
  static List<String> filterActiveShowtimesForDate(
    List<String> showtimes,
    String dateLabel,
  ) {
    // Future dates: every show is still ahead of time — show them all.
    if (!isDateToday(dateLabel)) return List<String>.from(showtimes);
    // Today: apply the 30-minute pre-show cutoff.
    return showtimes.where(isShowtimeVisible).toList();
  }
}
