import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/widgets/network_overlay.dart';
import 'package:booking/data/mock_data.dart';

/// ============================================================
/// Main Entry Point — Movix Movie Booking App
/// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockData.loadData();
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
