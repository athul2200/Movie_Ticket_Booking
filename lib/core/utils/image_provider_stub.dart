import 'package:flutter/material.dart';

ImageProvider getFileImageProvider(String path) {
  return NetworkImage(path);
}

Widget getFileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    gaplessPlayback: true,
    errorBuilder: errorBuilder,
  );
}
