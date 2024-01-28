import 'package:flutter/material.dart';
import 'package:phd_website/components/heart_shower/falling_heart.dart';

class HeartShower extends StatefulWidget {
  const HeartShower({
    super.key,
  });

  @override
  State<HeartShower> createState() => _HeartShowerState();
}

class _HeartShowerState extends State<HeartShower> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fallingHearts = constraints.maxWidth / 40;
      return Stack(
        children: [
          for (int i = 0; i < fallingHearts; i++)
            FallingHeart(
              key: ValueKey(i),
              constraints: constraints,
            ),
        ],
      );
    });
  }
}
