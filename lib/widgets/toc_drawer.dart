import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reader_provider.dart';

class TocDrawer extends StatelessWidget {
  const TocDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    provider.bookName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    '共 ${provider.chapters.length} 章',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.chapters.length,
              itemBuilder: (context, index) {
                final isActive = index == provider.currentChapter;
                return ListTile(
                  dense: true,
                  selected: isActive,
                  selectedTileColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  leading: isActive
                      ? Icon(Icons.bookmark,
                          color: theme.colorScheme.primary, size: 18)
                      : const Icon(Icons.bookmark_border,
                          color: Colors.grey, size: 18),
                  title: Text(
                    provider.chapters[index].title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? theme.colorScheme.primary : null,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    context.read<ReaderProvider>().jumpToChapter(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
