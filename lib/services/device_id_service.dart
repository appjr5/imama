import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Generates and persists a stable per-device user_id and conversation_id,
/// since there's no login system — the backend uses these to track the
/// same "user" and conversation thread across app opens.
class DeviceIdService {
  static const _userIdKey = 'device_user_id';
  static const _conversationIdKey = 'device_conversation_id';

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_userIdKey);
    if (id == null) {
      id = _generateId('user');
      await prefs.setString(_userIdKey, id);
    }
    return id;
  }

  static Future<String> getConversationId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_conversationIdKey);
    if (id == null) {
      id = _generateId('conv');
      await prefs.setString(_conversationIdKey, id);
    }
    return id;
  }

  /// Starts a brand-new conversation thread (e.g. if you add a
  /// "start new chat" button later). Not currently wired to any UI.
  static Future<String> resetConversation() async {
    final prefs = await SharedPreferences.getInstance();
    final id = _generateId('conv');
    await prefs.setString(_conversationIdKey, id);
    return id;
  }

  static String _generateId(String prefix) {
    final rand = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = List.generate(6, (_) => rand.nextInt(36).toRadixString(36)).join();
    return '${prefix}_${timestamp}_$suffix';
  }
}