import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title - Coming Soon',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
