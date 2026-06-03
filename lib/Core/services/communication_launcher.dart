import 'package:url_launcher/url_launcher.dart';

/// Centralises outbound communication (phone call, WhatsApp) so pages don't
/// hand-roll url_launcher / number formatting.
///
/// Methods return `true` if something was launched, `false` otherwise — the
/// caller can show feedback on `false` (e.g. "WhatsApp not installed").
class CommunicationLauncher {
  CommunicationLauncher._();

  /// Default country code applied to local numbers starting with '0'.
  /// (App data is Pakistani; adjust if the audience changes.)
  static const _defaultCountryCode = '92';

  /// Opens the dialer for [phone].
  static Future<bool> call(String phone) =>
      _launch(Uri.parse('tel:${_digits(phone)}'));

  /// Opens a WhatsApp chat with [phone], optionally pre-filling [message].
  /// WhatsApp opens the chat — the user taps the call icon to start a video call.
  static Future<bool> whatsApp(String phone, {String message = ''}) async {
    final number = _toInternational(phone);
    final text = message.isEmpty ? '' : '&text=${Uri.encodeComponent(message)}';

    // Prefer the native WhatsApp scheme; fall back to the universal wa.me link.
    final native = Uri.parse('whatsapp://send?phone=$number$text');
    if (await _launch(native)) return true;

    final query = message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}';
    return _launch(Uri.parse('https://wa.me/$number$query'));
  }

  /// Launches [uri] directly. We don't pre-check with canLaunchUrl because on
  /// Android 11+ it can report false even when the launch would succeed.
  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
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
