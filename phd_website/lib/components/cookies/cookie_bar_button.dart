import 'package:flutter/material.dart';

class CookieBarButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final Icon icon;

  const CookieBarButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextButton.icon(
        onPressed: onPressed,
        label: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black,
              ),
        ),
        icon: icon,
        style: TextButton.styleFrom(
          minimumSize: const Size(250, 45),
          backgroundColor: Colors.grey.shade400,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          foregroundColor: Colors.transparent
        ),
      ),
    );
  }
}
