import 'package:flutter/cupertino.dart';

class NewCardLink extends StatelessWidget {
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.all(8.0);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? iconSize;

  const NewCardLink({super.key, required this.child, this.iconSize, this.padding = defaultPadding});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(CupertinoIcons.arrow_up_right_circle_fill, size: iconSize,),
          ),
        ],
      ),
    );
  }
}
