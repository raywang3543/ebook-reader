import 'dart:ui' as ui;
import 'package:flutter/painting.dart';

class Pagination {
  /// Splits [text] into pages that fit within [pageWidth] x [pageHeight].
  static List<String> paginate({
    required String text,
    required double pageWidth,
    required double pageHeight,
    required TextStyle style,
  }) {
    if (text.isEmpty) return [''];
    if (pageWidth <= 0 || pageHeight <= 0) return [text];

    // Format paragraphs with Chinese-style indentation
    final formatted = text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => '\u3000\u3000${line.trim()}')
        .join('\n\n');

    final pages = <String>[];
    var remaining = formatted;

    while (remaining.isNotEmpty) {
      int lo = 1;
      int hi = remaining.length;

      // Binary search: find maximum characters that fit in one page
      while (lo < hi) {
        final mid = (lo + hi + 1) ~/ 2;
        if (_fits(remaining.substring(0, mid), pageWidth, pageHeight, style)) {
          lo = mid;
        } else {
          hi = mid - 1;
        }
      }

      // Safety: avoid infinite loop when even a single char doesn't fit
      if (lo == 0) lo = 1;

      pages.add(remaining.substring(0, lo));
      remaining = remaining.substring(lo).trimLeft();
    }

    return pages.isEmpty ? [formatted] : pages;
  }

  static bool _fits(
      String text, double width, double height, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
    );
    painter.layout(maxWidth: width);
    return painter.height <= height;
  }
}
