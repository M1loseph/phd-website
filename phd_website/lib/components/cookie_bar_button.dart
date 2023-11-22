import 'package:flutter/material.dart';

class CookieBarButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final IconData icon;

  const CookieBarButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: LayoutBuilder(builder: (context, constrains) {
        return TextButton.icon(
          onPressed: onPressed,
          label: Text(text),
          icon: Icon(icon),
          style: TextButton.styleFrom(
              minimumSize: const Size(250, 45),
              backgroundColor: Colors.grey.shade400,
              shape: const ContinuousRectangleBorder()),
        );
      }),
    );
  }
}
