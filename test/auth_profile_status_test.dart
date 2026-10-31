import 'package:flutter_test/flutter_test.dart';
import 'package:booking/services/auth_service.dart';

void main() {
  group('Firestore profile active-state classification', () {
    test('only explicit false is an inactive profile', () {
      expect(classifyProfileActiveState(false), ProfileActiveState.inactive);
    });

    test('explicit true is active', () {
      expect(classifyProfileActiveState(true), ProfileActiveState.active);
    });

    test('missing or malformed values are invalid, not disabled', () {
      expect(classifyProfileActiveState(null), ProfileActiveState.invalid);
      expect(classifyProfileActiveState('false'), ProfileActiveState.invalid);
      expect(classifyProfileActiveState(0), ProfileActiveState.invalid);
    });
  });

  group('Role-specific Firestore profile requirements', () {
    test('Admin profile does not need regular-user or Owner fields', () {
      final result = resolveProfileRole(
        {
          'adminId': 'admin-uid',
          'email': 'admin@example.com',
          'role': 'admin',
          'isActive': true,
        },
        {'movixRole': 'admin'},
      );

      expect(result.isValid, isTrue);
      expect(result.role, UserRole.admin);
      expect(result.assignedTheater, isNull);
    });

    test(
      'Owner profile requires its theater claim and assignment to match',
      () {
        final result = resolveProfileRole(
          {
            'email': 'owner@example.com',
            'role': 'owner',
            'isActive': true,
            'assignedTheater': 'Kairali',
            'theaterId': 'Kairali',
          },
          {'movixRole': 'owner', 'theaterId': 'Kairali'},
        );

        expect(result.isValid, isTrue);
        expect(result.role, UserRole.owner);
        expect(result.assignedTheater, 'Kairali');
      },
    );

    test('Owner theater mismatch is rejected', () {
      final result = resolveProfileRole(
        {'role': 'owner', 'assignedTheater': 'Kairali'},
        {'movixRole': 'owner', 'theaterId': 'Nila'},
      );

      expect(result.issue, ProfileRoleIssue.theaterClaimMismatch);
    });

    test('regular user profile works without privileged claims', () {
      final result = resolveProfileRole({
        'role': 'user',
        'email': 'user@example.com',
        'displayName': 'Regular User',
        'phoneNumber': '9876543210',
        'assignedTheater': null,
        'isActive': true,
      }, {});

      expect(result.isValid, isTrue);
      expect(result.role, UserRole.user);
    });

    test('Firestore Admin role alone cannot grant Admin access', () {
      final result = resolveProfileRole({
        'role': 'admin',
        'email': 'admin@example.com',
        'isActive': true,
      }, {});

      expect(result.issue, ProfileRoleIssue.missingAdminClaim);
    });
  });
}
