import 'package:flutter/material.dart';
import 'package:booking/theme/app_theme.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/seat_row_model.dart';
import 'package:booking/models/movie_model.dart';
import 'package:booking/models/theater_model.dart';
import 'custom_card.dart';

class SeatBlockingScreen extends StatefulWidget {
  const SeatBlockingScreen({super.key});

  @override
  State<SeatBlockingScreen> createState() => _SeatBlockingScreenState();
}

class _SeatBlockingScreenState extends State<SeatBlockingScreen> {
  Set<String> selectedSeats = {};

  String _selectedCinema = 'Kairali';
  String _selectedScreen = 'Screen 01';
  String _selectedShowtime = '07:30 PM';

  String get _sessionKey => '${_selectedCinema}_${_selectedScreen}_$_selectedShowtime';

  // Booked seats dynamically calculated from real user bookings
  Set<String> get bookedSeats {
    final set = <String>{};
    for (final b in MockData.bookings) {
      if (b.status != 'Cancelled' &&
          b.cinema.toLowerCase().contains(_selectedCinema.toLowerCase())) {
        set.addAll(b.seats);
      }
    }
    return set;
  }

  // Blocked seats backed by MockData for persistence
  Set<String> get blockedSeats => Set<String>.from(
        MockData.blockedSeats[_sessionKey] ?? [],
      );

  void toggleSeatSelection(String seatId) {
    final altId = seatId.contains('-') ? seatId.replaceAll('-', '') : seatId;
    if (bookedSeats.contains(seatId) || bookedSeats.contains(altId)) {
      return; // Cannot select booked seats
    }
    setState(() {
      if (selectedSeats.contains(seatId) || selectedSeats.contains(altId)) {
        selectedSeats.remove(seatId);
        selectedSeats.remove(altId);
      } else {
        selectedSeats.add(seatId);
      }
    });
  }

  void clearSelection() {
    setState(() {
      selectedSeats.clear();
    });
  }

  void _selectFullRow() {
    final layout = MockData.getLayout(_selectedCinema, _selectedScreen);
    if (layout.isEmpty) return;
    setState(() {
      for (final r in layout) {
        for (int i = 1; i <= r.seatCount; i++) {
          final sId = '${r.rowName}$i';
          final sIdAlt = '${r.rowName}-$i';
          if (!bookedSeats.contains(sId) && !bookedSeats.contains(sIdAlt)) {
            selectedSeats.add(sId);
          }
        }
      }
    });
  }

  void _selectOddEven(bool selectOdd) {
    final layout = MockData.getLayout(_selectedCinema, _selectedScreen);
    if (layout.isEmpty) return;
    setState(() {
      for (final r in layout) {
        for (int i = 1; i <= r.seatCount; i++) {
          if ((selectOdd && i % 2 != 0) || (!selectOdd && i % 2 == 0)) {
            final sId = '${r.rowName}$i';
            final sIdAlt = '${r.rowName}-$i';
            if (!bookedSeats.contains(sId) && !bookedSeats.contains(sIdAlt)) {
              selectedSeats.add(sId);
            }
          }
        }
      }
    });
  }

  Future<void> blockSelectedSeats() async {
    final current = Set<String>.from(blockedSeats);
    current.addAll(selectedSeats);
    setState(() {
      MockData.blockedSeats[_sessionKey] = current.toList();
      selectedSeats.clear();
    });
    await MockData.saveAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected seats successfully blocked for this session.'),
          backgroundColor: AppTheme.darkRed,
        ),
      );
    }
  }

  Future<void> unblockSelectedSeats() async {
    final current = Set<String>.from(blockedSeats);
    current.removeAll(selectedSeats);
    setState(() {
      MockData.blockedSeats[_sessionKey] = current.toList();
      selectedSeats.clear();
    });
    await MockData.saveAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected seats unblocked.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column
            SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSessionDetails(),
                    const SizedBox(height: 24),
                    _buildAuditoriumStatus(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Right Column
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFloorPlanHeader(),
                      const SizedBox(height: 40),
                      _buildScreenIndicator(),
                      const SizedBox(height: 40),
                      Expanded(
                        child: _buildSeatGrid(),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildFloorPlanFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        // Floating Bottom Bar
        if (selectedSeats.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFloatingSelectionBar(),
            ),
          ),
      ],
    );
  }

  List<String> get availableCinemas {
    final list = MockData.theaters.map((t) => t.name).toList();
    if (list.isEmpty) return ['Kairali', 'Nila'];
    return list;
  }

  List<String> get availableScreens {
    final screensFromPrices = MockData.screenPrices[_selectedCinema]?.keys.toList();
    if (screensFromPrices != null && screensFromPrices.isNotEmpty) {
      return screensFromPrices;
    }
    final screensFromLayouts = MockData.screenLayouts[_selectedCinema]?.keys.toList();
    if (screensFromLayouts != null && screensFromLayouts.isNotEmpty) {
      return screensFromLayouts;
    }
    return ['Screen 01', 'Screen 02'];
  }

  List<String> get availableShowtimes {
    final theater = MockData.theaters.firstWhere(
      (t) => t.name.toLowerCase() == _selectedCinema.toLowerCase(),
      orElse: () => MockData.theaters.isNotEmpty ? MockData.theaters.first : const TheaterModel(name: 'Kairali', type: '', showtimes: []),
    );
    if (theater.showtimes.isNotEmpty) {
      return theater.showtimes;
    }
    return ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '10:30 PM'];
  }

  List<MovieModel> get moviesForSelectedCinema {
    final list = <MovieModel>[];
    final targetCinema = _selectedCinema.trim().toLowerCase();

    for (final movie in MockData.allMovies) {
      final matchesTheater = movie.theaters.any(
        (t) => t.trim().toLowerCase().contains(targetCinema),
      );
      
      bool isScheduledInTheater = false;
      final schedulesForMovie = MockData.movieSchedules[movie.title];
      if (schedulesForMovie != null) {
        for (final dateEntry in schedulesForMovie.entries) {
          if (dateEntry.value.keys.any((k) => k.trim().toLowerCase().contains(targetCinema))) {
            isScheduledInTheater = true;
            break;
          }
        }
      }

      if (matchesTheater || isScheduledInTheater) {
        list.add(movie);
      }
    }
    return list;
  }

  MovieModel? get scheduledMovie {
    for (final movieEntry in MockData.movieSchedules.entries) {
      final movieTitle = movieEntry.key;
      for (final dateEntry in movieEntry.value.entries) {
        final theaterMap = dateEntry.value[_selectedCinema];
        if (theaterMap != null) {
          final timesList = theaterMap[_selectedScreen];
          if (timesList != null && timesList.contains(_selectedShowtime)) {
            try {
              return MockData.allMovies.firstWhere(
                (m) => m.title.trim().toLowerCase() == movieTitle.trim().toLowerCase(),
              );
            } catch (_) {}
          }
        }
      }
    }

    for (final movieEntry in MockData.movieSchedules.entries) {
      final movieTitle = movieEntry.key;
      for (final dateEntry in movieEntry.value.entries) {
        final theaterMap = dateEntry.value[_selectedCinema];
        if (theaterMap != null && theaterMap.containsKey(_selectedScreen)) {
          try {
            return MockData.allMovies.firstWhere(
              (m) => m.title.trim().toLowerCase() == movieTitle.trim().toLowerCase(),
            );
          } catch (_) {}
        }
      }
    }

    final theaterMovies = moviesForSelectedCinema;
    if (theaterMovies.isNotEmpty) {
      return theaterMovies.first;
    }

    return null;
  }

  Widget _buildSessionDetails() {
    final activeMovie = scheduledMovie;

    final currentCinema = availableCinemas.contains(_selectedCinema) ? _selectedCinema : availableCinemas.first;
    final currentScreen = availableScreens.contains(_selectedScreen) ? _selectedScreen : availableScreens.first;
    final currentShowtime = availableShowtimes.contains(_selectedShowtime) ? _selectedShowtime : availableShowtimes.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Details',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theater',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currentCinema,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: availableCinemas.map((cinema) {
                      return DropdownMenuItem(
                        value: cinema,
                        child: Text(
                          cinema,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCinema = val;
                          selectedSeats.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currentScreen,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    items: availableScreens.map((screen) {
                      return DropdownMenuItem(
                        value: screen,
                        child: Text(
                          screen,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedScreen = val;
                          selectedSeats.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Showtime',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: currentShowtime,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: Colors.white,
            filled: true,
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          items: availableShowtimes.map((st) {
            return DropdownMenuItem(
              value: st,
              child: Text(
                st,
                style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedShowtime = val;
                selectedSeats.clear();
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Scheduled Movie',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: activeMovie != null && activeMovie.posterUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(activeMovie.posterUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.movie, color: Colors.white)),
                      )
                    : const Icon(Icons.movie, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeMovie?.title ?? "Feature Movie",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${activeMovie?.duration ?? '2h 15m'} • ${activeMovie?.genres.join('/') ?? 'Drama'}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_selectedCinema • $_selectedScreen • $_selectedShowtime",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditoriumStatus() {
    final layout = MockData.getLayout(_selectedCinema, _selectedScreen);
    final totalSeatsCount = layout.fold<int>(0, (sum, r) => sum + r.seatCount);
    final availableCount = (totalSeatsCount - (bookedSeats.length + blockedSeats.length)).clamp(0, 9999);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUDITORIUM STATUS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatusBox('$availableCount', 'Available', const Color(0xFFF3F4F6))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusBox('${bookedSeats.length}', 'Booked', const Color(0xFFE5E7EB))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatusBox('${blockedSeats.length}', 'Blocked', const Color(0xFFF3F4F6))),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFECACA)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedSeats.length}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selected to\nBlock',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBox(String count, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: selectedSeats.isEmpty ? null : blockSelectedSeats,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Confirm Block Selection', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.darkRed,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: selectedSeats.isEmpty ? null : clearSelection,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppTheme.borderLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Clear Current Selection', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFloorPlanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactive Floor\nPlan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(Colors.white, 'Available', true),
              _buildLegendItem(const Color(0xFFE5E7EB), 'Booked'),
              _buildLegendItem(const Color(0xFF6B7280), 'Blocked'),
              _buildLegendItem(AppTheme.primaryRed, 'Selection'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, [bool withBorder = false]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: withBorder ? Border.all(color: AppTheme.borderLight) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildScreenIndicator() {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [Color(0x00E5E7EB), Color(0xFFE5E7EB), Color(0xFFE5E7EB), Color(0x00E5E7EB)],
              stops: [0.0, 0.2, 0.8, 1.0],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SCREEN THIS WAY',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                letterSpacing: 4,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    final layout = MockData.getLayout(_selectedCinema, _selectedScreen);

    if (layout.isEmpty) {
      return const Center(
        child: Text(
          'No seats configured for this screen by owner.',
          style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                children: layout.map((seatRow) => _buildSeatRowFromOwnerLayout(seatRow)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeatRowFromOwnerLayout(SeatRow seatRow) {
    final rowLetter = seatRow.rowName;
    final totalSeats = seatRow.seatCount;

    int leftCount = 0;
    int rightCount = 0;
    int centerCount = totalSeats;

    if (totalSeats >= 8) {
      leftCount = (totalSeats * 0.25).round();
      rightCount = (totalSeats * 0.25).round();
      centerCount = totalSeats - leftCount - rightCount;
    }

    List<Widget> children = [
      SizedBox(
        width: 32,
        child: Center(
          child: Text(
            rowLetter,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
    ];

    int seatNum = 1;
    if (leftCount > 0) {
      for (int i = 0; i < leftCount; i++) {
        children.add(_buildSeat(rowLetter, seatNum));
        seatNum++;
      }
      children.add(const SizedBox(width: 24));
    }

    for (int i = 0; i < centerCount; i++) {
      children.add(_buildSeat(rowLetter, seatNum));
      seatNum++;
    }

    if (rightCount > 0) {
      children.add(const SizedBox(width: 24));
      for (int i = 0; i < rightCount; i++) {
        children.add(_buildSeat(rowLetter, seatNum));
        seatNum++;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildSeat(String rowLetter, int seatNumber) {
    final seatId1 = '$rowLetter$seatNumber';
    final seatId2 = '$rowLetter-$seatNumber';

    final isBooked = bookedSeats.contains(seatId1) || bookedSeats.contains(seatId2);
    final isBlocked = blockedSeats.contains(seatId1) || blockedSeats.contains(seatId2);
    final isSelected = selectedSeats.contains(seatId1) || selectedSeats.contains(seatId2);

    Color bgColor = Colors.white;
    Color textColor = AppTheme.textPrimary;
    Color borderColor = AppTheme.borderLight;

    if (isBooked) {
      bgColor = const Color(0xFFE5E7EB);
      textColor = const Color(0xFF374151);
      borderColor = Colors.transparent;
    } else if (isBlocked) {
      bgColor = const Color(0xFF4B5563);
      textColor = Colors.white;
      borderColor = Colors.transparent;
    } else if (isSelected) {
      bgColor = AppTheme.primaryRed;
      textColor = Colors.white;
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () => toggleSeatSelection(seatId1),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: isBlocked
            ? const Icon(Icons.block, size: 14, color: Colors.white)
            : Text(
                '$seatNumber',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildFloorPlanFooter() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: _selectFullRow,
          borderRadius: BorderRadius.circular(8),
          child: _buildFooterButton('Select All\nSeats'),
        ),
        InkWell(
          onTap: () => _selectOddEven(true),
          borderRadius: BorderRadius.circular(8),
          child: _buildFooterButton('Select\nOdd Seats'),
        ),
        InkWell(
          onTap: () => _selectOddEven(false),
          borderRadius: BorderRadius.circular(8),
          child: _buildFooterButton('Select\nEven Seats'),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.info_outline, size: 16, color: AppTheme.textPrimary),
        Text(
          'Click any seat to select and toggle block/unblock status.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildFooterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }

  Widget _buildFloatingSelectionBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.primaryRed,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${selectedSeats.length} Seats Selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 24),
            Container(height: 24, width: 1, color: AppTheme.borderLight),
            const SizedBox(width: 24),
            ElevatedButton(
              onPressed: blockSelectedSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Block Selected'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: unblockSelectedSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Unblock Selected'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: clearSelection,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: const Color(0xFFF3F4F6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
