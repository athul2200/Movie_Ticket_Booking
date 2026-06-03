import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';

/// ============================================================
/// Rating Badge — Score display card for Rotten, IMDB,
/// Metacritic, Fan Favorite sections
/// ============================================================

class RatingBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const RatingBadge({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.ratingBadgeHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Value or Icon ──
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: iconColor ?? AppColors.primary,
              )
            else
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            const SizedBox(height: AppSpacing.xs),

            // ── Label ──
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
