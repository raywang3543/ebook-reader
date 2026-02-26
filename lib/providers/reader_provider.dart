import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chapter.dart';
import '../utils/chapter_parser.dart';
import '../utils/pagination.dart';

enum AppTheme { light, dark, sepia }

class ReaderProvider extends ChangeNotifier {
  // ── Book state ──────────────────────────────────────────────────────────
  String _bookName = '';
  List<Chapter> _chapters = [];
  int _currentChapter = 0;
  int _currentPage = 0;
  List<List<String>> _paginatedChapters = [];

  // ── Settings ────────────────────────────────────────────────────────────
  double _fontSize = 18.0;
  AppTheme _theme = AppTheme.light;

  // ── Audio ────────────────────────────────────────────────────────────────
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  double _musicVolume = 0.5;
  bool _hasMusicLoaded = false;

  // ── Page dimensions (set by LayoutBuilder in the reader widget) ──────────
  double _pageWidth = 0;
  double _pageHeight = 0;

  // ── Getters ──────────────────────────────────────────────────────────────
  String get bookName => _bookName;
  List<Chapter> get chapters => _chapters;
  int get currentChapter => _currentChapter;
  int get currentPage => _currentPage;
  double get fontSize => _fontSize;
  AppTheme get theme => _theme;
  bool get isMusicPlaying => _isMusicPlaying;
  double get musicVolume => _musicVolume;
  bool get hasMusicLoaded => _hasMusicLoaded;
  bool get hasBook => _chapters.isNotEmpty;

  String get currentChapterTitle =>
      _chapters.isNotEmpty ? _chapters[_currentChapter].title : '';

  String get currentPageContent {
    if (_paginatedChapters.isEmpty ||
        _currentChapter >= _paginatedChapters.length) {
      return _chapters.isNotEmpty ? _chapters[_currentChapter].content : '';
    }
    final pages = _paginatedChapters[_currentChapter];
    if (pages.isEmpty || _currentPage >= pages.length) return '';
    return pages[_currentPage];
  }

  int get totalPages {
    if (_paginatedChapters.isEmpty ||
        _currentChapter >= _paginatedChapters.length) {
      return 1;
    }
    return _paginatedChapters[_currentChapter].length;
  }

  int get currentPageNumber => _currentPage + 1;

  double get progressPercent {
    if (_chapters.isEmpty) return 0;
    return (_currentChapter + 1) / _chapters.length;
  }

  bool get isFirstPage => _currentChapter == 0 && _currentPage == 0;

  bool get isLastPage {
    if (_paginatedChapters.isEmpty) return true;
    final lastChapter = _chapters.length - 1;
    final lastPage =
        (_paginatedChapters.isNotEmpty && lastChapter < _paginatedChapters.length)
            ? _paginatedChapters[lastChapter].length - 1
            : 0;
    return _currentChapter == lastChapter && _currentPage == lastPage;
  }

  ReaderProvider() {
    _loadSettings();
  }

  // ── Book loading ─────────────────────────────────────────────────────────
  Future<void> loadBookFromPath(String path, String name) async {
    try {
      final file = File(path);
      final content = await file.readAsString(encoding: utf8);
      await _initBook(content, name);
    } catch (e) {
      debugPrint('Error loading book: $e');
    }
  }

  Future<void> loadBookFromBytes(Uint8List bytes, String name) async {
    try {
      final content = utf8.decode(bytes);
      await _initBook(content, name);
    } catch (e) {
      debugPrint('Error loading book from bytes: $e');
    }
  }

  Future<void> _initBook(String content, String name) async {
    _bookName = name;
    _chapters = ChapterParser.parse(content);
    _currentChapter = 0;
    _currentPage = 0;
    _paginatedChapters = [];
    notifyListeners();
    await _loadProgress();
  }

  // ── Page dimensions / pagination ─────────────────────────────────────────
  void setPageDimensions(double width, double height) {
    if ((width - _pageWidth).abs() > 1 || (height - _pageHeight).abs() > 1) {
      _pageWidth = width;
      _pageHeight = height;
      _recalculatePages();
    }
  }

  void _recalculatePages() {
    if (_chapters.isEmpty || _pageWidth <= 0 || _pageHeight <= 0) return;

    final style = TextStyle(fontSize: _fontSize, height: 1.8);
    _paginatedChapters = _chapters.map((chapter) {
      return Pagination.paginate(
        text: chapter.content,
        pageWidth: _pageWidth,
        pageHeight: _pageHeight,
        style: style,
      );
    }).toList();

    // Clamp current page to valid range
    if (_currentChapter < _paginatedChapters.length) {
      final pages = _paginatedChapters[_currentChapter];
      if (_currentPage >= pages.length) {
        _currentPage = (pages.length - 1).clamp(0, pages.length);
      }
    }

    notifyListeners();
  }

  // ── Navigation ───────────────────────────────────────────────────────────
  void nextPage() {
    if (_paginatedChapters.isEmpty) return;
    final pages = _paginatedChapters[_currentChapter];
    if (_currentPage < pages.length - 1) {
      _currentPage++;
    } else if (_currentChapter < _chapters.length - 1) {
      _currentChapter++;
      _currentPage = 0;
    }
    _saveProgress();
    notifyListeners();
  }

  void prevPage() {
    if (_paginatedChapters.isEmpty) return;
    if (_currentPage > 0) {
      _currentPage--;
    } else if (_currentChapter > 0) {
      _currentChapter--;
      if (_currentChapter < _paginatedChapters.length) {
        _currentPage =
            (_paginatedChapters[_currentChapter].length - 1).clamp(0, 999999);
      }
    }
    _saveProgress();
    notifyListeners();
  }

  void jumpToChapter(int index) {
    if (index >= 0 && index < _chapters.length) {
      _currentChapter = index;
      _currentPage = 0;
      _saveProgress();
      notifyListeners();
    }
  }

  // ── Settings ─────────────────────────────────────────────────────────────
  void changeFontSize(double size) {
    _fontSize = size.clamp(12.0, 32.0);
    _recalculatePages();
    _saveSettings();
    notifyListeners();
  }

  void changeTheme(AppTheme theme) {
    _theme = theme;
    _saveSettings();
    notifyListeners();
  }

  // ── Audio ─────────────────────────────────────────────────────────────────
  String? _musicError;
  String? get musicError => _musicError;

  Future<bool> loadMusic(String path) async {
    try {
      await _audioPlayer.setSourceDeviceFile(path);
      await _audioPlayer.setVolume(_musicVolume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _hasMusicLoaded = true;
      _musicError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _musicError = '不支持的音频格式，请使用 mp3/flac/wav 等标准格式';
      debugPrint('loadMusic error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadMusicFromBytes(Uint8List bytes) async {
    try {
      await _audioPlayer.setSourceBytes(bytes);
      await _audioPlayer.setVolume(_musicVolume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _hasMusicLoaded = true;
      _musicError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _musicError = '不支持的音频格式，请使用 mp3/flac/wav 等标准格式';
      debugPrint('loadMusicFromBytes error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
      _isMusicPlaying = false;
    } else {
      await _audioPlayer.resume();
      _isMusicPlaying = true;
    }
    notifyListeners();
  }

  Future<void> changeVolume(double volume) async {
    _musicVolume = volume;
    await _audioPlayer.setVolume(volume);
    _saveSettings();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setInt('theme', _theme.index);
    await prefs.setDouble('musicVolume', _musicVolume);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 18.0;
    final themeIndex = prefs.getInt('theme') ?? 0;
    _theme = AppTheme.values[themeIndex.clamp(0, AppTheme.values.length - 1)];
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    if (_bookName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'progress_${_bookName.replaceAll(RegExp(r'[^\w]'), '_')}';
    final data = json.encode({
      'bookName': _bookName,
      'currentChapter': _currentChapter,
      'currentPage': _currentPage,
    });
    await prefs.setString(key, data);
  }

  Future<void> _loadProgress() async {
    if (_bookName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'progress_${_bookName.replaceAll(RegExp(r'[^\w]'), '_')}';
    final raw = prefs.getString(key);
    if (raw != null) {
      try {
        final map = json.decode(raw) as Map<String, dynamic>;
        final savedChapter = (map['currentChapter'] as int?) ?? 0;
        final savedPage = (map['currentPage'] as int?) ?? 0;
        if (savedChapter < _chapters.length) {
          _currentChapter = savedChapter;
          _currentPage = savedPage;
        }
      } catch (e) {
        debugPrint('Error loading progress: $e');
      }
    }
    notifyListeners();
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _bookName = '';
    _chapters = [];
    _currentChapter = 0;
    _currentPage = 0;
    _paginatedChapters = [];
    await _audioPlayer.stop();
    _isMusicPlaying = false;
    _hasMusicLoaded = false;
    await _loadSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
