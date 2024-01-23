import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:phd_website/pages/contact_page.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:phd_website/services/clipboard_service.dart';
import 'package:provider/provider.dart';

class FakeAssetBundle extends Fake implements AssetBundle {
  final String svgStr = '''<svg viewBox="0 0 10 10"></svg>''';

  @override
  Future<ByteData> load(String key) async {
    final data = utf8.encode('<svg viewBox="0 0 10 10"></svg>');
    return ByteData.sublistView(data);
  }
}

class MockClipboardService extends Mock implements ClipboardService {
  String? copiedValue;
  @override
  Future<void> copyToClipboard(String value) async {
    copiedValue = value;
  }
}

class MockBuildProperties extends Mock implements BuildProperties {
  @override
  String get appVersion => '1.0.0';
  @override
  int get lastBuildYear => 2024;
}

void main() {
  testWidgets('When click copy button Then email should be copied to clipboard',
      (tester) async {
    // Given
    final clipboardService = MockClipboardService();
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: FakeAssetBundle(),
        child: MultiProvider(
          providers: [
            Provider(create: (_) => BodyTextStyleService()),
            Provider<BuildProperties>(create: (_) => MockBuildProperties()),
            Provider<ClipboardService>(create: (_) => clipboardService),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: ContactPage(),
          ),
        ),
      ),
    );

    // When
    await tester.tap(find.byIcon(Icons.copy));

    // Then
    expect(clipboardService.copiedValue, 'bogna.jaszczak@pwr.edu.pl');
  });
}
