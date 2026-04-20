import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();

    final Color bgColor;
    final Color surfaceColor;
    final Color primaryText;
    final Color secondaryText;
    final Color separatorColor;
    final Color accentColor;

    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1C1C1E);
        surfaceColor = const Color(0xFF2C2C2E);
        primaryText = const Color(0xFFFFFFFF);
        secondaryText = const Color(0xFF8E8E93);
        separatorColor = const Color(0xFF38383A);
        accentColor = const Color(0xFF2997FF);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFEED9A8);
        surfaceColor = const Color(0xFFF4E4C1);
        primaryText = const Color(0xFF3D2B1F);
        secondaryText = const Color(0xFF8B6914).withValues(alpha: 0.7);
        separatorColor = const Color(0x33D4A853);
        accentColor = const Color(0xFF8B6914);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFF5F5F7);
        surfaceColor = const Color(0xFFFFFFFF);
        primaryText = const Color(0xFF1D1D1F);
        secondaryText = const Color(0xFF8E8E93);
        separatorColor = const Color(0x1A000000);
        accentColor = const Color(0xFF0071E3);
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Material(
          color: bgColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: separatorColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: secondaryText, size: 20),
                        onPressed: onClose,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              secondaryText.withValues(alpha: 0.12),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      // ── THEME ──────────────────────────────────────────
                      _SectionHeader(label: '主题', color: secondaryText),
                      _GroupCard(
                        surfaceColor: surfaceColor,
                        separatorColor: separatorColor,
                        children: [
                          _ThemeRow(
                            label: '浅色',
                            appTheme: AppTheme.light,
                            bgColor: const Color(0xFFFFFFFF),
                            textColor: const Color(0xFF1D1D1F),
                            dotColor: const Color(0xFF0071E3),
                            primaryText: primaryText,
                            accentColor: accentColor,
                            separatorColor: separatorColor,
                            isLast: false,
                          ),
                          _ThemeRow(
                            label: '深色',
                            appTheme: AppTheme.dark,
                            bgColor: const Color(0xFF1C1C1E),
                            textColor: const Color(0xFFFFFFFF),
                            dotColor: const Color(0xFF2997FF),
                            primaryText: primaryText,
                            accentColor: accentColor,
                            separatorColor: separatorColor,
                            isLast: false,
                          ),
                          _ThemeRow(
                            label: '米黄',
                            appTheme: AppTheme.sepia,
                            bgColor: const Color(0xFFF4E4C1),
                            textColor: const Color(0xFF3D2B1F),
                            dotColor: const Color(0xFF8B6914),
                            primaryText: primaryText,
                            accentColor: accentColor,
                            separatorColor: separatorColor,
                            isLast: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── FONT SIZE ──────────────────────────────────────
                      _SectionHeader(label: '字体大小', color: secondaryText),
                      _GroupCard(
                        surfaceColor: surfaceColor,
                        separatorColor: separatorColor,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '文字大小',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: primaryText,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    Text(
                                      '${provider.fontSize.round()} pt',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryText,
                                        letterSpacing: -0.224,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('A',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: secondaryText)),
                                    Expanded(
                                      child: Slider(
                                        value: provider.fontSize,
                                        min: 12,
                                        max: 32,
                                        divisions: 20,
                                        activeColor: accentColor,
                                        inactiveColor:
                                            separatorColor,
                                        onChanged: (v) => context
                                            .read<ReaderProvider>()
                                            .changeFontSize(v),
                                      ),
                                    ),
                                    Text('A',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: secondaryText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── MUSIC ──────────────────────────────────────────
                      _SectionHeader(label: '背景音乐', color: secondaryText),
                      _GroupCard(
                        surfaceColor: surfaceColor,
                        separatorColor: separatorColor,
                        children: [
                          if (!provider.hasMusicLoaded)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              child: Text(
                                '未加载音乐文件',
                                style: TextStyle(
                                    fontSize: 15, color: secondaryText),
                              ),
                            )
                          else ...[
                            // Play / Pause row
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    context.read<ReaderProvider>().toggleMusic(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  child: Row(
                                    children: [
                                      Icon(
                                        provider.isMusicPlaying
                                            ? Icons.pause_circle_rounded
                                            : Icons.play_circle_rounded,
                                        color: accentColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        provider.isMusicPlaying ? '暂停播放' : '播放音乐',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: primaryText,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                                height: 0.5,
                                thickness: 0.5,
                                indent: 18,
                                color: separatorColor),
                            // Volume row
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 14, 18, 10),
                              child: Row(
                                children: [
                                  Icon(Icons.volume_down_rounded,
                                      size: 18, color: secondaryText),
                                  Expanded(
                                    child: Slider(
                                      value: provider.musicVolume,
                                      min: 0,
                                      max: 1,
                                      activeColor: accentColor,
                                      inactiveColor: separatorColor,
                                      onChanged: (v) => context
                                          .read<ReaderProvider>()
                                          .changeVolume(v),
                                    ),
                                  ),
                                  Icon(Icons.volume_up_rounded,
                                      size: 18, color: secondaryText),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── DATA ───────────────────────────────────────────
                      _SectionHeader(label: '数据管理', color: secondaryText),
                      _GroupCard(
                        surfaceColor: surfaceColor,
                        separatorColor: separatorColor,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _confirmClear(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline_rounded,
                                        color: Color(0xFFFF3B30), size: 20),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '清除所有数据',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFFF3B30),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.chevron_right_rounded,
                                        color: secondaryText.withValues(alpha: 0.5),
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '清除所有数据',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        content: const Text(
          '将清除所有阅读进度和设置，此操作不可撤销。',
          style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消',
                style: TextStyle(color: Color(0xFF0071E3))),
          ),
          TextButton(
            onPressed: () {
              context.read<ReaderProvider>().clearData();
              Navigator.of(ctx).pop();
              onClose();
            },
            child: const Text(
              '清除',
              style: TextStyle(
                  color: Color(0xFFFF3B30), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Color surfaceColor;
  final Color separatorColor;
  final List<Widget> children;

  const _GroupCard({
    required this.surfaceColor,
    required this.separatorColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String label;
  final AppTheme appTheme;
  final Color bgColor;
  final Color textColor;
  final Color dotColor;
  final Color primaryText;
  final Color accentColor;
  final Color separatorColor;
  final bool isLast;

  const _ThemeRow({
    required this.label,
    required this.appTheme,
    required this.bgColor,
    required this.textColor,
    required this.dotColor,
    required this.primaryText,
    required this.accentColor,
    required this.separatorColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final isSelected = provider.theme == appTheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                context.read<ReaderProvider>().changeTheme(appTheme),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  // Color preview swatch
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0x1A000000), width: 0.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_rounded, color: accentColor, size: 20),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
              height: 0.5,
              thickness: 0.5,
              indent: 60,
              color: separatorColor),
      ],
    );
  }
}
