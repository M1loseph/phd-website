import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/services/analytics_events.dart';
import 'package:phd_website/services/analytics_service.dart';

class HttpClientMock extends Mock implements Client {}

class FixedClock implements Clock {
  static final fixedDate = DateTime.parse('2020-10-10T10:10:10Z');
  @override
  DateTime now() {
    return fixedDate;
  }
}

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
        body: json
            .encode(AppOpenedEvent(fixedClock.now(), 'unit-tests').toJson()),
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
    );

    analyticsService.registerPageOpenedEvent(PageData(pageName: 'myPageName'));

    await Future.delayed(const Duration(seconds: 1));

    // then
    verify(() => httpClientMock.post(
          Uri.parse('https://some.server/api/v1/analytics/pageOpened'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(PageOpenedEvent(
            'abc123',
            FixedClock.fixedDate,
            PageData(
              pageName: 'myPageName',
            ),
          ).toJson()),
        )).called(1);
  });
}
