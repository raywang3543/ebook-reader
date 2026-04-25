import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';
import '../widgets/settings_panel.dart';
import '../widgets/toc_drawer.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _showSettings = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final provider = context.read<ReaderProvider>();
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.space) {
      provider.nextPage();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      provider.prevPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: _FrostedAppBar(
          scaffoldKey: _scaffoldKey,
          onSettingsTap: () => setState(() => _showSettings = !_showSettings),
        ),
        drawer: const TocDrawer(),
        body: Stack(
          children: [
            const _ReaderBody(),

            // Floating back button
            Positioned(
              top: 110,
              left: 14,
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B2E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF1E1B2E).withValues(alpha: 0.30),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),

            // Settings backdrop
            if (_showSettings)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showSettings = false),
                  child: Container(color: Colors.black26),
                ),
              ),

            // Settings panel slides from right
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: _showSettings ? 0 : -300,
              width: 280,
              child: SettingsPanel(
                onClose: () => setState(() => _showSettings = false),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const _ReaderNavBar(),
      ),
    );
  }
}

// ─── Frosted-glass AppBar ────────────────────────────────────────────────────

class _FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback onSettingsTap;

  const _FrostedAppBar({
    required this.scaffoldKey,
    required this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final appTheme = provider.theme;

    final Color bgColor;
    final Color fgColor;
    final Color borderColor;

    switch (appTheme) {
      case AppTheme.dark:
        bgColor = const Color(0xCC1E1B2E);
        fgColor = const Color(0xFFFFF6EC);
        borderColor = const Color(0xFF3A3650);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xCCFFE8D6);
        fgColor = const Color(0xFF3D2B1F);
        borderColor = const Color(0x33E76F51);
        break;
      case AppTheme.light:
        bgColor = const Color(0xCCFFFFFF);
        fgColor = const Color(0xFF1E1B2E);
        borderColor = const Color(0x1A000000);
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // Drawer button
                  IconButton(
                    icon: Icon(Icons.list_rounded, color: fgColor, size: 22),
                    tooltip: '目录',
                    onPressed: () =>
                        scaffoldKey.currentState?.openDrawer(),
                  ),

                  // Title
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.bookName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: fgColor,
                            letterSpacing: 0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          provider.currentChapterTitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: fgColor.withValues(alpha: 0.55),
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Settings button
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: fgColor, size: 22),
                    tooltip: '设置',
                    onPressed: onSettingsTap,
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

// ─── Reading content area ─────────────────────────────────────────────────────

class _ReaderBody extends StatelessWidget {
  const _ReaderBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();

    final Color bgColor;
    final Color textColor;
    final Color titleColor;

    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1E1B2E);
        textColor = const Color(0xFFFFF6EC);
        titleColor = const Color(0xFFFFD23F);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFFFE8D6);
        textColor = const Color(0xFF3D2B1F);
        titleColor = const Color(0xFFE8362A);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFFFFFFF);
        textColor = const Color(0xFF1E1B2E);
        titleColor = const Color(0xFFFF5A4E);
    }

    return GestureDetector(
      onTapUp: (details) {
        final width = context.size?.width ?? 1;
        if (details.localPosition.dx < width / 3) {
          provider.prevPage();
        } else if (details.localPosition.dx > width * 2 / 3) {
          provider.nextPage();
        }
      },
      child: Container(
        color: bgColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.fromLTRB(28, 20, 28, 20);
            final pageWidth =
                constraints.maxWidth - padding.left - padding.right;
            final pageHeight =
                constraints.maxHeight - padding.top - padding.bottom;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<ReaderProvider>()
                  .setPageDimensions(pageWidth, pageHeight);
            });

            return Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter title
                  Text(
                    provider.currentChapterTitle,
                    style: TextStyle(
                      fontSize: provider.fontSize * 1.15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: 0,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 18),

                  // Page content
                  Expanded(
                    child: Text(
                      provider.currentPageContent,
                      style: TextStyle(
                        fontSize: provider.fontSize,
                        height: 1.85,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _ReaderNavBar extends StatelessWidget {
  const _ReaderNavBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();

    final Color bgColor;
    final Color fgColor;
    final Color subtleColor;
    final Color accentColor;
    final Color borderColor;

    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1E1B2E);
        fgColor = const Color(0xFFFFF6EC);
        subtleColor = const Color(0xFF8A8398);
        accentColor = const Color(0xFFFFD23F);
        borderColor = const Color(0xFF3A3650);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFFFE0CC);
        fgColor = const Color(0xFF3D2B1F);
        subtleColor = const Color(0xFFE8362A).withValues(alpha: 0.6);
        accentColor = const Color(0xFFE8362A);
        borderColor = const Color(0x33E76F51);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFFFFFFF);
        fgColor = const Color(0xFF1E1B2E);
        subtleColor = const Color(0xFF8A8398);
        accentColor = const Color(0xFFFF5A4E);
        borderColor = const Color(0x1A000000);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradient progress bar
        SizedBox(
          height: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: borderColor),
              FractionallySizedBox(
                widthFactor: provider.progressPercent.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, const Color(0xFFFFD23F)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Previous
              IconButton(
                icon: Icon(Icons.chevron_left_rounded, size: 28, color: fgColor),
                onPressed: provider.isFirstPage
                    ? null
                    : provider.prevPage,
                tooltip: '上一页',
              ),

              // Page info — center
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${provider.currentPageNumber} / ${provider.totalPages}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      '第 ${provider.currentChapter + 1} 章 / 共 ${provider.chapters.length} 章',
                      style: TextStyle(
                        fontSize: 11,
                        color: subtleColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Next
              IconButton(
                icon: Icon(Icons.chevron_right_rounded, size: 28, color: fgColor),
                onPressed: provider.isLastPage ? null : provider.nextPage,
                tooltip: '下一页',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
