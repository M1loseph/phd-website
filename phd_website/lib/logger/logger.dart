

import 'package:flutter/foundation.dart';

class Logger {
  final Type loggingClass;

  Logger({required this.loggingClass});

  void debug(String message) {
    if(kDebugMode) {
      debugPrint('[${loggingClass.toString()}] [${DateTime.now()}] $message');
    }
  }
}
