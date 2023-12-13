import 'package:flutter/material.dart';
import 'package:phd_website/components/heart_shower/falling_heart.dart';

class FallingHeartFacade extends StatelessWidget {
  const FallingHeartFacade({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FallingHeart(constraints: constraints);
      },
    );
  }
}
