import 'package:flutter/material.dart';

import 'falling_heart_facade.dart';

class HeartShower extends StatefulWidget {
  const HeartShower({
    super.key,
  });

  @override
  State<HeartShower> createState() => _HeartShowerState();
}

class _HeartShowerState extends State<HeartShower> {
  static const _fallingHearts = 100;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < _fallingHearts; i++) const FallingHeartFacade(),
      ],
    );
  }
}
