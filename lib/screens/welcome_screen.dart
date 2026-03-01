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
  // 原生平台使用 path，Web 平台使用 bytes
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
        const SnackBar(
          content: Text('⚠️ 音频加载失败，请使用 mp3/flac/wav 等标准格式'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  Text(
                    '电子书阅读器',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '上传您的小说文件，随时随地开始阅读',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Book upload
                  _UploadCard(
                    icon: Icons.menu_book_rounded,
                    title: '选择小说文件',
                    subtitle: _bookName ?? '支持 .txt 格式',
                    onTap: _pickBook,
                    isSelected: _bookReady,
                  ),
                  const SizedBox(height: 16),

                  // Music upload (optional)
                  _UploadCard(
                    icon: Icons.music_note_rounded,
                    title: '添加背景音乐（可选）',
                    subtitle: _musicName ?? '支持 mp3、ogg、wav 等格式',
                    onTap: _pickMusic,
                    isSelected: kIsWeb ? _musicBytes != null : _musicPath != null,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          _bookReady && !_isLoading ? _startReading : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('开始阅读',
                              style: TextStyle(fontSize: 17)),
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.withValues(alpha: 0.35),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected ? primary : Colors.grey, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
