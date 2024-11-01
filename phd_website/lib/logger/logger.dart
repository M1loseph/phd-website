import 'package:flutter/foundation.dart';

class Logger {
  final Type loggingClass;

  Logger(this.loggingClass);

  void debug(String message) {
    debugPrint(
        '[DEBUG] [${loggingClass.toString()}] [${DateTime.now()}] $message');
  }

  void error(String message) {
    debugPrint(
        '[ERROR] [${loggingClass.toString()}] [${DateTime.now()}] $message');
  }
}
