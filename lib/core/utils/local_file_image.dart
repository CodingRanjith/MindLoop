import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shows a local file image on mobile/desktop; placeholder on web.
class LocalFileImage extends StatelessWidget {
  const LocalFileImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  static bool canShowFile(String? path) {
    if (path == null || path.isEmpty) return false;
    if (kIsWeb) return false;
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    if (!canShowFile(path)) {
      return _placeholder(context);
    }

    Widget image = Image.file(
      File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => _placeholder(context),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_outlined,
        size: (height != null && height! < 60) ? 24 : 40,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
