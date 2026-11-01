import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider getFileImageProvider(String path) {
  final cleanPath = path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
  return FileImage(File(cleanPath));
}

Widget getFileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  bool diagnosticLogging = false,
}) {
  final cleanPath = path.startsWith('file://') ? Uri.parse(path).toFilePath() : path;
  if (cleanPath.startsWith('assets/')) {
    return Image.asset(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
  final file = File(cleanPath);
  if (diagnosticLogging) {
    try {
      final exists = file.existsSync();
      debugPrint(
        '[OWNER_MOVIES_DIAG] local image file: exists=$exists, '
        'bytes=${exists ? file.lengthSync() : 0}',
      );
    } catch (error, stackTrace) {
      debugPrint('[OWNER_MOVIES_DIAG] local file inspection failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  final image = Image.file(
    file,
    width: width,
    height: height,
    fit: fit,
    gaplessPlayback: true,
    errorBuilder: errorBuilder,
  );
  if (diagnosticLogging) {
    debugPrint('[OWNER_MOVIES_DIAG] Image.file widget constructed');
  }
  return image;
}
