import 'package:shared_preferences/shared_preferences.dart';

class GuestSessionService {
  GuestSessionService._();

  static const String _guestKey = 'kiddo_guest_mode';

  // Remember that the user chose guest mode.
  static Future<void> startGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
  }

  // Check whether guest mode was previously selected.
  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  // Clear guest mode when switching to an account.
  static Future<void> endGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestKey);
  }
}