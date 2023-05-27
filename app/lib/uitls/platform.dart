import 'dart:io';

class AppPlatform {
  static bool get isMobile {
    return ((Platform.isIOS || Platform.isAndroid));
  }
}
