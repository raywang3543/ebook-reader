import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _bookPath;
  Uint8List? _bookBytes;
  String? _bookName;

  String? _musicPath;
  Uint8List? _musicBytes;
  String? _musicName;

  bool _isLoading = false;

  bool get _bookReady => kIsWeb ? _bookBytes != null : _bookPath != null;

  Future<void> _pickBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: kIsWeb,
    );
    if (result == null) return;
    final file = result.files.single;
    setState(() {
      _bookName = file.name;
      if (kIsWeb) {
        _bookBytes = file.bytes;
        _bookPath = null;
      } else {
        _bookPath = file.path;
        _bookBytes = null;
      }
    });
  }

  Future<void> _pickMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: kIsWeb,
    );
    if (result == null) return;
    final file = result.files.single;
    setState(() {
      _musicName = file.name;
      if (kIsWeb) {
        _musicBytes = file.bytes;
        _musicPath = null;
      } else {
        _musicPath = file.path;
        _musicBytes = null;
      }
    });
  }

  Future<void> _startReading() async {
    if (!_bookReady) return;
    setState(() => _isLoading = true);

    final provider = context.read<ReaderProvider>();

    if (kIsWeb) {
      await provider.loadBookFromBytes(_bookBytes!, _bookName!);
    } else {
      await provider.loadBookFromPath(_bookPath!, _bookName!);
    }

    bool musicOk = true;
    if (kIsWeb && _musicBytes != null) {
      musicOk = await provider.loadMusicFromBytes(_musicBytes!);
    } else if (!kIsWeb && _musicPath != null) {
      musicOk = await provider.loadMusic(_musicPath!);
    }
    if (!musicOk && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('音频加载失败，请使用 mp3/flac/wav 等标准格式'),
          backgroundColor: const Color(0xFF1D1D1F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 30,
                          offset: Offset(3, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.book_rounded,
                      size: 46,
                      color: Color(0xFF0071E3),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Headline — SF Pro Display style: tight, bold
                  const Text(
                    '电子书阅读器',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                      letterSpacing: -1.0,
                      height: 1.10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '上传您的小说文件，开始沉浸式阅读',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0x99000000),
                      height: 1.47,
                      letterSpacing: -0.374,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 52),

                  // Upload cards
                  _UploadCard(
                    icon: Icons.book_outlined,
                    title: '选择小说文件',
                    subtitle: _bookName ?? '支持 TXT 格式',
                    onTap: _pickBook,
                    isSelected: _bookReady,
                  ),
                  const SizedBox(height: 10),
                  _UploadCard(
                    icon: Icons.music_note_outlined,
                    title: '添加背景音乐',
                    subtitle: _musicName ?? '可选 · 支持 MP3、WAV、OGG',
                    onTap: _pickMusic,
                    isSelected:
                        kIsWeb ? _musicBytes != null : _musicPath != null,
                  ),

                  const SizedBox(height: 40),

                  // Primary CTA — Apple Blue, 12px radius
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _bookReady && !_isLoading ? _startReading : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0071E3),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF0071E3).withValues(alpha: 0.3),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '开始阅读',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.374,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: const Color(0xFF0071E3), width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF0071E3).withValues(alpha: 0.06),
          highlightColor: const Color(0xFF0071E3).withValues(alpha: 0.04),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0071E3).withValues(alpha: 0.10)
                        : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? const Color(0xFF0071E3)
                        : const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF0071E3)
                              : const Color(0xFF1D1D1F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status icon
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  size: 22,
                  color: isSelected
                      ? const Color(0xFF0071E3)
                      : const Color(0xFFD1D1D6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
