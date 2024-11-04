import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/logger/logger.dart';
import 'package:phd_website/services/analytics_events.dart';

const httpCreated = 201;

// TODO: maybe try not to do heavy lifting in constructor - just for the sake of not doing it :)
class AnalyticsService {
  final Logger logger = Logger(AnalyticsService);
  final Uri analyticsUrl;
  final Client httpClient;
  final Clock clock;
  final String environment;
  final BuildProperties buildProperties;
  final StreamController<(PageData, DateTime)> eventQueue = StreamController();

  AnalyticsService({
    required String analyticsUrl,
    required this.httpClient,
    required this.clock,
    required this.environment,
    required this.buildProperties,
  }) : analyticsUrl = Uri.parse(analyticsUrl) {
    scheduleMicrotask(_backgroundSessionTask);
  }

  Future<void> registerPageOpenedEvent(PageData pageData) async {
    eventQueue.add((pageData, clock.now()));
  }

  void _backgroundSessionTask() async {
    String? sessionId;
    while (sessionId == null) {
      try {
        final event = AppOpenedEvent(
            clock.now(), environment, buildProperties.appVersion);
        final response = await httpClient.post(
          analyticsUrl.replace(path: 'api/v1/analytics/appOpened'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(event.toJson()),
        );
        if (response.statusCode != httpCreated) {
          continue;
        }
        final appOpenedEventResponse =
            AppOpenedEventResponse.fromJson(json.decode(response.body));
        sessionId = appOpenedEventResponse.sessionId;
      } catch (e) {
        if (kDebugMode) {
          logger.debug('Error occurred when establishing session $e');
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    await for (final (pageData, openTime) in eventQueue.stream) {
      final event = PageOpenedEvent(sessionId, openTime, pageData);
      await httpClient.post(
        analyticsUrl.replace(path: 'api/v1/analytics/pageOpened'),
        headers: Map.from(
          {'Content-Type': 'application/json'},
        ),
        body: json.encode(event.toJson()),
      );
    }
  }
}
