import 'package:flutter_test/flutter_test.dart';
import 'package:booking/core/utils/ist_time_utils.dart';

void main() {
  test('Test actual IstTimeUtils showtime parsing and visibility', () {
    final now = IstTimeUtils.nowInIst();
    print('Current time in IST (actual): $now');

    final shows = ['08:30 PM', '11:20 PM', '07:30 PM', '09:30 PM'];
    for (final show in shows) {
      final parsed = IstTimeUtils.parseShowtime(show);
      final visible = IstTimeUtils.isShowtimeVisible(show);
      print('Show: $show | Parsed: $parsed | Visible: $visible');
    }
  });
}
