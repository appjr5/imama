import 'package:flutter/material.dart';

/// Renders text containing **bold** markers as actual bold spans instead
/// of showing the literal asterisks. Only handles **bold** — nothing
/// fancier (no italics, links, etc.) since that's all the model tends
/// to produce.
class BoldText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const BoldText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}
