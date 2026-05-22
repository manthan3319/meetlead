import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  /// Host where the dev backend runs.
  /// - iOS simulator / desktop / web: `localhost` works because they share the host's networking
  /// - Android emulator: must use `10.0.2.2` to reach the host machine
  /// - Physical device: set this to your machine's LAN IP (e.g. 192.168.1.5)
  static String get _host {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
      return 'localhost';
    } catch (_) {
      return 'localhost';
    }
  }

  static String get apiBaseUrl => 'http://${_host}:5050/api';
  static String get socketUrl => 'http://${_host}:5050';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
}
