import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/services/auth_service.dart';
import 'package:booking/screens/auth/auth_widgets.dart';

// ============================================================
// Login Screen — Entry point for all users (User, Owner, Admin).
// Back button exits the app; Login is always the bottom of the stack.
//
// Features:
//   - Email / Password sign-in
//   - "Remember Me" saves email to SharedPreferences (email pre-fill only;
//     Firebase session persists independently of this checkbox)
//   - Forgot Password sheet (ForgotPasswordSheet from auth_widgets.dart)
//   - Role-based navigation after successful login (via AuthService)
//   - Animated error banner
//   - Loading state disables the button and shows a spinner
// ============================================================

const String _kRememberEmailKey = 'auth_remember_email';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberMe = false;
  bool _isLoading = false;
  String _errorMessage = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kRememberEmailKey);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = saved;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveOrClearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_kRememberEmailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_kRememberEmailKey);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Login logic ────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await _saveOrClearEmail();

    try {
      final profile = await AuthService.instance.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Navigate based on role — stack cleared so back press exits the app.
      switch (profile.role) {
        case UserRole.user:
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.home,
            (r) => false,
          );
        case UserRole.owner:
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.owner,
            (r) => false,
            arguments: profile.assignedTheater,
          );
        case UserRole.admin:
          await _openAdminDashboardExternally();
      }
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.mapFirebaseAuthError(e.code));
    } on AccountDisabledException catch (e) {
      _showError(e.userMessage);
    } on ProfileNotFoundException catch (e) {
      _showError(e.userMessage);
    } on NoTheaterAssignedException catch (e) {
      _showError(e.userMessage);
    } on InvalidRoleException catch (e) {
      _showError(e.userMessage);
    } on ProfileFetchException catch (e) {
      _showError(e.userMessage);
    } on AuthAppException catch (e) {
      _showError(e.userMessage);
    } catch (_) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) setState(() => _errorMessage = msg);
  }

  Future<void> _openAdminDashboardExternally() async {
    var launched = false;
    try {
      launched = await launchUrl(
        Uri.parse('https://movies-admin.netlify.app/'),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('Admin dashboard browser launch failed: $error');
    }

    // The Android app should remain on its login screen after opening the web
    // dashboard, with no cached Admin session or blank Admin route underneath.
    try {
      await AuthService.instance.logout();
    } catch (error) {
      debugPrint('Admin session cleanup failed (${error.runtimeType}).');
    }

    if (!mounted) return;
    if (!launched) {
      _showError(
        'Could not open the Admin Dashboard in your browser. '
        'Please open https://movies-admin.netlify.app/ manually.',
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Admin Dashboard opened in your browser. Sign in there to continue.',
        ),
      ),
    );
  }

  void _openForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ForgotPasswordSheet(initialEmail: _emailController.text.trim()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Logo / Brand ──
                  Center(child: _buildLogo()),
                  const SizedBox(height: 40),

                  // ── Heading ──
                  Text(
                    'Welcome back',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue to Movix',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Error banner ──
                  AuthErrorBanner(message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                  // ── Email field ──
                  MovixTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    nextFocusNode: _passwordFocus,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required.';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Password field ──
                  MovixPasswordField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Remember Me + Forgot Password row ──
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primary,
                          checkColor: AppColors.textBlack,
                          side: const BorderSide(color: AppColors.inputBorder),
                          onChanged: _isLoading
                              ? null
                              : (v) => setState(() => _rememberMe = v ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Me',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _openForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Login button ──
                  MovixPrimaryButton(
                    label: 'Sign In',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // ── Sign-Up link ──
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => Navigator.pushNamed(
                                  context,
                                  AppRouter.signup,
                                ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo widget ───────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        // Gold ring with M initial
        Container(
          width: 80,
          height: 80,
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
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MOVIX',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Movie Ticket Booking',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.placeholder,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
