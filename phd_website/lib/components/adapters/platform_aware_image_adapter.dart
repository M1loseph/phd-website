import 'package:flutter/material.dart';
import 'package:phd_website/components/adapters/platform_aware_image.dart';

class PlatformAwareImageAdapter extends PlatformAwareImage {
  final String path;
  final double? height;

  const PlatformAwareImageAdapter({
    super.key,
    required this.path,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      getActualPath(path),
      height: height,
    );
  }
}
