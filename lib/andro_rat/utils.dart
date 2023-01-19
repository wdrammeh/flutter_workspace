import 'dart:io';

class Utils {
  
  static bool isMobilePlatform() {
    return Platform.isAndroid || Platform.isIOS;
  }

  // Todo include/support IOS
  static bool isSupportedPlatform() {
    return Platform.isAndroid;
  }
  
}
