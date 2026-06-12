import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/models/theater_model.dart';

/// ============================================================
/// Showtime Card — Theater card with name, type badge,
/// and selectable time slot chips
/// ============================================================

class ShowtimeCard extends StatefulWidget {
  final TheaterModel theater;
  final int initialSelectedIndex;

  const ShowtimeCard({
    super.key,
    required this.theater,
    this.initialSelectedIndex = -1,
  });

  @override
  State<ShowtimeCard> createState() => _ShowtimeCardState();
}

class _ShowtimeCardState extends State<ShowtimeCard> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Theater name + type badge row ──
          Row(
            children: [
              // Red dot indicator
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Theater name
              Expanded(
                child: Text(
                  widget.theater.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Type badge (Standard)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  widget.theater.type,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Time slot chips ──
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: List.generate(widget.theater.showtimes.length, (index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: AppSizes.showtimeChipHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.chipOutline,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.theater.showtimes[index],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
