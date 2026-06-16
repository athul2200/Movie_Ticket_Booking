import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the admin dashboard web page in the system browser for mobile/desktop.
Future<void> openAdminWebPage() async {
  const String url = 'https://movies-admin.netlify.app/';
  final Uri uri = Uri.parse(url);
  try {
    debugPrint('Attempting to launch $url');
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      debugPrint('Failed to launch with externalApplication, trying platformDefault');
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}
