import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/services/network_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _networkService.checkConnection();
    
    if (!mounted) return;

    if (hasConnection) {
      // Proceed to the app
      Navigator.pushReplacementNamed(context, AppRouter.roleSelection);
    } else {
      // Go to No Internet screen
      Navigator.pushReplacementNamed(context, AppRouter.noInternet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple text logo for splash, could be replaced with an image logo
            Text(
              'MOVIX',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 20),
            Text(
              'Checking Connection...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
