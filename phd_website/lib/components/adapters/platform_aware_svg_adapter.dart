import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phd_website/components/adapters/platform_aware_image.dart';

class PlatformAwareSvgAdapter extends PlatformAwareImage {
  final String path;
  final double? height;
  final double? width;
  final ColorFilter? colorFilter;

  const PlatformAwareSvgAdapter({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.colorFilter,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      getActualPath(path),
      height: height,
      width: width,
      colorFilter: colorFilter,
    );
  }
}
