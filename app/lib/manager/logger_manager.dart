import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class LoggerManager {
  static void initLogger() {
    if (!kReleaseMode) {
      Logger.level = Level.debug;
    } else {
      Logger.level = Level.error;
    }
  }
}
