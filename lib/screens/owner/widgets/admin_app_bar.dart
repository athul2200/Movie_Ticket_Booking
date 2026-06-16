import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool noLeading;

  const AdminAppBar({
    super.key,
    this.title = 'Movix',
    this.showBackButton = false,
    this.noLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    if (noLeading) {
      leadingWidget = const SizedBox.shrink();
    } else if (showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      );
    } else {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      );
    }

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: noLeading ? null : leadingWidget,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
