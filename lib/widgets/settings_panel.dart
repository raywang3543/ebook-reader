import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.fromLTRB(16, 48, 8, 12),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('设置',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme
                  const _SectionTitle('主题模式'),
                  Row(
                    children: [
                      _ThemeChip(
                        label: '浅色',
                        appTheme: AppTheme.light,
                        bgColor: Colors.white,
                        textColor: Colors.black87,
                        borderColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: '深色',
                        appTheme: AppTheme.dark,
                        bgColor: const Color(0xFF1E1E1E),
                        textColor: Colors.white70,
                        borderColor: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: '米黄',
                        appTheme: AppTheme.sepia,
                        bgColor: const Color(0xFFF4E4C1),
                        textColor: const Color(0xFF6B4C11),
                        borderColor: const Color(0xFFD4A853),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Font size
                  const _SectionTitle('字体大小'),
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 16),
                      Expanded(
                        child: Slider(
                          value: provider.fontSize,
                          min: 12,
                          max: 32,
                          divisions: 20,
                          label: provider.fontSize.round().toString(),
                          onChanged: (v) =>
                              context.read<ReaderProvider>().changeFontSize(v),
                        ),
                      ),
                      const Icon(Icons.text_fields, size: 24),
                    ],
                  ),
                  Center(
                    child: Text(
                      '${provider.fontSize.round()} px',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Music controls
                  const _SectionTitle('背景音乐'),
                  if (!provider.hasMusicLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('未加载音乐文件',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    )
                  else ...[
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(provider.isMusicPlaying
                              ? Icons.pause
                              : Icons.play_arrow),
                          label: Text(
                              provider.isMusicPlaying ? '暂停' : '播放'),
                          onPressed: () =>
                              context.read<ReaderProvider>().toggleMusic(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.volume_down, size: 18),
                        Expanded(
                          child: Slider(
                            value: provider.musicVolume,
                            min: 0,
                            max: 1,
                            onChanged: (v) =>
                                context.read<ReaderProvider>().changeVolume(v),
                          ),
                        ),
                        const Icon(Icons.volume_up, size: 18),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Clear data
                  const _SectionTitle('数据管理'),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('清除所有数据',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => _confirmClear(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('将清除所有阅读进度和设置，确定吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消')),
          TextButton(
            onPressed: () {
              context.read<ReaderProvider>().clearData();
              Navigator.of(ctx).pop();
              onClose();
            },
            child:
                const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final AppTheme appTheme;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _ThemeChip({
    required this.label,
    required this.appTheme,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final isSelected = provider.theme == appTheme;

    return GestureDetector(
      onTap: () => context.read<ReaderProvider>().changeTheme(appTheme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(color: textColor, fontSize: 13)),
      ),
    );
  }
}
