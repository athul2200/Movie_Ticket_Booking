import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/constants/app_constants.dart';
import 'package:booking/navigation/app_router.dart';
import 'package:booking/services/auth_service.dart';
import 'package:booking/screens/auth/auth_widgets.dart';

// ============================================================
// Sign-Up Screen — New user self-registration.
// Key constraints enforced here:
//   - role is hardcoded to 'user' — never from user input
//   - assignedTheater is hardcoded to null
//   - AuthService never accepts a role from user input
// ============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;
  String _errorMessage = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Validation helpers ─────────────────────────────────────────────────────

  String? _validateName(String? v) {
    if (v == null || v.trim().length < 2) {
      return 'Full name must be at least 2 characters.';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!pattern.hasMatch(v.trim())) return 'Enter a valid email address.';
    return null;
  }

  String? _validateMobile(String? v) {
    if (v == null || v.trim().isEmpty) return 'Mobile number is required.';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return 'Enter a valid 10-digit mobile number.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 8) return 'Password must be at least 8 characters.';
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  // ── Registration logic ─────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await AuthService.instance.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _mobileController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // After registration the user role is always 'user' → home.
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (r) => false);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Registration FirebaseAuthException code=${e.code}, '
        'message=${e.message ?? ''}',
      );
      _showError(AuthService.mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      debugPrint(
        'Registration ${e.plugin} FirebaseException code=${e.code}, '
        'message=${e.message ?? ''}',
      );
      _showError(AuthService.mapFirebaseDatabaseError(e.code));
    } on AuthAppException catch (e) {
      _showError(e.userMessage);
    } catch (e, stackTrace) {
      debugPrint(
        'Registration unexpected exception (${e.runtimeType}): '
        '$e\n$stackTrace',
      );
      _showError(
        'Registration failed. Please check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) setState(() => _errorMessage = msg);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Movix',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to book movie tickets.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Error banner ──
                  AuthErrorBanner(message: _errorMessage),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                  // ── Full Name ──
                  MovixTextField(
                    label: 'Full Name',
                    hint: 'Alexander Sterling',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    focusNode: _nameFocus,
                    nextFocusNode: _emailFocus,
                    enabled: !_isLoading,
                    validator: _validateName,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Email ──
                  MovixTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    nextFocusNode: _mobileFocus,
                    enabled: !_isLoading,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Mobile Number ──
                  MovixTextField(
                    label: 'Mobile Number',
                    hint: '9876543210',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    focusNode: _mobileFocus,
                    nextFocusNode: _passwordFocus,
                    enabled: !_isLoading,
                    validator: _validateMobile,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Password ──
                  MovixPasswordField(
                    label: 'Password',
                    hint: 'Min 8 chars, 1 digit',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    nextFocusNode: _confirmFocus,
                    enabled: !_isLoading,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Confirm Password ──
                  MovixPasswordField(
                    label: 'Confirm Password',
                    hint: '••••••••',
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    validator: _validateConfirm,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Terms notice ──
                  Text(
                    'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ── Register button ──
                  MovixPrimaryButton(
                    label: 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    icon: _isLoading ? null : Icons.person_add_outlined,
                  ),
                  const SizedBox(height: 24),

                  // ── Login link ──
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
                            'Sign In',
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
