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
  String _selectedMovie = 'Oppenheimer';
  String _selectedScreen = 'Screen 01 (IMAX)';
  final TextEditingController _dateCtrl = TextEditingController(
    text: '11/24/2023',
  );

  final List<String> _timeSlots = [
    '10:00 AM',
    '01:30 PM',
    '04:45 PM',
    '08:00 PM',
    '11:15 PM',
    '02:00 AM',
  ];
  String _selectedTime = '04:45 PM';

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AdminAppBar(),
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
                        value: 'Oppenheimer',
                        child: Text('Oppenheimer'),
                      ),
                      DropdownMenuItem(value: 'Barbie', child: Text('Barbie')),
                      DropdownMenuItem(value: 'Dune 2', child: Text('Dune 2')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMovie = val);
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
                        value: 'Screen 01 (IMAX)',
                        child: Text('Screen 01 (IMAX)'),
                      ),
                      DropdownMenuItem(
                        value: 'Screen 02',
                        child: Text('Screen 02'),
                      ),
                      DropdownMenuItem(
                        value: 'Screen 03',
                        child: Text('Screen 03'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedScreen = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Date', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  AdminTextField(
                    controller: _dateCtrl,
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Available Time Slots',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _timeSlots.map((time) {
                      bool isSelected = time == _selectedTime;
                      bool isOccupied = time == '02:00 AM'; // Mock occupied

                      return GestureDetector(
                        onTap: isOccupied
                            ? null
                            : () {
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                        child: Container(
                          width:
                              (MediaQuery.of(context).size.width -
                                  (AppSpacing.lg * 4) -
                                  AppSpacing.sm * 2) /
                              3,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
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
                                  ? AppColors.surface
                                  : AppColors.divider,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? AppColors.textWhite
                                        : isOccupied
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AdminButton(
                    text: 'Confirm Schedule',
                    icon: Icons.event_available,
                    onPressed: () {},
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

            // Timelines
            _buildTimelineRow(
              'SCR 01',
              'Oppenheimer',
              '10:00 - 13:00',
              0.3,
              0.4,
              true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTimelineRow(
              'SCR 02',
              'Barbie',
              '11:15 - 13:15',
              0.5,
              0.3,
              false,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTimelineRow(
              'SCR 03',
              'Dune 2',
              '09:00 - 11:45',
              0.1,
              0.35,
              false,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Warning Alert ──
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'The selected time slot (04:45 PM)\nonly leaves 15 minutes for cleaning\nafter the previous show.\nRecommended buffer: 30 mins.',
                          style: Theme.of(context).textTheme.bodyMedium
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
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
                  left: MediaQuery.of(context).size.width * 0.6 * startPct,
                  width: MediaQuery.of(context).size.width * 0.6 * widthPct,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          movieTitle,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
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
