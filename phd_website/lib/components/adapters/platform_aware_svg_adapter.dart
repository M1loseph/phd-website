import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phd_website/components/adapters/platform_aware_widget.dart';

class PlatformAwareSvgAdapter extends PlatformAwareWidget {
  final String path;
  final double? height;
  final ColorFilter? colorFilter;

  const PlatformAwareSvgAdapter({
    super.key,
    required this.path,
    this.height,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      getActualPath(path),
      height: height,
      colorFilter: colorFilter, 
    );
  }
}
