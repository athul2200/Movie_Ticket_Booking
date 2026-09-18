import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:booking/widgets/update_dialog.dart';

/// ============================================================
/// Update Service — GitHub-based automatic APK update manager
/// ============================================================

class UpdateService {
  static final UpdateService instance = UpdateService._internal();
  factory UpdateService() => instance;
  UpdateService._internal();

  /// GitHub raw URL for version.json
  /// Primary branch: master, Fallback branch: main
  static const String _primaryUrl =
      'https://raw.githubusercontent.com/athul2200/Movie_Ticket_Booking/master/version.json';
  static const String _fallbackUrl =
      'https://raw.githubusercontent.com/athul2200/Movie_Ticket_Booking/main/version.json';

  /// Avoid showing duplicate dialogs in a single session
  bool _hasChecked = false;

  /// Fetches installed app version dynamically from package manager
  Future<String> getInstalledVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      developer.log('Error reading PackageInfo: $e', name: 'UpdateService');
      return '1.0.0';
    }
  }

  /// Checks for updates asynchronously without blocking app startup.
  /// If a newer version is available, presents the UpdateDialog.
  Future<void> checkAndShowUpdateDialog(
    BuildContext context, {
    bool forceCheck = false,
  }) async {
    if (_hasChecked && !forceCheck) return;

    try {
      // 1. Get installed version dynamically
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      final fullCurrentVersion = currentBuildNumber.isNotEmpty
          ? '$currentVersion+$currentBuildNumber'
          : currentVersion;

      // 2. Fetch remote version.json from GitHub Raw URL with timeout
      Map<String, dynamic>? data = await _fetchVersionJson(_primaryUrl);
      data ??= await _fetchVersionJson(_fallbackUrl);

      if (data == null) {
        developer.log('Failed to fetch version.json from GitHub Raw', name: 'UpdateService');
        return;
      }

      final String latestVersion = data['latest_version']?.toString() ?? '';
      final String apkUrl = data['apk_url']?.toString() ?? '';
      final String updateMessage = data['update_message']?.toString() ?? '';

      if (latestVersion.isEmpty || apkUrl.isEmpty) {
        developer.log('Invalid version.json data format', name: 'UpdateService');
        return;
      }

      // 3. Perform semantic version comparison
      final bool updateAvailable = isUpdateAvailable(fullCurrentVersion, latestVersion);

      _hasChecked = true;

      if (updateAvailable && context.mounted) {
        UpdateDialog.show(
          context,
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          updateMessage: updateMessage,
          apkUrl: apkUrl,
        );
      }
    } catch (e) {
      // Handle all internet/parsing errors gracefully without blocking or crashing app startup
      developer.log('Gracefully handled update check exception: $e', name: 'UpdateService');
    }
  }

  /// Helper to fetch JSON from URL with 5-second timeout
  Future<Map<String, dynamic>?> _fetchVersionJson(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      developer.log('HTTP fetch error ($url): $e', name: 'UpdateService');
    }
    return null;
  }

  /// Semantic version comparison logic.
  /// Returns true if [remoteVersion] is strictly newer than [currentVersion].
  bool isUpdateAvailable(String currentVersion, String remoteVersion) {
    final cleanCurrent = currentVersion.trim().replaceAll(RegExp(r'^[vV]'), '');
    final cleanRemote = remoteVersion.trim().replaceAll(RegExp(r'^[vV]'), '');

    final currentParts = cleanCurrent.split('+');
    final remoteParts = cleanRemote.split('+');

    final currentBase =
        currentParts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remoteBase =
        remoteParts[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // 1. Compare major.minor.patch
    final maxLength = currentBase.length > remoteBase.length
        ? currentBase.length
        : remoteBase.length;

    for (int i = 0; i < maxLength; i++) {
      final c = i < currentBase.length ? currentBase[i] : 0;
      final r = i < remoteBase.length ? remoteBase[i] : 0;

      if (r > c) return true;
      if (r < c) return false;
    }

    // 2. Base version numbers equal; compare build numbers if both provided
    if (currentParts.length > 1 && remoteParts.length > 1) {
      final currentBuild = int.tryParse(currentParts[1]) ?? 0;
      final remoteBuild = int.tryParse(remoteParts[1]) ?? 0;
      if (remoteBuild > currentBuild) return true;
    }

    return false;
  }
}
