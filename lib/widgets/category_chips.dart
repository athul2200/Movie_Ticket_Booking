import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';

/// ============================================================
/// Category Chips — Horizontal scrollable genre filter chips
/// Selected chip: red bg + white text
/// Unselected chip: white bg + dark text + gray border
/// ============================================================

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.chipSelectedBg
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.chipSelectedBg
                      : AppColors.chipOutline,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
