import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/services/analytics_events.dart';

const httpCreated = 201;

class AnalyticsService {
  late Future<String?> sessionId;
  final Uri analyticsUrl;
  final Client httpClient;
  final Clock clock;
  final String environment;

  AnalyticsService({
    required String analyticsUrl,
    required this.httpClient,
    required this.clock,
    required this.environment,
  }) : analyticsUrl = Uri.parse(analyticsUrl);

  Future<void> registerAppOpenedEvent() async {
    sessionId = () async {
      final event = AppOpenedEvent(clock.now(), environment);
      final response = await httpClient.post(
        analyticsUrl.replace(path: 'api/v1/analytics/appOpened'),
        headers: Map.from(
          {'Content-Type': 'application/json'},
        ),
        body: json.encode(event.toJson()),
      );
      if (response.statusCode != httpCreated) {
        return null;
      }
      final appOpenedEventResponse =
          AppOpenedEventResponse.fromJson(json.decode(response.body));
      return appOpenedEventResponse.sessionId;
    }();
    return sessionId.ignore();
  }

  Future<void> registerPageOpenedEvent(PageData pageData) async {
    await sessionId.then((sessionId) async {
      if (sessionId == null) {
        return;
      }
      final event = PageOpenedEvent(sessionId, clock.now(), pageData);
      await httpClient.post(
        analyticsUrl.replace(path: 'api/v1/analytics/pageOpened'),
        headers: Map.from(
          {'Content-Type': 'application/json'},
        ),
        body: json.encode(event.toJson()),
      );
    });
  }
}
