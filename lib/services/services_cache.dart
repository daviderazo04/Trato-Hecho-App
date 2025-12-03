import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local cache for service listings to speed up reloads.
class ServicesCache {
  String _keyForUser(int? userId) =>
      'services_cache_${userId != null ? userId.toString() : 'guest'}';

  Future<void> saveRaw(
      List<Map<String, dynamic>> services, int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(services);
    await prefs.setString(_keyForUser(userId), payload);
  }

  Future<List<Map<String, dynamic>>> loadRaw(int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForUser(userId));
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }
}
