import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_dropdown.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';
import 'package:booking/core/utils/ist_time_utils.dart';
import 'package:booking/data/mock_data.dart';

class OwnerScheduleScreen extends StatefulWidget {
  final String theaterName;
  const OwnerScheduleScreen({super.key, this.theaterName = 'Kairali'});

  @override
  State<OwnerScheduleScreen> createState() => _OwnerScheduleScreenState();
}

class _OwnerScheduleScreenState extends State<OwnerScheduleScreen> {
  late String _selectedMovie;
  late String _selectedTheater;
  String _selectedScreen = 'Screen 01';

  late final TextEditingController _dateCtrl;
  late DateTime _selectedDateObj;

  // Occupied slots per date and screen: DateLabel -> Screen -> Set of times
  final Map<String, Map<String, Set<String>>> _occupiedSlots = {};

  // Schedule preview state per date and screen: DateLabel -> Screen -> {movie, time}
  final Map<String, Map<String, Map<String, String>>> _schedulePreview = {};

  // Default time slots used for any theater not explicitly listed
  static const Map<String, List<String>> _defaultScreenSlots = {
    'Screen 01': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
    'Screen 02': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
  };

  static const Map<String, Map<String, List<String>>> _theaterData = {
    'Kairali': {
      'Screen 01': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
      'Screen 02': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
    },
    'Nila': {
      'Screen 01': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
      'Screen 02': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
    },
  };

  List<String> get _timeSlots {
    // Look up by theater name first; fall back to the default slots so any
    // theater always has times to display.
    return _theaterData[_selectedTheater]?[_selectedScreen]
        ?? _defaultScreenSlots[_selectedScreen]
        ?? ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'];
  }

  final Set<String> _selectedTimes = {};

  @override
  void initState() {
    super.initState();
    _selectedMovie = MockData.allMovies.isNotEmpty ? MockData.allMovies.first.title : 'Drishyam 3';
    // Lock the theater to the owner's own theater
    _selectedTheater = widget.theaterName;
    // Use IST-aligned date so the saved label matches the user module's date chips
    final now = IstTimeUtils.nowInIst();
    _selectedDateObj = DateTime.utc(now.year, now.month, now.day);
    _dateCtrl = TextEditingController(
      text:
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
    );
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Set<String> get _allOccupiedTimes {
    final dateLabel = IstTimeUtils.formatDateLabel(_selectedDateObj);
    final Set<String> times = {};
    
    for (final movieEntry in MockData.movieSchedules.entries) {
      final theaterMap = movieEntry.value[dateLabel];
      if (theaterMap != null) {
        final screenMap = theaterMap[_selectedTheater];
        if (screenMap != null) {
          final scheduledTimes = screenMap[_selectedScreen];
          if (scheduledTimes != null) {
            times.addAll(scheduledTimes);
          }
        }
      }
    }
    
    times.addAll(_occupiedSlots[dateLabel]?[_selectedScreen] ?? {});
    return times;
  }

  bool _isOccupied(String time) {
    return _allOccupiedTimes.contains(time);
  }

  /// Returns true if any selected slot is adjacent to an occupied slot on the same screen
  bool get _hasOverlapRisk {
    final occupiedTimes = _allOccupiedTimes;
    for (final selectedTime in _selectedTimes) {
      final selectedIdx = _timeSlots.indexOf(selectedTime);
      for (final occ in occupiedTimes) {
        final occIdx = _timeSlots.indexOf(occ);
        if ((selectedIdx - occIdx).abs() == 1) return true;
      }
    }
    return false;
  }

  /// First selected time that has an overlap risk (for display in warning)
  String get _overlapRiskTime {
    final occupiedTimes = _allOccupiedTimes;
    for (final selectedTime in _selectedTimes) {
      final selectedIdx = _timeSlots.indexOf(selectedTime);
      for (final occ in occupiedTimes) {
        final occIdx = _timeSlots.indexOf(occ);
        if ((selectedIdx - occIdx).abs() == 1) return selectedTime;
      }
    }
    return _selectedTimes.isEmpty ? '' : _selectedTimes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminAppBar(title: widget.theaterName, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'Schedule a Show',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Assign movies to screens and manage daily\ntime slots.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Form Card ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Movie',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminDropdown<String>(
                    value: _selectedMovie,
                    prefixIcon: const Icon(
                      Icons.movie_creation_outlined,
                      color: AppColors.textSecondary,
                    ),
                    items: MockData.allMovies.map((movie) {
                      return DropdownMenuItem(
                        value: movie.title,
                        child: Text(movie.title),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMovie = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Theater',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Read-only: owner can only schedule for their own theater
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_city_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _selectedTheater,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'YOUR THEATER',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Select Screen',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminDropdown<String>(
                    value: _selectedScreen,
                    prefixIcon: const Icon(
                      Icons.grid_view_outlined,
                      color: AppColors.textSecondary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Screen 01',
                        child: Text('Screen 01'),
                      ),
                      DropdownMenuItem(
                        value: 'Screen 02',
                        child: Text('Screen 02'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedScreen = val;
                          _selectedTimes.clear();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _dateCtrl,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          // Normalize to UTC midnight to match generateAvailableDates labels
                          _selectedDateObj = DateTime.utc(picked.year, picked.month, picked.day);
                          // Update the text field for visual confirmation
                          _dateCtrl.text =
                              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        });
                      }
                    },
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Text(
                        'Available Time Slots',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      
                      const Spacer(),
                      if (_selectedTimes.isNotEmpty)
                        Text(
                          '${_selectedTimes.length} selected',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _timeSlots.map((time) {
                      final bool isSelected = _selectedTimes.contains(time);
                      final bool isOccupied = _isOccupied(time);

                      return GestureDetector(
                        onTap: isOccupied
                            ? null
                            : () {
                                setState(() {
                                  // Toggle: tap to select, tap again to deselect
                                  if (isSelected) {
                                    _selectedTimes.remove(time);
                                  } else {
                                    _selectedTimes.add(time);
                                  }
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 50),
                          width:
                              (MediaQuery.of(context).size.width -
                                  (AppSpacing.lg * 4) -
                                  AppSpacing.sm * 2) /
                              3,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : isOccupied
                                ? AppColors.surface
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : isOccupied
                                  ? AppColors.divider
                                  : AppColors.divider,
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected || isOccupied) ...[
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: isSelected ? Colors.white : AppColors.textHint,
                                  size: 12,
                                ),
                                const SizedBox(width: 3),
                              ],
                              Text(
                                time,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : isOccupied
                                          ? AppColors.textHint
                                          : AppColors.textPrimary,
                                      fontWeight: (isSelected || isOccupied)
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AdminButton(
                    text: 'Confirm Schedule (${_selectedTimes.length} slot${_selectedTimes.length > 1 ? 's' : ''})',
                    icon: Icons.event_available,
                    onPressed: _selectedTimes.isEmpty
                        ? null
                        : () {
                            final sortedTimes = _selectedTimes.toList()
                              ..sort((a, b) {
                                return _timeSlots.indexOf(a)
                                    .compareTo(_timeSlots.indexOf(b));
                              });
                            final timeSummary = sortedTimes.join(', ');
                            final dateLabel = IstTimeUtils.formatDateLabel(_selectedDateObj);
                              
                              _schedulePreview
                                  .putIfAbsent(dateLabel, () => {})[_selectedScreen] = {
                                'movie': _selectedMovie,
                                'time': sortedTimes.first,
                              };
                              _occupiedSlots
                                  .putIfAbsent(dateLabel, () => {})
                                  .putIfAbsent(_selectedScreen, () => {})
                                  .addAll(_selectedTimes);

                              // Save to global schedules so the user app sees it
                              MockData.movieSchedules.putIfAbsent(_selectedMovie, () => {});
                              MockData.movieSchedules[_selectedMovie]!.putIfAbsent(dateLabel, () => {});
                              MockData.movieSchedules[_selectedMovie]![dateLabel]!.putIfAbsent(_selectedTheater, () => {});
                              
                              // Keep any existing times and add the newly selected ones
                              final existingTimes = MockData.movieSchedules[_selectedMovie]![dateLabel]![_selectedTheater]![_selectedScreen] ?? [];
                              final newTimesSet = Set<String>.from(existingTimes)..addAll(_selectedTimes);
                              
                              // Sort times chronologically
                              final sortedGlobalTimes = newTimesSet.toList()
                                ..sort((a, b) {
                                  return _timeSlots.indexOf(a)
                                      .compareTo(_timeSlots.indexOf(b));
                                });
                              MockData.movieSchedules[_selectedMovie]![dateLabel]![_selectedTheater]![_selectedScreen] = sortedGlobalTimes;

                              setState(() {
                                _selectedTimes.clear();
                                _selectedTimes.add(
                                  _timeSlots.firstWhere(
                                    (t) => !_isOccupied(t),
                                    orElse: () => _timeSlots.first,
                                  ),
                                );
                              });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 3),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '$_selectedMovie on $_selectedScreen\n$timeSummary',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Daily Schedule Preview ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Schedule Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    _buildLegendItem(AppColors.primaryDark, 'Occupied'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildLegendItem(AppColors.textHint, 'Free'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Timeline Header
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Screen',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '08 AM',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '10 AM',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '12 PM',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Timelines — driven by _schedulePreview and _selectedScreen
            _buildTimelineRow(
              'SCR 01',
              _schedulePreview[IstTimeUtils.formatDateLabel(_selectedDateObj)]?['Screen 01']?['movie'] ?? 'Drishyam 3',
              _schedulePreview[IstTimeUtils.formatDateLabel(_selectedDateObj)]?['Screen 01']?['time'] ?? '10:00 AM - 01:00 PM',
              0.3,
              0.4,
              _selectedScreen == 'Screen 01',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTimelineRow(
              'SCR 02',
              _schedulePreview[IstTimeUtils.formatDateLabel(_selectedDateObj)]?['Screen 02']?['movie'] ?? 'Michael',
              _schedulePreview[IstTimeUtils.formatDateLabel(_selectedDateObj)]?['Screen 02']?['time'] ?? '11:15 AM - 01:15 PM',
              0.5,
              0.3,
              _selectedScreen == 'Screen 02',
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Warning Alert — only shown when there's an overlap risk ──
            if (_hasOverlapRisk)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Overlap Risk',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'The selected time slot ($_overlapRiskTime) on '
                            '$_selectedScreen only leaves 15 minutes for '
                            'cleaning after the previous show.\n'
                            'Recommended buffer: 30 mins.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _buildTimelineRow(
    String screen,
    String movieTitle,
    String timeStr,
    double startPct,
    double widthPct,
    bool isSelected,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.tv : Icons.tv_outlined,
                size: 16,
                color:
                    isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                screen,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Stack(
              children: [
                Positioned(
                  left:
                      MediaQuery.of(context).size.width * 0.6 * startPct,
                  width:
                      MediaQuery.of(context).size.width * 0.6 * widthPct,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          movieTitle,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
