import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'device_id_service.dart';

/// Talks to your own FastAPI/Gemma backend (the one from the original
/// iMama project). The base URL is baked in at build time (see
/// config/app_config.dart) — the end user never enters anything.
class ApiService {
  static String get _base => AppConfig.backendUrl;

  /// Sends a chat message, optionally with an attached image, to your
  /// FastAPI backend's /chat endpoint (multipart if an image is present,
  /// JSON otherwise). Includes user_id/conversation_id, which your
  /// backend requires for every request.
  static Future<String> sendChatMessage({
    required String message,
    File? image,
  }) async {
    if (_base.isEmpty) {
      throw Exception(
          'Samahani, huduma haipatikani kwa sasa. (Dev: missing --dart-define-from-file=env.json)');
    }

    final userId = await DeviceIdService.getUserId();
    final conversationId = await DeviceIdService.getConversationId();
    final uri = Uri.parse('$_base/chat');

    try {
      http.Response response;

      if (image != null) {
        final request = http.MultipartRequest('POST', uri)
          ..fields['message'] = message
          ..fields['user_id'] = userId
          ..fields['conversation_id'] = conversationId
          ..files.add(await http.MultipartFile.fromPath('image', image.path));
        final streamed = await request.send().timeout(const Duration(seconds: 60));
        response = await http.Response.fromStream(streamed);
      } else {
        response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'message': message,
                'user_id': userId,
                'conversation_id': conversationId,
              }),
            )
            .timeout(const Duration(seconds: 60));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['reply'] ?? data['response'] ?? '';
        return _cleanReply(text);
      } else if (response.statusCode == 422) {
        // FastAPI validation error — surface the actual missing/invalid
        // field so it's obvious during development instead of a generic message.
        throw Exception('Ombi halikubaliki na seva (422): ${response.body}');
      } else {
        throw Exception('Hitilafu ya seva (${response.statusCode}): ${response.body}');
      }
    } on SocketException {
      throw Exception('Imeshindikana kuunganisha na mtandao. Angalia intaneti yako.');
    }
  }

  /// Strips model-specific special tokens (e.g. Gemma's <end_of_turn>)
  /// that shouldn't be shown to users.
  static String _cleanReply(String text) {
    return text
        .replaceAll('<end_of_turn>', '')
        .replaceAll('<start_of_turn>', '')
        .trim();
  }

  /// Health check against your backend's /health route.
  static Future<bool> ping() async {
    if (_base.isEmpty) return false;
    try {
      final response = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}