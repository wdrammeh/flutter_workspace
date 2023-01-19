import 'package:flutter/foundation.dart';

class Debug {

  static void log(data) {
    if (kDebugMode) {
      print("$data");
    }
  }

}
