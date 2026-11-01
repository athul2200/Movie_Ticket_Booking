import 'package:flutter/material.dart';
import 'package:booking/core/theme/app_theme.dart';
import 'package:booking/core/utils/image_provider_helper.dart';

/// Cross-platform image widget that handles:
/// - Network URLs (`http://`, `https://`)
/// - Blob URLs (`blob:`)
/// - Data URLs (`data:`)
/// - Local device file paths (`/data/...`, `C:\...`, `file://...`)
class AppImage extends StatelessWidget {
  final String urlOrPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool diagnosticLogging;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage({
    super.key,
    required this.urlOrPath,
    this.width,
    this.height,
    this.fit,
    this.diagnosticLogging = false,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (diagnosticLogging) {
      debugPrint('[OWNER_MOVIES_DIAG] AppImage build: path=$urlOrPath');
    }
    if (urlOrPath.trim().isEmpty) {
      return _buildFallback(context, 'Empty path');
    }

    final String trimmed = urlOrPath.trim();
    final bool isNetwork = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('blob:') ||
        trimmed.startsWith('data:');

    if (isNetwork) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          if (diagnosticLogging) {
            debugPrint('[OWNER_MOVIES_DIAG] network image failed: $error');
            if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
          }
          return _buildFallback(context, error, stackTrace);
        },
      );
    } else if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (diagnosticLogging) {
            debugPrint('[OWNER_MOVIES_DIAG] asset image failed: $error');
            if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
          }
          return _buildFallback(context, error, stackTrace);
        },
      );
    } else {
      return getFileImageWidget(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        diagnosticLogging: diagnosticLogging,
        errorBuilder: (context, error, stackTrace) {
          if (diagnosticLogging) {
            debugPrint('[OWNER_MOVIES_DIAG] local image failed: $error');
            if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
          }
          return _buildFallback(context, error, stackTrace);
        },
      );
    }
  }

  Widget _buildFallback(BuildContext context, Object error, [StackTrace? stackTrace]) {
    if (errorBuilder != null) {
      return errorBuilder!(context, error, stackTrace);
    }
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.movie, size: 40, color: AppColors.textHint),
      ),
    );
  }
}
