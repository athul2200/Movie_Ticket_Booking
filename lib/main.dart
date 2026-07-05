import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/widgets/network_overlay.dart';

/// ============================================================
/// Main Entry Point — Movix Movie Booking App
/// ============================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) {
        return NetworkOverlay(child: child!);
      },
    );
  }
}
