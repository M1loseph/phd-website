import 'dart:convert';

import 'package:http/http.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/services/analytics_events.dart';


class AnalyticsService {
  final String sessionId;
  final Uri analyticsUrl;
  final Client httpClient;
  final Clock clock;
  final String environment;

  AnalyticsService({
    required this.sessionId,
    required String analyticsUrl,
    required this.httpClient,
    required this.clock,
    required this.environment,
  }) : analyticsUrl = Uri.parse(analyticsUrl);

  Future<void> registerUserOpenedApp() async {
    final event = UserOpenedAppEvent(sessionId, clock.now(), environment);
    await httpClient.post(
      analyticsUrl.replace(path: 'api/v1/analytics/appOpened'),
      headers: Map.from(
        {'Content-Type': 'application/json'},
      ),
      body: json.encode(event.toJson()),
    );
  }

  Future<void> registerUserOpenedPage(PageData pageData) async {
    final event = UserOpenedPageEvent(sessionId, clock.now(), pageData);
    await httpClient.post(
      analyticsUrl.replace(path: 'api/v1/analytics/pageOpened'),
      headers: Map.from(
        {'Content-Type': 'application/json'},
      ),
      body: json.encode(event.toJson()),
    );
  }
}
