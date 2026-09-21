import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'custom_card.dart';

class ShowManagementScreen extends StatefulWidget {
  const ShowManagementScreen({super.key});

  @override
  State<ShowManagementScreen> createState() => _ShowManagementScreenState();
}

class _ShowManagementScreenState extends State<ShowManagementScreen> {
  /// Returns today's date label matching the format used throughout the app.
  String get _todayLabel {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  /// Cancels (removes) a specific show time for a movie/theater/screen and persists.
  Future<void> _cancelShow(String movie, String theater, String screen, String time) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Show'),
        content: Text('Cancel $movie at $time on $screen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Show', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      final dateMap = MockData.movieSchedules[movie]?[_todayLabel];
      if (dateMap != null) {
        final times = dateMap[theater]?[screen];
        if (times != null) {
          times.remove(time);
          // If no more times remain, clean up empty nodes
          if (times.isEmpty) dateMap[theater]?.remove(screen);
          if (dateMap[theater]?.isEmpty ?? false) dateMap.remove(theater);
        }
      }
    });
    await MockData.saveAll();
  }

  String _selectedTheaterFilter = 'All Theaters';

  void _showAddShowDialog() {
    if (MockData.allMovies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No movies available to schedule.')),
      );
      return;
    }

    String selectedMovie = MockData.allMovies.first.title;
    String selectedTheater = 'Kairali';
    String selectedScreen = 'Screen 01';
    final timeCtrl = TextEditingController(text: '07:30 PM');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Show Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMovie,
                decoration: const InputDecoration(labelText: 'Select Movie'),
                items: MockData.allMovies
                    .map((m) => DropdownMenuItem(value: m.title, child: Text(m.title)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedMovie = val);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTheater,
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
                value: selectedScreen,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final time = timeCtrl.text.trim();
                if (time.isEmpty) return;

                final today = _todayLabel;
                MockData.movieSchedules.putIfAbsent(selectedMovie, () => {});
                MockData.movieSchedules[selectedMovie]!.putIfAbsent(today, () => {});
                MockData.movieSchedules[selectedMovie]![today]!.putIfAbsent(selectedTheater, () => {});
                MockData.movieSchedules[selectedMovie]![today]![selectedTheater]!.putIfAbsent(selectedScreen, () => []);

                if (!MockData.movieSchedules[selectedMovie]![today]![selectedTheater]![selectedScreen]!.contains(time)) {
                  MockData.movieSchedules[selectedMovie]![today]![selectedTheater]![selectedScreen]!.add(time);
                }

                await MockData.saveAll();
                setState(() {});
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
    final today = _todayLabel;

    // Gather all theaters for today from all movie schedules
    final Map<String, Map<String, List<Map<String, String>>>> theaterShows = {};
    MockData.movieSchedules.forEach((movie, dates) {
      final dateEntry = dates[today];
      if (dateEntry == null) return;
      dateEntry.forEach((theater, screens) {
        if (_selectedTheaterFilter != 'All Theaters' && theater != _selectedTheaterFilter) return;

        theaterShows.putIfAbsent(theater, () => {});
        screens.forEach((screen, times) {
          theaterShows[theater]!.putIfAbsent(screen, () => []);
          for (final t in times) {
            theaterShows[theater]![screen]!.add({'movie': movie, 'time': t});
          }
        });
      });
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                    'Manage daily movie showtimes, screen assignments, and scheduling. Today: $today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Row(
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
                  const SizedBox(width: 12),
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
          const SizedBox(height: 32),

          if (theaterShows.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No shows scheduled for today.',
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
                            width: 300,
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
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (entry.key > 0) const SizedBox(height: 16),
                                      _buildShowCard(
                                        context,
                                        show['movie']!,
                                        show['time']!,
                                        null,
                                        null,
                                        null,
                                        0.5,
                                        onCancel: () => _cancelShow(
                                          show['movie']!,
                                          theater,
                                          screen,
                                          show['time']!,
                                        ),
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

  Widget _buildShowCard(BuildContext context, String title, String time, String? seats, String? revenue, String? imageUrl, double occupancy, {VoidCallback? onCancel}) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image / Header area
          if (imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      const Icon(Icons.more_vert, size: 18, color: AppTheme.textPrimary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: occupancy,
                    minHeight: 4,
                    backgroundColor: AppTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkRed),
                  )
                ],
              ),
            ),

          // Details & Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (seats != null && revenue != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(seats, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              Text('Seats', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                      Text(revenue, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkRed)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.errorRed),
                    label: const Text('Cancel Show', style: TextStyle(color: AppTheme.errorRed)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRedBg,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
