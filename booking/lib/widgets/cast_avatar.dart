import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/models/cast_model.dart';

/// ============================================================
/// Cast Avatar — Circular avatar with name and role below
/// Used in the Cast & Crew section on the detail screen
/// ============================================================

class CastAvatar extends StatelessWidget {
  final CastModel cast;

  const CastAvatar({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Circular avatar ──
          Container(
            width: AppSizes.castAvatarSize,
            height: AppSizes.castAvatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.divider,
                width: 2,
              ),
              image: DecorationImage(
                image: NetworkImage(cast.imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
            child: ClipOval(
              child: Image.network(
                cast.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Name ──
          Text(
            cast.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // ── Role ──
          Text(
            cast.role,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
