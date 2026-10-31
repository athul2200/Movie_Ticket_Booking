import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booking/services/auth_service.dart';
import 'package:booking/screens/admin/admin_dashboard.dart';
import 'package:booking/screens/admin/admin_web_login_screen.dart';

// ============================================================
// Admin Auth Gate — Entry widget for the Admin web app.
//
// Replaces the direct AdminDashboard() in AdminApp.home.
// Four states:
//   loading   → CircularProgressIndicator
//   login     → AdminWebLoginScreen (uses Admin red/white theme)
//   denied    → _AccessDeniedScreen (non-admin session)
//   dashboard → AdminDashboard (unchanged UI, receives onLogout callback)
//
// Security note:
//   This Flutter auth gate (Layer 1) prevents the dashboard from rendering
//   without a valid admin session. The Netlify hosting URL remains publicly
//   reachable (Layer 0 — requires paid Netlify feature or reverse proxy to
//   restrict). Firestore Security Rules (Layer 2) are the authoritative
//   data-protection layer regardless of how the UI is reached.
// ============================================================

enum _AuthGateState { loading, login, denied, dashboard }

class AdminAuthGate extends StatefulWidget {
  const AdminAuthGate({super.key});

  @override
  State<AdminAuthGate> createState() => _AdminAuthGateState();
}

class _AdminAuthGateState extends State<AdminAuthGate> {
  _AuthGateState _state = _AuthGateState.loading;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// Checks the current Firebase session and Firestore profile.
  /// Called on init and again after a successful web login (via onLoginSuccess)
  /// or after web logout (rebuilds to show login screen).
  Future<void> _checkAuth() async {
    setState(() => _state = _AuthGateState.loading);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _state = _AuthGateState.login);
      return;
    }

    try {
      final profile = await AuthService.instance.fetchProfile(user.uid);
      if (!mounted) return;

      if (profile.role == UserRole.admin && profile.isActive) {
        setState(() => _state = _AuthGateState.dashboard);
      } else {
        // Non-admin or inactive account — sign out and deny.
        await FirebaseAuth.instance.signOut();
        setState(() => _state = _AuthGateState.denied);
      }
    } catch (e, stackTrace) {
  debugPrint('ADMIN AUTH GATE ERROR: $e');
  debugPrintStack(stackTrace: stackTrace);

  await FirebaseAuth.instance.signOut();

  if (mounted) {
    setState(() => _state = _AuthGateState.login);
  }
}
  }

  /// Called by AdminDashboard.onLogout (via _AdminHeader back/logout button).
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    AuthService.instance.logout(); // also clears cachedProfile
    // Rebuild — _checkAuth will find no current user and show login.
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _AuthGateState.loading   => const _LoadingScreen(),
      _AuthGateState.login     => AdminWebLoginScreen(onLoginSuccess: _checkAuth),
      _AuthGateState.denied    => _AccessDeniedScreen(onRetry: _checkAuth),
      _AuthGateState.dashboard => AdminDashboard(onLogout: _handleLogout),
    };
  }
}

// ── Internal loading screen ───────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD32F2F)),
            SizedBox(height: 20),
            Text(
              'Verifying session...',
              style: TextStyle(color: Color(0xFF616161), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Access denied screen (non-admin account) ──────────────────────────────────
class _AccessDeniedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _AccessDeniedScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Color(0xFFD32F2F), size: 64),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your account does not have admin privileges.\n'
                'Contact the system administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF616161), height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
