import 'package:flutter/material.dart';
import 'layout/dashboard_layout.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CineAdminApp());
}

class CineAdminApp extends StatelessWidget {
  const CineAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineAdmin Premium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardLayout(),
    );
  }
}