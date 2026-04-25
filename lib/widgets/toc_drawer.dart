import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class TocDrawer extends StatelessWidget {
  const TocDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();

    final Color bgColor;
    final Color primaryText;
    final Color secondaryText;
    final Color accentColor;
    final Color activeRowBg;
    final Color separatorColor;

    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1E1B2E);
        primaryText = const Color(0xFFFFF6EC);
        secondaryText = const Color(0xFF8A8398);
        accentColor = const Color(0xFFFFD23F);
        activeRowBg = const Color(0xFFFFD23F).withValues(alpha: 0.10);
        separatorColor = const Color(0xFF3A3650);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFFFE8D6);
        primaryText = const Color(0xFF3D2B1F);
        secondaryText = const Color(0xFFE8362A).withValues(alpha: 0.7);
        accentColor = const Color(0xFFE8362A);
        activeRowBg = const Color(0xFFE8362A).withValues(alpha: 0.10);
        separatorColor = const Color(0x33E76F51);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFFFF6EC);
        primaryText = const Color(0xFF1E1B2E);
        secondaryText = const Color(0xFF8A8398);
        accentColor = const Color(0xFFFF5A4E);
        activeRowBg = const Color(0xFFFF5A4E).withValues(alpha: 0.08);
        separatorColor = const Color(0x1A000000);
    }

    return Drawer(
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header — ink→violet gradient with sun glow
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(22, 50, 22, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1B2E), Color(0xFF7C5CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sun glow in top-right corner
                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x66FFD23F), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.book_rounded,
                          color: Color(0xFFFFD23F), size: 32),
                      const SizedBox(height: 12),
                      Text(
                        provider.bookName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '共 ${provider.chapters.length} 章',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chapter list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: provider.chapters.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 58,
                  color: separatorColor,
                ),
                itemBuilder: (context, index) {
                  final isActive = index == provider.currentChapter;
                  return Material(
                    color: isActive ? activeRowBg : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.read<ReaderProvider>().jumpToChapter(index);
                        Navigator.of(context).pop();
                      },
                      child: Stack(
                        children: [
                          // Left accent bar for active chapter
                          if (isActive)
                            Positioned(
                              left: 0,
                              top: 8,
                              bottom: 8,
                              child: Container(
                                width: 3,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: isActive
                                      ? Icon(Icons.bookmark_rounded,
                                          color: accentColor, size: 18)
                                      : Text(
                                          (index + 1)
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: secondaryText,
                                            fontFamily: 'monospace',
                                            letterSpacing: 0.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.chapters[index].title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isActive
                                              ? accentColor
                                              : primaryText,
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          letterSpacing: 0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
