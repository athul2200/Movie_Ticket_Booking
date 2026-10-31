import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ============================================================
// Auth Service — Firebase Authentication + Firestore profile
// Implements Plan v6 strict role resolution:
//   user  → /home
//   owner → /owner (with non-empty assignedTheater)
//   admin → /admin
// Any missing/invalid field → signOut + denial
// ============================================================

// ── Global navigator key ──────────────────────────────────────────────────────
// Used by AuthService for app-resume revalidation navigation without context.
// Passed to MaterialApp.navigatorKey in main.dart.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// ── Role enum ─────────────────────────────────────────────────────────────────
enum UserRole { user, owner, admin }

enum ProfileActiveState { active, inactive, invalid }

ProfileActiveState classifyProfileActiveState(Object? value) {
  if (value == true) return ProfileActiveState.active;
  if (value == false) return ProfileActiveState.inactive;
  return ProfileActiveState.invalid;
}

enum ProfileRoleIssue {
  missingRole,
  unsupportedRole,
  conflictingUserClaim,
  missingAdminClaim,
  missingOwnerClaim,
  missingOrUnsupportedTheater,
  theaterClaimMismatch,
}

class ProfileRoleResolution {
  final UserRole? role;
  final String? assignedTheater;
  final ProfileRoleIssue? issue;

  const ProfileRoleResolution._({this.role, this.assignedTheater, this.issue});

  const ProfileRoleResolution.valid(UserRole role, {String? assignedTheater})
    : this._(role: role, assignedTheater: assignedTheater);

  const ProfileRoleResolution.invalid(ProfileRoleIssue issue)
    : this._(issue: issue);

  bool get isValid => issue == null;
}

/// Resolves authorization using the protected profile role plus trusted Auth
/// claims. Optional profile display fields are intentionally not role gates.
ProfileRoleResolution resolveProfileRole(
  Map<String, dynamic> profile,
  Map<String, dynamic> claims,
) {
  final roleValue = profile['role'];
  if (roleValue is! String) {
    return const ProfileRoleResolution.invalid(ProfileRoleIssue.missingRole);
  }

  final claimedRole = claims['movixRole'];
  switch (roleValue) {
    case 'user':
      if (claimedRole != null && claimedRole != 'user') {
        return const ProfileRoleResolution.invalid(
          ProfileRoleIssue.conflictingUserClaim,
        );
      }
      return const ProfileRoleResolution.valid(UserRole.user);
    case 'admin':
      if (claimedRole != 'admin') {
        return const ProfileRoleResolution.invalid(
          ProfileRoleIssue.missingAdminClaim,
        );
      }
      return const ProfileRoleResolution.valid(UserRole.admin);
    case 'owner':
      if (claimedRole != 'owner') {
        return const ProfileRoleResolution.invalid(
          ProfileRoleIssue.missingOwnerClaim,
        );
      }
      final theater = profile['assignedTheater'];
      if (theater is! String || !movixTheaterIds.contains(theater)) {
        return const ProfileRoleResolution.invalid(
          ProfileRoleIssue.missingOrUnsupportedTheater,
        );
      }
      if (claims['theaterId'] != theater) {
        return const ProfileRoleResolution.invalid(
          ProfileRoleIssue.theaterClaimMismatch,
        );
      }
      return ProfileRoleResolution.valid(
        UserRole.owner,
        assignedTheater: theater,
      );
    default:
      return const ProfileRoleResolution.invalid(
        ProfileRoleIssue.unsupportedRole,
      );
  }
}

/// Canonical theater keys already used by MockData and the Owner module.
const Set<String> movixTheaterIds = {'Kairali', 'Nila'};

// ── UserProfile ───────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final UserRole role;
  final String? assignedTheater; // non-null only for role == owner
  final bool isActive;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    this.assignedTheater,
  });
}

// ── Custom exception hierarchy ────────────────────────────────────────────────
// Each exception carries a user-facing message shown directly in the UI.
abstract class AuthAppException implements Exception {
  final String userMessage;
  const AuthAppException(this.userMessage);
  @override
  String toString() => userMessage;
}

class ProfileNotFoundException extends AuthAppException {
  const ProfileNotFoundException()
    : super('Account profile not found. Please contact support.');
}

class AccountDisabledException extends AuthAppException {
  const AccountDisabledException()
    : super('This Movix profile is inactive. Contact the administrator.');
}

class InvalidProfileException extends AuthAppException {
  const InvalidProfileException()
    : super(
        'The account profile is incomplete: isActive must be a Boolean true value. Please contact support.',
      );
}

class InvalidRoleException extends AuthAppException {
  const InvalidRoleException()
    : super('Account configuration error. Please contact support.');
}

class NoTheaterAssignedException extends AuthAppException {
  const NoTheaterAssignedException()
    : super(
        'No theater has been assigned to this account. Please contact support.',
      );
}

class ProfileFetchException extends AuthAppException {
  const ProfileFetchException()
    : super('Unable to verify your account. Please try again.');
}

// ── AuthService ───────────────────────────────────────────────────────────────
class AuthService with WidgetsBindingObserver {
  // Singleton
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Last successfully fetched profile; cleared on logout or any denial.
  UserProfile? _cachedProfile;
  UserProfile? get cachedProfile => _cachedProfile;

  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  // ── Lifecycle observer ───────────────────────────────────────────────────

  /// Call once after Firebase.initializeApp() in main().
  void startObserving() => WidgetsBinding.instance.addObserver(this);

  /// Called automatically during logout.
  void _stopObserving() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isLoggedIn) {
      _revalidateOnResume();
    }
  }

  /// Re-fetches the Firestore profile when the app returns to the foreground.
  /// If the profile is invalid (disabled, deleted, etc.), signs out and
  /// navigates to /login using the global navigator key.
  Future<void> _revalidateOnResume() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final profile = await fetchProfile(user.uid);
      _cachedProfile = profile;
    } catch (_) {
      _cachedProfile = null;
      await _auth.signOut();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (r) => false,
      );
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  /// Returns the validated [UserProfile].
  /// Throws [FirebaseAuthException] for auth errors,
  /// or an [AuthAppException] subclass for profile/role errors.
  Future<UserProfile> login(String email, String password) async {
    late final UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase Authentication sign-in failed: '
        'code=${e.code}, message=${e.message ?? ''}',
      );
      rethrow;
    }
    try {
      final profile = await fetchProfile(credential.user!.uid);
      _cachedProfile = profile;
      return profile;
    } catch (_) {
      _cachedProfile = null;
      await _auth.signOut();
      rethrow;
    }
  }

  /// Registers a new user account.
  /// - role is hardcoded to 'user' — never sourced from input.
  /// - If Firestore write fails after Auth creation, the Auth account is
  ///   deleted to prevent orphaned accounts.
  Future<UserProfile> registerUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    UserCredential? credential;
    var registrationStage = 'Firebase Authentication account creation';
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      registrationStage = 'Firebase Authentication display-name update';
      await credential.user!.updateDisplayName(name.trim());

      registrationStage = 'Firestore user-profile write';
      await _db.collection('users').doc(credential.user!.uid).set({
        'role': 'user',
        'email': email.trim(),
        'displayName': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'assignedTheater': null,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      registrationStage = 'Firestore user-profile verification';
      final profile = await fetchProfile(credential.user!.uid);
      _cachedProfile = profile;
      return profile;
    } catch (e, stackTrace) {
      final profileWriteContext =
          registrationStage == 'Firestore user-profile write'
          ? ' path=/users/{auth.uid}, '
                'authenticatedUidMatchesDocument=${credential != null && _auth.currentUser?.uid == credential.user?.uid}'
          : '';
      if (e is FirebaseAuthException) {
        debugPrint(
          'Registration failed during $registrationStage$profileWriteContext: '
          'FirebaseAuthException code=${e.code}, message=${e.message ?? ''}',
        );
      } else if (e is FirebaseException) {
        debugPrint(
          'Registration failed during $registrationStage$profileWriteContext: '
          '${e.plugin} FirebaseException code=${e.code}, '
          'message=${e.message ?? ''}',
        );
      } else {
        debugPrint(
          'Registration failed during $registrationStage '
          '(${e.runtimeType}): $e\n$stackTrace',
        );
      }
      if (e is! FirebaseAuthException && credential != null) {
        try {
          await credential.user?.delete();
        } catch (cleanupError, cleanupStackTrace) {
          debugPrint(
            'Registration cleanup failed after $registrationStage '
            '(${cleanupError.runtimeType}): $cleanupError\n'
            '$cleanupStackTrace',
          );
        }
      }
      if (e is FirebaseAuthException &&
          e.code == 'email-already-in-use' &&
          credential == null) {
        return _recoverOrphanedRegistration(
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          duplicateAccountError: e,
        );
      }
      rethrow;
    }
  }

  /// Repairs an Auth account left behind if profile rollback failed earlier.
  /// Existing profiles are never overwritten, and recovered profiles always
  /// receive the ordinary `user` role.
  Future<UserProfile> _recoverOrphanedRegistration({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required FirebaseAuthException duplicateAccountError,
  }) async {
    late final User user;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      user = credential.user!;
    } on FirebaseAuthException {
      throw duplicateAccountError;
    }

    try {
      final profileRef = _db.collection('users').doc(user.uid);
      final existingProfile = await profileRef.get();
      if (existingProfile.exists) {
        await _auth.signOut();
        throw duplicateAccountError;
      }

      await user.updateDisplayName(name.trim());
      await profileRef.set({
        'role': 'user',
        'email': user.email ?? email.trim(),
        'displayName': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        'assignedTheater': null,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      final profile = await fetchProfile(user.uid);
      _cachedProfile = profile;
      return profile;
    } catch (e, stackTrace) {
      if (_auth.currentUser?.uid == user.uid) {
        try {
          await _auth.signOut();
        } catch (signOutError) {
          debugPrint(
            'Orphaned registration recovery sign-out failed '
            '(${signOutError.runtimeType}).',
          );
        }
      }
      if (e is FirebaseException) {
        debugPrint(
          'Orphaned profile recovery failed: ${e.plugin} '
          'code=${e.code}, message=${e.message ?? ''}',
        );
      } else if (e is! FirebaseAuthException) {
        debugPrint(
          'Orphaned profile recovery failed '
          '(${e.runtimeType}): $e\n$stackTrace',
        );
      }
      rethrow;
    }
  }

  /// Fetches and validates the Firestore profile for [uid].
  /// Throws an [AuthAppException] subclass for every invalid state.
  /// Never defaults to a fallback role.
  Future<UserProfile> fetchProfile(String uid) async {
    late DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
    } on FirebaseException catch (e, stackTrace) {
      debugPrint(
        'Firestore user-profile read failed: ${e.plugin} '
        'code=${e.code}, message=${e.message ?? ''}\n$stackTrace',
      );
      throw const ProfileFetchException();
    } catch (e, stackTrace) {
      debugPrint(
        'User-profile read failed (${e.runtimeType}): $e\n$stackTrace',
      );
      throw const ProfileFetchException();
    }

    if (!doc.exists || doc.data() == null) {
      debugPrint(
        'Profile authorization failed: uid=$uid, reason=Firestore profile missing at /users/$uid.',
      );
      throw const ProfileNotFoundException();
    }

    final data = doc.data()!;

    final signedInUser = _auth.currentUser;
    if (signedInUser == null || signedInUser.uid != uid) {
      debugPrint(
        'Profile authorization failed: requestedUid=$uid, '
        'reason=current Firebase Auth UID is missing or does not match.',
      );
      throw const InvalidRoleException();
    }
    final Map<String, dynamic> claims;
    try {
      // Force refresh so newly provisioned or revoked custom claims take
      // effect before role-based navigation.
      claims = (await signedInUser.getIdTokenResult(true)).claims ?? {};
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        'Firebase role-claim read failed: code=${e.code}, '
        'message=${e.message ?? ''}\n$stackTrace',
      );
      throw const ProfileFetchException();
    } catch (e, stackTrace) {
      debugPrint(
        'Firebase role-claim read failed: exception=${e.runtimeType}, '
        'message=$e\n$stackTrace',
      );
      throw const ProfileFetchException();
    }

    // Only an explicit false profile flag means app-level deactivation.
    // Missing or malformed data is a profile configuration error, not a
    // disabled account and not Firebase Authentication's user-disabled code.
    final profileActiveState = classifyProfileActiveState(data['isActive']);
    if (profileActiveState == ProfileActiveState.inactive) {
      debugPrint(
        'Profile authorization denied: uid=$uid, reason=Firestore /users/$uid '
        'has isActive=false; Firebase Auth sign-in succeeded.',
      );
      throw const AccountDisabledException();
    }
    if (profileActiveState == ProfileActiveState.invalid) {
      debugPrint(
        'Profile authorization failed: uid=$uid, '
        'reason=Firestore isActive missing or invalid '
        '(type=${data['isActive']?.runtimeType ?? 'null'}).',
      );
      throw const InvalidProfileException();
    }
    const isActive = true;

    // Role requirements differ intentionally: Admin does not need Owner or
    // regular-user profile fields; Owner needs an assigned theater matching
    // the trusted token claim; regular users may not carry privileged claims.
    final resolution = resolveProfileRole(data, claims);
    if (!resolution.isValid) {
      debugPrint(
        'Profile authorization failed: uid=$uid, '
        'reason=role validation issue ${resolution.issue}; '
        'profileRole=${data['role']}, claimRole=${claims['movixRole']}, '
        'assignedTheater=${data['assignedTheater']}, '
        'claimTheaterId=${claims['theaterId']}.',
      );
      if (resolution.issue == ProfileRoleIssue.missingOrUnsupportedTheater) {
        throw const NoTheaterAssignedException();
      }
      throw const InvalidRoleException();
    }
    final role = resolution.role!;
    final assignedTheater = resolution.assignedTheater;

    return UserProfile(
      uid: uid,
      email: (data['email'] as String?) ?? '',
      displayName: (data['displayName'] as String?) ?? '',
      phoneNumber: (data['phoneNumber'] as String?) ?? '',
      role: role,
      isActive: isActive,
      assignedTheater: assignedTheater,
    );
  }

  /// Sends a password-reset email via Firebase Authentication.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Signs out, clears the cached profile, and stops lifecycle observation.
  Future<void> logout() async {
    _cachedProfile = null;
    _stopObserving();
    await _auth.signOut();
    // Re-register observer so the next login session is observed.
    startObserving();
  }

  // ── Firebase error code → user-facing message ─────────────────────────────
  /// Handles both modern SDK ('invalid-credential') and older SDK codes.
  static String mapFirebaseAuthError(String code) {
    return switch (code) {
      'invalid-credential' => 'Incorrect email or password.',
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect email or password.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' =>
        'This Firebase Authentication account is disabled. Contact support.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'No internet connection.',
      'email-already-in-use' => 'An account with this email already exists.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'operation-not-allowed' =>
        'Email and password registration is disabled. Please contact support.',
      'configuration-not-found' =>
        'Email and password sign-in is not configured. Please contact support.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }

  /// Maps database failures that can occur after Auth account creation.
  static String mapFirebaseDatabaseError(String code) {
    return switch (code) {
      'permission-denied' =>
        'Your account was not saved because database access was denied. Please contact support.',
      'unavailable' || 'network-request-failed' =>
        'The account service is temporarily unavailable. Check your connection and try again.',
      'not-found' =>
        'The user profile database is not configured. Please contact support.',
      'failed-precondition' =>
        'The user profile database is not ready. Please contact support.',
      _ => 'The user profile could not be saved. Please try again.',
    };
  }
}
