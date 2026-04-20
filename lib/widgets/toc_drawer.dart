import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class TocDrawer extends StatelessWidget {
  const TocDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();

    final Color bgColor;
    final Color headerBg;
    final Color primaryText;
    final Color secondaryText;
    final Color accentColor;
    final Color activeRowBg;
    final Color separatorColor;

    switch (provider.theme) {
      case AppTheme.dark:
        bgColor = const Color(0xFF1C1C1E);
        headerBg = const Color(0xFF000000);
        primaryText = const Color(0xFFFFFFFF);
        secondaryText = const Color(0xFF8E8E93);
        accentColor = const Color(0xFF2997FF);
        activeRowBg = const Color(0xFF2997FF).withValues(alpha: 0.12);
        separatorColor = const Color(0xFF38383A);
        break;
      case AppTheme.sepia:
        bgColor = const Color(0xFFF4E4C1);
        headerBg = const Color(0xFF3D2B1F);
        primaryText = const Color(0xFF3D2B1F);
        secondaryText = const Color(0xFF8B6914).withValues(alpha: 0.7);
        accentColor = const Color(0xFF8B6914);
        activeRowBg = const Color(0xFF8B6914).withValues(alpha: 0.10);
        separatorColor = const Color(0x33D4A853);
        break;
      case AppTheme.light:
        bgColor = const Color(0xFFF5F5F7);
        headerBg = const Color(0xFF1D1D1F);
        primaryText = const Color(0xFF1D1D1F);
        secondaryText = const Color(0xFF8E8E93);
        accentColor = const Color(0xFF0071E3);
        activeRowBg = const Color(0xFF0071E3).withValues(alpha: 0.08);
        separatorColor = const Color(0x1A000000);
    }

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header — dark background, book info
            Container(
              width: double.infinity,
              color: headerBg,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.book_rounded,
                      color: Colors.white54, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    provider.bookName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '共 ${provider.chapters.length} 章',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // Chapter list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: provider.chapters.length,
                separatorBuilder: (_, __) => Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 54,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Row(
                          children: [
                            // Chapter index indicator
                            SizedBox(
                              width: 28,
                              child: isActive
                                  ? Icon(Icons.bookmark_rounded,
                                      color: accentColor, size: 16)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: secondaryText,
                                        letterSpacing: -0.15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.chapters[index].title,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isActive ? accentColor : primaryText,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  letterSpacing: -0.224,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
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
