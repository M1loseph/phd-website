import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:provider/provider.dart';

class ConsultationPage extends StatelessWidget {
  final iconSpace = 10.0;
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalAppState = context.watch<AppGlobalState>();
    final textStyle = globalAppState.getMainContextTextStyle();
    return Center(
      child: SpacedListLayout(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home),
              SizedBox(
                width: iconSpace,
              ),
              Text(
                "C19 4.14",
                style: textStyle,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month),
              SizedBox(
                width: iconSpace,
              ),
              Text(
                "Poniedziałek 11:15 - 12:15",
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
