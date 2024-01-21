import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/components/nav/section_label.dart';

class DesktopSectionNavigation extends StatefulWidget {
  final String destination;
  final String name;
  final bool selected;

  const DesktopSectionNavigation({
    super.key,
    required this.destination,
    required this.name,
    required this.selected,
  });

  @override
  State<DesktopSectionNavigation> createState() =>
      _DesktopSectionNavigationState();
}

class _DesktopSectionNavigationState extends State<DesktopSectionNavigation>
    with SingleTickerProviderStateMixin {
  static const defaultScale = 1.0;
  static const onPressedScale = 0.90;

  late final AnimationController controller;
  bool hoovered = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: defaultScale, end: onPressedScale),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: onPressedScale, end: defaultScale),
        weight: 50,
      ),
    ]).animate(controller);
    return MouseRegion(
      onEnter: (_) => setState(() => hoovered = true),
      onExit: (_) => setState(() => hoovered = false),
      child: GestureDetector(
        onTap: () {
          controller.forward();
          context.go(widget.destination);
        },
        child: ScaleTransition(
          scale: animation,
          child: SectionLabel(
            name: widget.name,
            selected: widget.selected,
            hoovered: hoovered,
          ),
        ),
      ),
    );
  }
}
