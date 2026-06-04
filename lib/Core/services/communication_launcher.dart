import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralises outbound communication (phone call, WhatsApp) so pages don't
/// hand-roll url_launcher / number formatting.
///
/// Methods return `true` if something was launched, `false` otherwise — the
/// caller can show feedback on `false` (e.g. "WhatsApp not installed").
class CommunicationLauncher {
  CommunicationLauncher._();

  /// Default country code applied to local numbers starting with '0'.
  /// (App data is Pakistani; adjustable if the audience changes.)
  static const _defaultCountryCode = '92';

  /// Opens the dialer for [phone]. Returns false if there's no number.
  static Future<bool> call(String phone) {
    debugPrint('[CommLauncher] call(phone="$phone")');
    final digits = _digits(phone);
    if (digits.isEmpty) {
      debugPrint('[CommLauncher] call aborted — no digits in "$phone"');
      return Future.value(false);
    }
    return _launch(Uri.parse('tel:$digits'));
  }

  /// Opens a WhatsApp chat with [phone], optionally pre-filling [message].
  /// WhatsApp opens the chat — the user taps the call icon to start a video call.
  /// Returns false (never throws) if the number is empty or nothing can handle it.
  static Future<bool> whatsApp(String phone, {String message = ''}) async {
    debugPrint('[CommLauncher] whatsApp(phone="$phone")');
    final number = _toInternational(phone);
    if (number.isEmpty) {
      debugPrint('[CommLauncher] whatsApp aborted — no digits in "$phone"');
      return false;
    }
    debugPrint('[CommLauncher] normalized number="$number"');

    final text = message.isEmpty ? '' : '&text=${Uri.encodeComponent(message)}';

    // Prefer the native WhatsApp scheme; fall back to the universal wa.me link.
    final native = Uri.parse('whatsapp://send?phone=$number$text');
    debugPrint('[CommLauncher] step 1 — trying native scheme: $native');
    if (await _launch(native)) return true;

    final query =
        message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}';
    final wa = Uri.parse('https://wa.me/$number$query');
    debugPrint('[CommLauncher] step 2 — falling back to web link: $wa');
    return _launch(wa);
  }

  /// Launches [uri] only when a handler is actually present. Checking first
  /// means a missing target (e.g. WhatsApp not installed, or a custom scheme on
  /// desktop/web) fails fast as `false` instead of throwing a PlatformException
  /// — that thrown-then-caught error is what made the debugger halt on the first
  /// tap. canLaunchUrl is reliable here because every scheme/package we launch
  /// (tel, https, com.whatsapp) is declared in the AndroidManifest <queries>.
  static Future<bool> _launch(Uri uri) async {
    try {
      final can = await canLaunchUrl(uri);
      debugPrint('[CommLauncher] canLaunchUrl("$uri") -> $can');
      if (!can) return false;
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('[CommLauncher] launchUrl("$uri") -> $launched');
      return launched;
    } catch (e, st) {
      debugPrint('[CommLauncher] launch error for "$uri": $e');
      debugPrint('$st');
      return false;
    }
  }

  static String _digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  /// Best-effort international format for WhatsApp (no '+', no leading 0).
  static String _toInternational(String phone) {
    var d = _digits(phone);
    if (d.startsWith('0')) d = '$_defaultCountryCode${d.substring(1)}';
    return d;
  }
}
