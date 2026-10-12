import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/core/utils/ist_time_utils.dart';
import 'custom_card.dart';

class ShowManagementScreen extends StatefulWidget {
  const ShowManagementScreen({super.key});

  @override
  State<ShowManagementScreen> createState() => _ShowManagementScreenState();
}

class _ShowManagementScreenState extends State<ShowManagementScreen> {
  String _customSelectedDate = '';
  String _selectedTheaterFilter = 'All Theaters';

  List<String> get _availableDates => IstTimeUtils.generateAvailableDates();

  String get _selectedDate {
    if (_customSelectedDate.isNotEmpty) {
      return _customSelectedDate;
    }
    final dates = _availableDates;
    return dates.isNotEmpty ? dates.first : _todayLabel;
  }

  set _selectedDate(String val) {
    _customSelectedDate = val;
  }

  String get _todayLabel {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  // ── Show Stats Calculator ──
  int _getBookedSeatsCount(String movie, String theater, String screen, String time) {
    int count = 0;
    final targetMovie = movie.trim().toLowerCase();
    final targetTheater = theater.trim().toLowerCase();
    final targetScreen = screen.trim().toLowerCase();
    final targetTime = time.trim().toLowerCase();

    for (final b in MockData.bookings) {
      if (b.status != 'Cancelled' &&
          b.movieTitle.trim().toLowerCase() == targetMovie &&
          b.cinema.trim().toLowerCase() == targetTheater &&
          (b.screen.isEmpty || b.screen.trim().toLowerCase() == targetScreen) &&
          b.time.trim().toLowerCase() == targetTime) {
        count += b.seats.length;
      }
    }
    return count;
  }

  double _getShowRevenue(String movie, String theater, String screen, String time) {
    double total = 0;
    final targetMovie = movie.trim().toLowerCase();
    final targetTheater = theater.trim().toLowerCase();
    final targetScreen = screen.trim().toLowerCase();
    final targetTime = time.trim().toLowerCase();

    for (final b in MockData.bookings) {
      if (b.status != 'Cancelled' &&
          b.movieTitle.trim().toLowerCase() == targetMovie &&
          b.cinema.trim().toLowerCase() == targetTheater &&
          (b.screen.isEmpty || b.screen.trim().toLowerCase() == targetScreen) &&
          b.time.trim().toLowerCase() == targetTime) {
        total += b.totalAmount;
      }
    }
    return total;
  }

  // ── Action: Cancel Show ──
  Future<void> _cancelShow(String movie, String theater, String screen, String time) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Show'),
        content: Text('Are you sure you want to cancel $movie at $time on $screen ($theater) for $_selectedDate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Cancel Show', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      final dateMap = MockData.movieSchedules[movie]?[_selectedDate];
      if (dateMap != null) {
        final times = dateMap[theater]?[screen];
        if (times != null) {
          times.remove(time);
          if (times.isEmpty) dateMap[theater]?.remove(screen);
          if (dateMap[theater] != null && dateMap[theater]!.isEmpty) {
            dateMap.remove(theater);
          }
        }
      }
    });
    await MockData.saveAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Show "$movie" at $time cancelled successfully.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  // ── Action: Edit Show ──
  Future<void> _showEditShowDialog(String currentMovie, String theater, String screen, String currentTime) async {
    final movieTitles = MockData.allMovies.map((m) => m.title).toList();
    String selectedMovie = movieTitles.contains(currentMovie)
        ? currentMovie
        : (movieTitles.isNotEmpty ? movieTitles.first : currentMovie);
    final timeCtrl = TextEditingController(text: currentTime);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Show Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location: $theater — $screen ($_selectedDate)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              if (movieTitles.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue: movieTitles.contains(selectedMovie) ? selectedMovie : movieTitles.first,
                  decoration: const InputDecoration(labelText: 'Movie'),
                  items: movieTitles
                      .map((title) => DropdownMenuItem(value: title, child: Text(title)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedMovie = val);
                  },
                ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Showtime (e.g. 07:30 PM)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTime = timeCtrl.text.trim();
                if (newTime.isEmpty) return;

                // Remove old show entry
                final dateMap = MockData.movieSchedules[currentMovie]?[_selectedDate];
                if (dateMap != null) {
                  final times = dateMap[theater]?[screen];
                  if (times != null) {
                    times.remove(currentTime);
                  }
                }

                // Add new show entry
                MockData.movieSchedules.putIfAbsent(selectedMovie, () => {});
                MockData.movieSchedules[selectedMovie]!.putIfAbsent(_selectedDate, () => {});
                MockData.movieSchedules[selectedMovie]![_selectedDate]!.putIfAbsent(theater, () => {});
                MockData.movieSchedules[selectedMovie]![_selectedDate]![theater]!.putIfAbsent(screen, () => []);

                if (!MockData.movieSchedules[selectedMovie]![_selectedDate]![theater]![screen]!.contains(newTime)) {
                  MockData.movieSchedules[selectedMovie]![_selectedDate]![theater]![screen]!.add(newTime);
                }

                await MockData.saveAll();
                setState(() {});
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Action: Show Stats & Analytics ──
  void _showStatsDialog(String movie, String theater, String screen, String time) {
    final bookedSeats = _getBookedSeatsCount(movie, theater, screen, time);
    final revenue = _getShowRevenue(movie, theater, screen, time);
    const totalCapacity = 160; // 10 rows x 16 seats
    final occupancyPct = (bookedSeats / totalCapacity * 100).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics_outlined, color: AppTheme.primaryRed),
            SizedBox(width: 8),
            Text('Show Performance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movie, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
            Text('$theater • $screen • $time ($_selectedDate)', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Booked Seats', '$bookedSeats / $totalCapacity', Icons.event_seat_outlined),
                _buildStatItem('Occupancy', '$occupancyPct%', Icons.pie_chart_outline),
                _buildStatItem('Revenue', '₹${revenue.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRed),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  // ── Action: Add Show ──
  void _showAddShowDialog() {
    if (MockData.allMovies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No movies available to schedule.')),
      );
      return;
    }

    final movieTitles = MockData.allMovies.map((m) => m.title).toList();
    String selectedMovie = movieTitles.first;
    String selectedTheater = 'Kairali';
    String selectedScreen = 'Screen 01';
    String selectedDateForShow = _selectedDate;
    final timeCtrl = TextEditingController(text: '07:30 PM');

    final dateOptions = _availableDates.contains(selectedDateForShow)
        ? _availableDates
        : [selectedDateForShow, ..._availableDates];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Show Schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: dateOptions.contains(selectedDateForShow) ? selectedDateForShow : dateOptions.first,
                  decoration: const InputDecoration(labelText: 'Date'),
                  items: dateOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedDateForShow = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: movieTitles.contains(selectedMovie) ? selectedMovie : movieTitles.first,
                  decoration: const InputDecoration(labelText: 'Select Movie'),
                  items: movieTitles
                      .map((title) => DropdownMenuItem(value: title, child: Text(title)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedMovie = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: const ['Kairali', 'Nila'].contains(selectedTheater) ? selectedTheater : 'Kairali',
                  decoration: const InputDecoration(labelText: 'Theater'),
                  items: const [
                    DropdownMenuItem(value: 'Kairali', child: Text('Kairali')),
                    DropdownMenuItem(value: 'Nila', child: Text('Nila')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedTheater = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: const ['Screen 01', 'Screen 02'].contains(selectedScreen) ? selectedScreen : 'Screen 01',
                  decoration: const InputDecoration(labelText: 'Screen'),
                  items: const [
                    DropdownMenuItem(value: 'Screen 01', child: Text('Screen 01')),
                    DropdownMenuItem(value: 'Screen 02', child: Text('Screen 02')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedScreen = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(labelText: 'Showtime (e.g. 07:30 PM)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final time = timeCtrl.text.trim();
                if (time.isEmpty) return;

                MockData.movieSchedules.putIfAbsent(selectedMovie, () => {});
                MockData.movieSchedules[selectedMovie]!.putIfAbsent(selectedDateForShow, () => {});
                MockData.movieSchedules[selectedMovie]![selectedDateForShow]!.putIfAbsent(selectedTheater, () => {});
                MockData.movieSchedules[selectedMovie]![selectedDateForShow]![selectedTheater]!.putIfAbsent(selectedScreen, () => []);

                if (!MockData.movieSchedules[selectedMovie]![selectedDateForShow]![selectedTheater]![selectedScreen]!.contains(time)) {
                  MockData.movieSchedules[selectedMovie]![selectedDateForShow]![selectedTheater]![selectedScreen]!.add(time);
                }

                await MockData.saveAll();
                setState(() {
                  _selectedDate = selectedDateForShow;
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: const Text('Add Show'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gather all theaters for selected date from all movie schedules safely
    final Map<String, Map<String, List<Map<String, String>>>> theaterShows = {};
    if (MockData.movieSchedules.isNotEmpty) {
      MockData.movieSchedules.forEach((movie, dates) {
        if (movie.isEmpty) return;
        final dateEntry = dates[_selectedDate];
        if (dateEntry == null) return;
        dateEntry.forEach((theater, screens) {
          if (theater.isEmpty) return;
          if (_selectedTheaterFilter != 'All Theaters' && theater != _selectedTheaterFilter) return;

          theaterShows.putIfAbsent(theater, () => {});
          screens.forEach((screen, times) {
            if (screen.isEmpty) return;
            theaterShows[theater]!.putIfAbsent(screen, () => []);
            for (final t in times) {
              if (t.isNotEmpty) {
                theaterShows[theater]![screen]!.add({'movie': movie, 'time': t});
              }
            }
          });
        });
      });
    }

    final datesList = _availableDates;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Show Schedule',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage daily movie showtimes, screen assignments, and scheduling.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: _selectedTheaterFilter,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTheaterFilter = val);
                    },
                    items: const [
                      DropdownMenuItem(value: 'All Theaters', child: Text('All Theaters')),
                      DropdownMenuItem(value: 'Kairali', child: Text('Kairali')),
                      DropdownMenuItem(value: 'Nila', child: Text('Nila')),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddShowDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Show'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Filter Pills
          if (datesList.isNotEmpty)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Text('Select Date: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ...datesList.map((date) {
                  final isSelected = date == _selectedDate;
                  return ChoiceChip(
                    label: Text(date),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryRed,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedDate = date);
                    },
                  );
                }),
              ],
            ),
          const SizedBox(height: 24),

          if (theaterShows.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No shows scheduled for $_selectedDate.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 800),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...theaterShows.entries.expand((theaterEntry) {
                      final theater = theaterEntry.key;
                      final screens = theaterEntry.value;
                      return [
                        ...screens.entries.map((screenEntry) {
                          final screen = screenEntry.key;
                          final shows = screenEntry.value;
                          return SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: _buildScreenColumn(
                                context,
                                '$theater — $screen',
                                theater,
                                AppTheme.errorRedBg,
                                AppTheme.darkRed,
                                shows.asMap().entries.map((entry) {
                                  final show = entry.value;
                                  final movie = show['movie']!;
                                  final time = show['time']!;
                                  final bookedSeats = _getBookedSeatsCount(movie, theater, screen, time);
                                  final revenue = _getShowRevenue(movie, theater, screen, time);
                                  final occupancy = (bookedSeats / 160.0).clamp(0.0, 1.0);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (entry.key > 0) const SizedBox(height: 16),
                                      _buildShowCard(
                                        context,
                                        movie,
                                        time,
                                        theater,
                                        screen,
                                        '$bookedSeats Seats Booked',
                                        '₹${revenue.toStringAsFixed(0)}',
                                        occupancy,
                                        onEdit: () => _showEditShowDialog(movie, theater, screen, time),
                                        onStats: () => _showStatsDialog(movie, theater, screen, time),
                                        onCancel: () => _cancelShow(movie, theater, screen, time),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }),
                      ];
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScreenColumn(BuildContext context, String title, String badgeText, Color badgeBg, Color badgeTextCol, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: badgeTextCol,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildShowCard(
    BuildContext context,
    String title,
    String time,
    String theater,
    String screen,
    String seatsInfo,
    String revenueInfo,
    double occupancy, {
    VoidCallback? onEdit,
    VoidCallback? onStats,
    VoidCallback? onCancel,
  }) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkRed,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textPrimary),
                      onSelected: (val) {
                        if (val == 'edit') {
                          onEdit?.call();
                        } else if (val == 'stats') {
                          onStats?.call();
                        } else if (val == 'cancel') {
                          onCancel?.call();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: AppTheme.textPrimary),
                              SizedBox(width: 8),
                              Text('Edit Show'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'stats',
                          child: Row(
                            children: [
                              Icon(Icons.analytics_outlined, size: 16, color: AppTheme.primaryRed),
                              SizedBox(width: 8),
                              Text('Show Analytics'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel_outlined, size: 16, color: AppTheme.errorRed),
                              SizedBox(width: 8),
                              Text('Cancel Show', style: TextStyle(color: AppTheme.errorRed)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      seatsInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      revenueInfo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.darkRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: occupancy,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkRed),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons Bottom Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      side: const BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 14, color: AppTheme.errorRed),
                    label: const Text('Cancel', style: TextStyle(fontSize: 12, color: AppTheme.errorRed)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRedBg,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
