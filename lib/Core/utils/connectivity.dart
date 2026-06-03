import 'dart:io';

/// reachability check without an extra package.
///
/// Does a short DNS lookup — enough to tell "online" from "offline" before
/// running an action that should be blocked while disconnected.
class Connectivity {
  Connectivity._();

  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
