import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(400, 400)),
            child: ClipOval(
              child: Image.asset("images/profile.jpg"),
            ),
          ),
        ),
        Text(
          "Bogna Jaszczak",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text(
          "Studentka szkoły doktorskiej",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          "Wydział Matematyki Politechnika Wrocławska",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
