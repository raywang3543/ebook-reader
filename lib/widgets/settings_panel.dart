import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class SettingsPanel extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.onClose});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _eqCtrl;

  @override
  void initState() {
    super.initState();
    _eqCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _eqCtrl.dispose();
    super.dispose();
  }

  VoidCallback get onClose => widget.onClose;

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
        bgColor = const Color(0xFF1E1B2E);
        surfaceColor = const Color(0xFF2A273A);
        primaryText = const Color(0xFFFFF6EC);
        secondaryText = const Color(0xFF8A8398);
        separatorColor = const Color(0xFF3A3650);
        accentColor = const Color(0xFFFFD23F);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFFFE0CC);
        surfaceColor = const Color(0xFFFFE8D6);
        primaryText = const Color(0xFF3D2B1F);
        secondaryText = const Color(0xFFE8362A).withValues(alpha: 0.7);
        separatorColor = const Color(0x33E76F51);
        accentColor = const Color(0xFFE8362A);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFFFF6EC);
        surfaceColor = const Color(0xFFFFFFFF);
        primaryText = const Color(0xFF1E1B2E);
        secondaryText = const Color(0xFF8A8398);
        separatorColor = const Color(0x1A000000);
        accentColor = const Color(0xFFFF5A4E);
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
                  padding: const EdgeInsets.fromLTRB(22, 16, 10, 16),
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
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                        onPressed: onClose,
                        style: IconButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(36, 36),
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
                            dotColor: const Color(0xFFFF5A4E),
                            primaryText: primaryText,
                            accentColor: accentColor,
                            separatorColor: separatorColor,
                            isLast: false,
                          ),
                          _ThemeRow(
                            label: '深色',
                            appTheme: AppTheme.dark,
                            bgColor: const Color(0xFF1E1B2E),
                            dotColor: const Color(0xFFFFD23F),
                            primaryText: primaryText,
                            accentColor: accentColor,
                            separatorColor: separatorColor,
                            isLast: false,
                          ),
                          _ThemeRow(
                            label: '米黄',
                            appTheme: AppTheme.sepia,
                            bgColor: const Color(0xFFFFE8D6),
                            dotColor: const Color(0xFFE8362A),
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
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        '${provider.fontSize.round()} pt',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                        ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              child: Row(
                                children: [
                                  // Gradient play button
                                  GestureDetector(
                                    onTap: () => context
                                        .read<ReaderProvider>()
                                        .toggleMusic(),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF7C5CFF),
                                            accentColor,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: provider.isMusicPlaying
                                            ? [
                                                BoxShadow(
                                                  color: accentColor
                                                      .withValues(alpha: 0.33),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 6),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        provider.isMusicPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '背景音乐',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: primaryText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        if (provider.isMusicPlaying)
                                          Row(
                                            children: [
                                              _EqBars(
                                                  controller: _eqCtrl,
                                                  color: accentColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                '正在播放',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryText),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            '已暂停',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryText),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                        color: Color(0xFFFF6B6B), size: 20),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '清除所有数据',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFFF6B6B),
                                        letterSpacing: 0,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '清除所有数据',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        ),
        content: const Text(
          '将清除所有阅读进度和设置，此操作不可撤销。',
          style: TextStyle(fontSize: 14, color: Color(0xFF8C8594)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消',
                style: TextStyle(color: Color(0xFFFF7A5C), fontWeight: FontWeight.w600)),
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
                  color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────────────────────

class _EqBars extends StatelessWidget {
  final AnimationController controller;
  final Color color;

  const _EqBars({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final h1 = 4.0 + t * 6.0;
        final h2 = 8.0 - t * 5.0;
        final h3 = 5.0 + t * 4.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(height: h1, color: color),
            const SizedBox(width: 2),
            _Bar(height: h2, color: color),
            const SizedBox(width: 2),
            _Bar(height: h3, color: color),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

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
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.2,
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
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
  final Color dotColor;
  final Color primaryText;
  final Color accentColor;
  final Color separatorColor;
  final bool isLast;

  const _ThemeRow({
    required this.label,
    required this.appTheme,
    required this.bgColor,
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
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
                      letterSpacing: 0,
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
              indent: 62,
              color: separatorColor),
      ],
    );
  }
}
