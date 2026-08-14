import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/blog_post.dart';
import '../models/content_category.dart';
import 'gemma_service.dart';

/// Generates one new "tip of the day" post per calendar day, caching it
/// locally so it only generates once per day rather than on every app
/// open. Keeps a rolling history of recent posts for the home screen list.
class BlogService {
  static const _postsKey = 'blog_posts';
  static const _maxHistory = 14;

  static String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<List<BlogPost>> getPosts() async {
    final posts = await _loadPosts();
    final hasToday = posts.any((p) => p.date == _todayKey);

    if (!hasToday) {
      try {
        final newPost = await _generateTodayPost();
        posts.insert(0, newPost);
        final trimmed = posts.take(_maxHistory).toList();
        await _savePosts(trimmed);
        return trimmed;
      } catch (_) {
        return posts;
      }
    }
    return posts;
  }

  static Future<BlogPost> _generateTodayPost() async {
    final prompt =
        'Andika kidokezo kifupi cha leo ($_todayKey) kwa mama mjamzito kuhusu '
        'lishe, chakula, usingizi, au mazoezi. Jibu kwa muundo huu hasa, bila '
        'maelezo mengine:\nKICHWA: [kichwa kifupi]\nMAELEZO: [aya moja fupi, '
        'maneno 40-70]';

    final reply = await GemmaService.sendChatMessage(message: prompt);

    final titleMatch = RegExp(r'KICHWA:\s*(.+)').firstMatch(reply);
    final bodyMatch = RegExp(r'MAELEZO:\s*(.+)', dotAll: true).firstMatch(reply);

    final title = titleMatch?.group(1)?.trim() ?? 'Kidokezo cha Leo';
    final body = bodyMatch?.group(1)?.trim() ?? reply.trim();

    return BlogPost(
      date: _todayKey,
      title: title,
      body: body,
      category: ContentCategory.fromKeywords('$title $body'),
    );
  }

  static Future<List<BlogPost>> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_postsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => BlogPost.fromJson(e)).toList();
  }

  static Future<void> _savePosts(List<BlogPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_postsKey, jsonEncode(posts.map((p) => p.toJson()).toList()));
  }
}
