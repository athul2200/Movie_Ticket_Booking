import 'package:flutter_test/flutter_test.dart';
import 'package:booking/services/update_service.dart';

void main() {
  group('UpdateService Version Comparison Tests', () {
    final updateService = UpdateService();

    test('Identical version returns false', () {
      expect(updateService.isUpdateAvailable('1.0.0', '1.0.0'), false);
    });

    test('Higher patch version returns true', () {
      expect(updateService.isUpdateAvailable('1.0.0', '1.0.1'), true);
    });

    test('Higher minor version returns true', () {
      expect(updateService.isUpdateAvailable('1.0.0', '1.1.0'), true);
    });

    test('Higher major version returns true', () {
      expect(updateService.isUpdateAvailable('1.0.0', '2.0.0'), true);
    });

    test('Lower remote version returns false', () {
      expect(updateService.isUpdateAvailable('1.1.0', '1.0.0'), false);
      expect(updateService.isUpdateAvailable('2.0.0', '1.9.9'), false);
    });

    test('Build number comparison when base version is equal', () {
      expect(updateService.isUpdateAvailable('1.0.0+1', '1.0.0+2'), true);
      expect(updateService.isUpdateAvailable('1.0.0+2', '1.0.0+1'), false);
      expect(updateService.isUpdateAvailable('1.0.0+1', '1.0.0+1'), false);
    });

    test('Handles v/V prefix gracefully', () {
      expect(updateService.isUpdateAvailable('v1.0.0', 'v1.1.0'), true);
      expect(updateService.isUpdateAvailable('V1.0.0+1', 'v1.1.0+2'), true);
    });

    test('Major update with build number', () {
      expect(updateService.isUpdateAvailable('1.0.0+1', '1.1.0+2'), true);
    });
  });
}
