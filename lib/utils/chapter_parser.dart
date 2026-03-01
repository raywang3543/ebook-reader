import '../models/chapter.dart';

class ChapterParser {
  static final List<RegExp> _patterns = [
    RegExp(r'^(第[一二三四五六七八九十百千万零\d]+[章节卷][^\S\n]*[^\n]{0,40})', multiLine: true),
    RegExp(r'^(Chapter\s+\d+[^\S\n]*[^\n]{0,40})', multiLine: true, caseSensitive: false),
    RegExp(r'^(\d+[\.、][^\S\n]+[^\n]{1,30})$', multiLine: true),
    RegExp(r'^(前言|楔子|序章|后记|尾声|序言|引子|正文)[^\n]*', multiLine: true),
  ];

  static List<Chapter> parse(String text) {
    RegExp? matched;
    for (final pattern in _patterns) {
      if (pattern.hasMatch(text)) {
        matched = pattern;
        break;
      }
    }

    if (matched == null) {
      return [Chapter(title: '正文', content: text.trim())];
    }

    final matches = matched.allMatches(text).toList();
    if (matches.isEmpty) {
      return [Chapter(title: '正文', content: text.trim())];
    }

    final chapters = <Chapter>[];

    // Content before first chapter
    final preContent = text.substring(0, matches.first.start).trim();
    if (preContent.isNotEmpty) {
      chapters.add(Chapter(title: '序言', content: preContent));
    }

    for (int i = 0; i < matches.length; i++) {
      final title = matches[i].group(0)!.trim();
      final start = matches[i].end;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final content = text.substring(start, end).trim();
      chapters.add(Chapter(title: title, content: content));
    }

    return chapters;
  }
}
