import 'package:flutter/cupertino.dart';
import 'package:phd_website/services/analytics_events.dart';
import 'package:phd_website/services/analytics_service.dart';
import 'package:provider/provider.dart';

class PageAnalyticsDecorator extends StatefulWidget {
  final String _pageName;
  final Widget _child;
  const PageAnalyticsDecorator({
    super.key,
    required String pageName,
    required Widget child,
  })  : _child = child,
        _pageName = pageName;

  @override
  State<PageAnalyticsDecorator> createState() => _PageAnalyticsDecoratorState();
}

class _PageAnalyticsDecoratorState extends State<PageAnalyticsDecorator> {
  @override
  void initState() {
    super.initState();
    context
        .read<AnalyticsService>()
        .registerPageOpenedEvent(PageData(pageName: widget._pageName));
  }

  @override
  Widget build(BuildContext context) {
    return widget._child;
  }
}
