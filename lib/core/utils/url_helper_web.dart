// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Opens the admin dashboard web page in a new browser tab/window on Web.
void openAdminWebPage() {
  String url = 'http://localhost:8080/#/admin';
  try {
    final origin = html.window.location.origin;
    url = '$origin/#/admin';
  } catch (e) {
    debugPrint('Error getting window location: $e');
  }

  try {
    html.window.open(url, '_blank');
  } catch (e) {
    debugPrint('Error launching URL: $e');
  }
}
