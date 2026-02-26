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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.list_rounded),
            tooltip: '目录',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Consumer<ReaderProvider>(
            builder: (_, provider, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.bookName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  provider.currentChapterTitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .appBarTheme
                          .foregroundColor
                          ?.withValues(alpha: 0.7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: '设置',
              onPressed: () =>
                  setState(() => _showSettings = !_showSettings),
            ),
          ],
        ),
        drawer: const TocDrawer(),
        body: Stack(
          children: [
            // Main content
            const _ReaderBody(),

            // Settings overlay backdrop
            if (_showSettings)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showSettings = false),
                  child: Container(color: Colors.black38),
                ),
              ),

            // Settings panel (slides from right)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
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

// ─────────────────────────────────────────────────────────────────────────────
// Main reading content area
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderBody extends StatelessWidget {
  const _ReaderBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final theme = Theme.of(context);

    // Determine text/background colors per theme
    final Color bgColor;
    final Color textColor;
    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1E1E1E);
        textColor = const Color(0xFFDDDDDD);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFF4E4C1);
        textColor = const Color(0xFF3D2B1F);
        break;
      case AppTheme.light:
        bgColor = Colors.white;
        textColor = const Color(0xFF1A1A1A);
    }

    return GestureDetector(
      // Tap left/right thirds to navigate pages
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
            const padding = EdgeInsets.fromLTRB(24, 16, 24, 16);
            final pageWidth =
                constraints.maxWidth - padding.left - padding.right;
            final pageHeight =
                constraints.maxHeight - padding.top - padding.bottom;

            // Update dimensions in provider (triggers repagination if changed)
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
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Page content
                  Expanded(
                    child: Text(
                      provider.currentPageContent,
                      style: TextStyle(
                        fontSize: provider.fontSize,
                        height: 1.8,
                        color: textColor,
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _ReaderNavBar extends StatelessWidget {
  const _ReaderNavBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: provider.progressPercent,
          minHeight: 3,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          valueColor:
              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),

        Container(
          height: 56,
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              // Previous page
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: provider.isFirstPage ? null : provider.prevPage,
                tooltip: '上一页',
              ),

              // Page info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${provider.currentPageNumber} / ${provider.totalPages}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '第 ${provider.currentChapter + 1} 章 / 共 ${provider.chapters.length} 章',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Next page
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
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
