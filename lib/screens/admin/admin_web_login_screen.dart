import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:booking/services/auth_service.dart';
// Uses the Admin red/white theme — NOT the mobile gold/black theme.
import 'package:booking/theme/app_theme.dart' as admin_theme;

// ============================================================
// Admin Web Login Screen — Shown by AdminAuthGate when no valid
// admin session exists on the Netlify-hosted web app.
//
// Uses the existing Admin colour palette (AppTheme.primaryRed, white
// backgrounds) to match the AdminDashboard aesthetic.
//
// On successful login:
//   1. Firebase Auth verifies credentials
//   2. Firestore profile checked for role == 'admin' && isActive
//   3. onLoginSuccess() is called → AdminAuthGate rebuilds with dashboard
// ============================================================

class AdminWebLoginScreen extends StatefulWidget {
  /// Callback invoked by AdminAuthGate.checkAuth after successful sign-in.
  final VoidCallback onLoginSuccess;

  const AdminWebLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<AdminWebLoginScreen> createState() => _AdminWebLoginScreenState();
}

class _AdminWebLoginScreenState extends State<AdminWebLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Login logic ────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Verify the Firestore profile to confirm admin role + isActive.
      final profile = await AuthService.instance.fetchProfile(
        credential.user!.uid,
      );

      if (profile.role != UserRole.admin || !profile.isActive) {
        // Signed in but not an admin — sign out and deny.
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _errorMessage =
                'Access denied. This dashboard is restricted to administrators.';
          });
        }
        return;
      }

      // Admin verified — notify AdminAuthGate to rebuild with dashboard.
      widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Admin Firebase Authentication sign-in failed: '
        'code=${e.code}, message=${e.message ?? ''}',
      );
      if (mounted) {
        setState(
          () => _errorMessage = AuthService.mapFirebaseAuthError(e.code),
        );
      }
    } on AuthAppException catch (e) {
      await FirebaseAuth.instance.signOut();
      if (mounted) setState(() => _errorMessage = e.userMessage);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = 'An unexpected error occurred. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: admin_theme.AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              margin: const EdgeInsets.all(24),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: admin_theme.AppTheme.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Brand header ──
                      Row(
                        children: [
                          const Icon(
                            Icons.movie_creation_rounded,
                            color: admin_theme.AppTheme.primaryRed,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Movix',
                            style: TextStyle(
                              color: admin_theme.AppTheme.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: admin_theme.AppTheme.primaryRed.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: admin_theme.AppTheme.primaryRed,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Sign in to Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: admin_theme.AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Access to this dashboard is restricted to authorised administrators.',
                        style: TextStyle(
                          color: admin_theme.AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Error banner ──
                      if (_errorMessage.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Email field ──
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: admin_theme.AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'admin@example.com',
                          hintStyle: const TextStyle(
                            color: admin_theme.AppTheme.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.primaryRed,
                              width: 1.5,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Password field ──
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: admin_theme.AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            color: admin_theme.AppTheme.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: admin_theme.AppTheme.primaryRed,
                              width: 1.5,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: admin_theme.AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Sign In button ──
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: admin_theme.AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: admin_theme
                                .AppTheme
                                .primaryRed
                                .withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
