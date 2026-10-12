import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/core/utils/ist_time_utils.dart';
import 'package:booking/data/mock_data.dart';
import 'package:booking/models/movie_model.dart';

// ============================================================
// EditScheduleDialog
//
// Allows the owner to:
//   1. Open the schedule options sheet displaying ONLY ONE option:
//      "Edit Schedule".
//   2. Through this option, edit screen assignments and show
//      timings for all screens associated with the movie.
//   3. Save changes which propagate across MockData and into
//      the User module.
// ============================================================

class EditScheduleDialog {
  /// Default slots per screen
  static const Map<String, List<String>> _kairaliSlots = {
    'Screen 01': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
    'Screen 02': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
  };

  static const Map<String, List<String>> _nilaSlots = {
    'Screen 01': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
    'Screen 02': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM', '09:30 PM'],
  };

  /// Returns available slot list for a screen in a theater.
  static List<String> getSlotsFor(String theaterName, String screenName) {
    final isNila = theaterName.toLowerCase().contains('nila');
    if (isNila) {
      return _nilaSlots[screenName] ?? _nilaSlots['Screen 01']!;
    }
    return _kairaliSlots[screenName] ?? _kairaliSlots['Screen 01']!;
  }

  /// Directly opens the multi-screen schedule editing screen.
  static Future<bool?> showWithOptions(
    BuildContext context, {
    required MovieModel movie,
    required String theaterName,
  }) {
    return showMultiScreen(
      context,
      theaterName: theaterName,
      movieTitle: movie.title,
    );
  }

  /// Opens the multi-screen schedule editor directly for all screens associated with the movie.
  static Future<bool?> showMultiScreen(
    BuildContext context, {
    required String theaterName,
    required String movieTitle,
    String? initialDateLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiScreenScheduleSheet(
        theaterName: theaterName,
        movieTitle: movieTitle,
        initialDateLabel: initialDateLabel,
      ),
    );
  }

  /// Backward-compatible entrypoint.
  static Future<bool?> show(
    BuildContext context, {
    required String theaterName,
    required String movieTitle,
    required String dateLabel,
    required String currentScreen,
    required List<String> currentTimes,
  }) {
    return showMultiScreen(
      context,
      theaterName: theaterName,
      movieTitle: movieTitle,
      initialDateLabel: dateLabel,
    );
  }
}

// ──────────────────────────────────────────────────────────────
// _MultiScreenScheduleSheet
//
// Multi-screen schedule editor:
// Allows the owner to edit the screen assignments and show timings
// for all screens associated with the movie in this theater.
// ──────────────────────────────────────────────────────────────

class _MultiScreenScheduleSheet extends StatefulWidget {
  final String theaterName;
  final String movieTitle;
  final String? initialDateLabel;

  const _MultiScreenScheduleSheet({
    required this.theaterName,
    required this.movieTitle,
    this.initialDateLabel,
  });

  @override
  State<_MultiScreenScheduleSheet> createState() =>
      _MultiScreenScheduleSheetState();
}

class _MultiScreenScheduleSheetState extends State<_MultiScreenScheduleSheet> {
  late String _selectedDate;
  late List<String> _availableDates;
  late List<String> _screens;

  /// Holds selected time slots per screen: { 'Screen 01': {'10:00 AM', ...}, ... }
  final Map<String, Set<String>> _screenTimes = {};

  /// Holds time slots occupied by other movies on this screen
  final Map<String, Set<String>> _occupiedTimes = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _screens = MockData.getTheaterScreens(widget.theaterName);

    // Collect dates that already have schedules for this movie
    final movieSched = MockData.movieSchedules[widget.movieTitle] ?? {};
    final scheduledDates = <String>[];
    movieSched.forEach((dateLabel, thMap) {
      thMap.forEach((th, scMap) {
        if (MockData.theaterMatches(th, widget.theaterName)) {
          if (scMap.values.any((times) => times.isNotEmpty)) {
            if (!scheduledDates.contains(dateLabel)) {
              scheduledDates.add(dateLabel);
            }
          }
        }
      });
    });

    final defaultDates = IstTimeUtils.generateAvailableDates();
    final combinedDates = <String>[...scheduledDates];
    for (final d in defaultDates) {
      if (!combinedDates.contains(d)) combinedDates.add(d);
    }
    _availableDates = combinedDates;

    _selectedDate = widget.initialDateLabel ??
        (scheduledDates.isNotEmpty ? scheduledDates.first : _availableDates.first);

    _loadSchedulesForSelectedDate();
  }

  void _loadSchedulesForSelectedDate() {
    _screenTimes.clear();
    for (final sc in _screens) {
      _screenTimes[sc] = <String>{};
    }

    final movieSched = MockData.movieSchedules[widget.movieTitle] ?? {};
    final dateMap = movieSched[_selectedDate];
    if (dateMap != null) {
      dateMap.forEach((th, scMap) {
        if (MockData.theaterMatches(th, widget.theaterName)) {
          scMap.forEach((sc, times) {
            if (_screenTimes.containsKey(sc)) {
              _screenTimes[sc]!.addAll(times);
            }
          });
        }
      });
    }

    // Occupied by other movies
    _occupiedTimes.clear();
    for (final sc in _screens) {
      final occupied = <String>{};
      MockData.movieSchedules.forEach((title, dates) {
        if (title.trim().toLowerCase() == widget.movieTitle.trim().toLowerCase()) {
          return;
        }
        final tMap = dates[_selectedDate];
        if (tMap == null) return;
        tMap.forEach((th, scs) {
          if (MockData.theaterMatches(th, widget.theaterName)) {
            final times = scs[sc] ?? [];
            occupied.addAll(times);
          }
        });
      });
      _occupiedTimes[sc] = occupied;
    }
  }

  Future<void> _save() async {
    final totalAssigned = _screenTimes.values.fold<int>(
      0,
      (sum, set) => sum + set.length,
    );

    if (totalAssigned == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please select at least one show timing for at least one screen.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final Map<String, List<String>> screenTimesMap = {};
    _screenTimes.forEach((sc, timesSet) {
      screenTimesMap[sc] = timesSet.toList();
    });

    await MockData.saveMovieScheduleMultiScreen(
      movieTitle: widget.movieTitle,
      theaterName: widget.theaterName,
      dateLabel: _selectedDate,
      screenTimes: screenTimesMap,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule updated successfully for ${widget.movieTitle}!'),
          backgroundColor: AppColors.greenAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final totalAssignedShows = _screenTimes.values.fold<int>(
      0,
      (sum, set) => sum + set.length,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Title & Info ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.edit_calendar_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Schedule',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      '${widget.movieTitle} · ${widget.theaterName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date Selector ──
                  Row(
                    children: [
                      _SectionLabel(label: 'Select Date'),
                      const Spacer(),
                      Text(
                        _selectedDate,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableDates.map((date) {
                        final isSelected = _selectedDate == date;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                                _loadSchedulesForSelectedDate();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black // Yellow bg -> Black text
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Section: All Screen Assignments & Show Timings ──
                  Row(
                    children: [
                      _SectionLabel(label: 'Screen Assignments & Show Timings'),
                      const Spacer(),
                      if (totalAssignedShows > 0)
                        Text(
                          '$totalAssignedShows shows total',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Assign screens and choose show timings for all screens below:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Render card for each screen
                  ..._screens.map((screen) => _buildScreenCard(screen)),

                  // Occupied legend if needed
                  if (_occupiedTimes.values.any((s) => s.isNotEmpty)) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.block_outlined,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Occupied by another movie',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Save Changes Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black, // Yellow bg -> Black spinner
                      ),
                    )
                  : const Icon(Icons.save_alt_outlined, size: 18),
              label: Text(_saving ? 'Saving…' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black, // Yellow bg -> Black text
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Cancel Button ──
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed:
                  _saving ? null : () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenCard(String screen) {
    final times = _screenTimes[screen] ?? <String>{};
    final isAssigned = times.isNotEmpty;
    final occupied = _occupiedTimes[screen] ?? <String>{};
    final slots = EditScheduleDialog.getSlotsFor(widget.theaterName, screen);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isAssigned
              ? AppColors.primary.withValues(alpha: 0.7)
              : AppColors.divider,
          width: isAssigned ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Screen Icon, Title, and Assignment Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isAssigned
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.divider.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.tv_outlined,
                  size: 16,
                  color: isAssigned ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                screen,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              // Assignment Badge
              if (isAssigned)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${times.length} SHOW${times.length > 1 ? 'S' : ''} ASSIGNED',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black, // Yellow bg -> Black text
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Text(
                    'NOT ASSIGNED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Show Timings Label
          Text(
            'Available Show Timings:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Chips for each time slot
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: slots.map((time) {
              final isSelected = times.contains(time);
              final isOccupied = occupied.contains(time);

              return GestureDetector(
                onTap: isOccupied
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            times.remove(time);
                          } else {
                            times.add(time);
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isOccupied
                            ? AppColors.surface
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
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
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected || isOccupied) ...[
                        Icon(
                          isOccupied
                              ? Icons.block_outlined
                              : Icons.check_circle_rounded,
                          size: 13,
                          color: isSelected ? Colors.black : AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.black // Yellow bg -> Black text
                                  : isOccupied
                                      ? AppColors.textHint
                                      : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : isOccupied
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Unassign screen shortcut if currently assigned
          if (isAssigned) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    times.clear();
                  });
                },
                icon: const Icon(
                  Icons.close,
                  size: 12,
                  color: AppColors.textHint,
                ),
                label: const Text(
                  'Unassign Screen',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Helper Label
// ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
