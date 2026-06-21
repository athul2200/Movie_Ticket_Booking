import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/screens/owner/widgets/admin_app_bar.dart';
import 'package:booking/screens/owner/widgets/admin_dropdown.dart';
import 'package:booking/screens/owner/widgets/admin_text_field.dart';
import 'package:booking/screens/owner/widgets/admin_button.dart';

class OwnerScheduleScreen extends StatefulWidget {
  const OwnerScheduleScreen({super.key});

  @override
  State<OwnerScheduleScreen> createState() => _OwnerScheduleScreenState();
}

class _OwnerScheduleScreenState extends State<OwnerScheduleScreen> {
  String _selectedMovie = 'Drishyam 3';
  String _selectedTheater = 'Kairali';
  String _selectedScreen = 'Screen 01';

  late final TextEditingController _dateCtrl;

  // Occupied slots per screen (mock data — per-screen)
  final Map<String, Set<String>> _occupiedSlots = {
    'Screen 01': {'10:15 PM'},
    'Screen 02': {'10:40 AM'},
  };

  // Schedule preview state — updates when user confirms
  final Map<String, Map<String, String>> _schedulePreview = {
    'Screen 01': {'movie': 'Drishyam 3', 'time': '10:00 AM - 01:00 PM'},
    'Screen 02': {'movie': 'Michael', 'time': '11:00 AM - 02:00 PM'},
  };

  static const Map<String, Map<String, List<String>>> _theaterData = {
    'Kairali': {
      'Screen 01': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM','09:30 PM'],
      'Screen 02': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
    },
    'Nila': {
      'Screen 01': ['11:00 AM', '02:30 PM', '05:30 PM', '08:30 PM', '11:20 PM'],
      'Screen 02': ['10:00 AM', '01:30 PM', '04:30 PM', '07:30 PM','09:30 PM'],
    },
  };

  List<String> get _timeSlots {
    return _theaterData[_selectedTheater]?[_selectedScreen] ?? [];
  }

  final Set<String> _selectedTimes = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl = TextEditingController(
      text:
          '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}',
    );
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  bool _isOccupied(String time) {
    return (_occupiedSlots[_selectedScreen] ?? {}).contains(time);
  }

  /// Returns true if any selected slot is adjacent to an occupied slot on the same screen
  bool get _hasOverlapRisk {
    final occupiedTimes = _occupiedSlots[_selectedScreen] ?? {};
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
    final occupiedTimes = _occupiedSlots[_selectedScreen] ?? {};
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
      appBar: const AdminAppBar(showBackButton: true),
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
                    items: const [
                      DropdownMenuItem(
                        value: 'Drishyam 3',
                        child: Text('Drishyam 3'),
                      ),
                      DropdownMenuItem(
                        value: 'Michael',
                        child: Text('Michael'),
                      ),
                      DropdownMenuItem(
                        value: 'Kattalan',
                        child: Text('Kattalan'),
                      ),
                      DropdownMenuItem(
                        value: 'Karuppu',
                        child: Text('Karuppu'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMovie = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Select Theater',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AdminDropdown<String>(
                    value: _selectedTheater,
                    prefixIcon: const Icon(
                      Icons.location_city_outlined,
                      color: AppColors.textSecondary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Kairali',
                        child: Text('Kairali'),
                      ),
                      DropdownMenuItem(
                        value: 'Nila',
                        child: Text('Nila'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedTheater = val;
                          _selectedTimes.clear();
                        });
                      }
                    },
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
                                  if (isSelected) {
                                    // Don't allow deselecting the last one
                                    if (_selectedTimes.length > 1) {
                                      _selectedTimes.remove(time);
                                    }
                                  } else {
                                    _selectedTimes.add(time);
                                  }
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                                  ? AppColors.surface
                                  : AppColors.divider,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
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
                                      fontWeight: isSelected
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
                            // Update the preview and mark all slots as occupied
                            setState(() {
                              _schedulePreview[_selectedScreen] = {
                                'movie': _selectedMovie,
                                'time': sortedTimes.first,
                              };
                              _occupiedSlots
                                  .putIfAbsent(_selectedScreen, () => {})
                                  .addAll(_selectedTimes);
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
              _schedulePreview['Screen 01']?['movie'] ?? 'Drishyam 3',
              _schedulePreview['Screen 01']?['time'] ?? '10:00 AM - 01:00 PM',
              0.3,
              0.4,
              _selectedScreen == 'Screen 01',
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTimelineRow(
              'SCR 02',
              _schedulePreview['Screen 02']?['movie'] ?? 'Michael',
              _schedulePreview['Screen 02']?['time'] ?? '11:15 AM - 01:15 PM',
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
