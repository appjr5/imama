import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class _Chunk {
  final String source;
  final String text;
  final List<String> tokens; // pre-tokenised for BM25
  _Chunk({required this.source, required this.text, required this.tokens});
}

class RagService {
  static List<_Chunk>? _chunks;
  static bool _loading = false;

  // BM25 hyper-parameters
  static const double _k1 = 1.5;
  static const double _b = 0.75;
  static const int _topK = 3;
  static const int _maxContextChars = 900; // chars per chunk injected into prompt

  // Common Swahili + English stop words
  static const _stopWords = {
    'na', 'ya', 'wa', 'kwa', 'ni', 'la', 'za', 'au', 'hii', 'hizi',
    'hiyo', 'hilo', 'ile', 'ule', 'vile', 'ambayo', 'ambavyo',
    'ambalo', 'kuwa', 'katika', 'pia', 'sana', 'hata', 'lakini',
    'ama', 'bali', 'kama', 'ili', 'kwamba', 'kutoka', 'pamoja',
    'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'shall', 'can', 'of', 'in', 'on', 'at',
    'to', 'for', 'with', 'by', 'from', 'as', 'it', 'its', 'this', 'that',
    'and', 'or', 'not', 'but', 'if', 'so', 'than',
  };

  static Future<void> ensureLoaded() async {
    if (_chunks != null || _loading) return;
    _loading = true;
    try {
      final raw = await rootBundle.loadString('assets/rag_kb.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _chunks = list.map((e) {
        final map = e as Map<String, dynamic>;
        final text = map['t'] as String;
        return _Chunk(
          source: map['s'] as String? ?? '',
          text: text,
          tokens: _tokenise(text),
        );
      }).toList();
    } finally {
      _loading = false;
    }
  }

  static List<String> _tokenise(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .toList();
  }

  /// Returns Swahili-formatted context string to prepend to the user prompt.
  /// Returns empty string if knowledge base not loaded or no relevant chunk found.
  static String retrieve(String query) {
    final chunks = _chunks;
    if (chunks == null || chunks.isEmpty) return '';

    final queryTokens = _tokenise(query);
    if (queryTokens.isEmpty) return '';

    // Compute IDF for query tokens across corpus
    final n = chunks.length.toDouble();
    final idf = <String, double>{};
    for (final qt in queryTokens) {
      final df = chunks.where((c) => c.tokens.contains(qt)).length;
      idf[qt] = log((n - df + 0.5) / (df + 0.5) + 1);
    }

    // Compute average document length
    final avgdl = chunks.fold(0.0, (s, c) => s + c.tokens.length) / n;

    // BM25 score each chunk
    final scores = List<double>.filled(chunks.length, 0);
    for (int i = 0; i < chunks.length; i++) {
      final c = chunks[i];
      final dl = c.tokens.length.toDouble();
      for (final qt in queryTokens) {
        final tf = c.tokens.where((t) => t == qt).length.toDouble();
        if (tf == 0) continue;
        final idfVal = idf[qt] ?? 0;
        scores[i] += idfVal * (tf * (_k1 + 1)) / (tf + _k1 * (1 - _b + _b * dl / avgdl));
      }
    }

    // Pick top-K
    final indices = List<int>.generate(chunks.length, (i) => i);
    indices.sort((a, b) => scores[b].compareTo(scores[a]));
    final top = indices.take(_topK).where((i) => scores[i] > 0).toList();

    if (top.isEmpty) return '';

    final buf = StringBuffer('Taarifa kutoka nyaraka za afya:\n');
    for (final i in top) {
      final c = chunks[i];
      final snippet = c.text.length > _maxContextChars
          ? '${c.text.substring(0, _maxContextChars)}...'
          : c.text;
      buf.write('[${c.source}]: $snippet\n\n');
    }
    return buf.toString().trimRight();
  }
}
