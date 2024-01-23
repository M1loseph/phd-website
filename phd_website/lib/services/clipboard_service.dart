import 'package:flutter/services.dart';

class ClipboardService {
  Future<void> copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }
}
