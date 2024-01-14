import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/components/adapters/platform_aware_image_adapter.dart';

class WMatLogo extends StatelessWidget {
  const WMatLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerDown: (event) => context.go('/'),
          child: const PlatformAwareImageAdapter(
            path: 'images/wmat_logo.png',
            height: 60,
          ),
        ),
      ),
    );
  }
}