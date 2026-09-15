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
  return Image.file(
    File(cleanPath),
    width: width,
    height: height,
    fit: fit,
    gaplessPlayback: true,
    errorBuilder: errorBuilder,
  );
}
