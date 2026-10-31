import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/services/auth_service.dart';
import 'package:booking/services/network_service.dart';

// ============================================================
// Splash Screen — App startup gate
//
// Checks in order:
//   1. Network connectivity (existing behaviour, unchanged)
//      → Offline: navigate to /no-internet
//      → Online: continue
//
//   2. Firebase Auth current user
//      → No session: navigate to /login
//      → Session exists: continue
//
//   3. Firestore profile fetch + role resolution
//      → user  + isActive → /home
//      → owner + isActive + theater → /owner (with theater argument)
//      → admin + isActive → /admin
//      → Any invalid state → signOut() + /login + error SnackBar
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    // Small delay so the splash logo is visible before async work starts.
    Future.delayed(const Duration(milliseconds: 400), _checkInitialState);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Startup gate ─────────────────────────────────────────────────────────

  Future<void> _checkInitialState() async {
    // Step 1 — Network check (existing behaviour preserved)
    final hasConnection = await _networkService.checkConnection();
    if (!mounted) return;

    if (!hasConnection) {
      Navigator.pushReplacementNamed(context, AppRouter.noInternet);
      return;
    }

    // Step 2 — Firebase session
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
      return;
    }

    // Step 3 — Firestore profile + role resolution
    try {
      final profile = await AuthService.instance.fetchProfile(currentUser.uid);
      if (!mounted) return;

      switch (profile.role) {
        case UserRole.user:
          Navigator.pushReplacementNamed(context, AppRouter.home);
        case UserRole.owner:
          Navigator.pushReplacementNamed(
            context, AppRouter.owner,
            arguments: profile.assignedTheater,
          );
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, AppRouter.admin);
      }
    } catch (e) {
      // Any fetch failure or invalid profile → sign out and go to login.
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.login);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AuthAppException
              ? e.userMessage
              : 'Unable to verify your account. Please sign in again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.background,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MOVIX',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
