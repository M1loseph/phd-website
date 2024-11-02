import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phd_website/services/analytics_events.dart';
import 'package:phd_website/services/analytics_service.dart';

import '../mock/fixed_build_properties.dart';
import '../mock/fixed_clock.dart';

class HttpClientMock extends Mock implements Client {}

void main() {
  test(
      'When API returns session response then should event about page being opened',
      () async {
    // given
    final httpClientMock = HttpClientMock();
    final fixedClock = FixedClock();
    // mock first call to establish session
    when(
      () => httpClientMock.post(
        Uri.parse('https://some.server/api/v1/analytics/appOpened'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            AppOpenedEvent(fixedClock.now(), 'unit-tests', '1.1').toJson()),
      ),
    ).thenAnswer((_) async => Response('{"sessionId": "abc123"}', 201));

    // mock next calls that send events about visited pages
    when(
      () => httpClientMock.post(
        Uri.parse('https://some.server/api/v1/analytics/pageOpened'),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => Response('', 201));

    // when
    final analyticsService = AnalyticsService(
      analyticsUrl: 'https://some.server',
      httpClient: httpClientMock,
      clock: fixedClock,
      environment: 'unit-tests',
      buildProperties: FixedBuildProperties(),
    );

    analyticsService.registerPageOpenedEvent(PageData(pageName: 'myPageName'));

    await Future.delayed(const Duration(seconds: 1));

    // then
    verify(() => httpClientMock.post(
          Uri.parse('https://some.server/api/v1/analytics/pageOpened'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(PageOpenedEvent(
            'abc123',
            FixedClock.defaultFixedDate,
            PageData(
              pageName: 'myPageName',
            ),
          ).toJson()),
        )).called(1);
  });
}
