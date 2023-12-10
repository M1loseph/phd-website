import 'package:flutter_test/flutter_test.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/state/cookies_approval.dart';
import 'package:phd_website/state/optional_feature.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
      'Given approved cookies When bumpNumberOfEntires is called Then siteEntries value is incremented',
      () async {
    // Given
    SharedPreferences.setMockInitialValues({
      'siteEntries': 10,
      'cookiesAcknowledged': CookiesApproval.approved.name
    });
    final appGlobalState = AppGlobalState(SharedPreferences.getInstance());

    // When
    await appGlobalState.bumpNumberOfEntires();

    // Then
    expect(
      await appGlobalState.getNumberOfEntires(),
      OptionalFeature.enabled(value: 11),
    );
  });

  test(
      'Given unapproved cookies Then siteEntries should return disabled feature',
      () async {
    // Given
    SharedPreferences.setMockInitialValues({});
    final appGlobalState = AppGlobalState(SharedPreferences.getInstance());

    // Then
    expect(
      await appGlobalState.getNumberOfEntires(),
      OptionalFeature<int>.disabled(),
    );
  });

  test(
      'Given unapproved cookies When cookies are approved Then siteEntries should return enabled feature',
      () async {
    // Given
    SharedPreferences.setMockInitialValues({});
    final appGlobalState = AppGlobalState(SharedPreferences.getInstance());

    // When
    await appGlobalState.acceptCookies();

    // Then
    expect(
      await appGlobalState.getNumberOfEntires(),
      OptionalFeature.enabled(value: 1),
    );
  });

  test(
      'Given unapproved cookies When cookies are rejected Then siteEntries should return disabled feature',
      () async {
    // Given
    SharedPreferences.setMockInitialValues({});
    final appGlobalState = AppGlobalState(SharedPreferences.getInstance());

    // When
    await appGlobalState.rejectCookies();

    // Then
    expect(
      await appGlobalState.getNumberOfEntires(),
      OptionalFeature<int>.disabled(),
    );
  });
}
