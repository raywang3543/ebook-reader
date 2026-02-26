import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/reader_provider.dart';
import 'screens/reader_screen.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ReaderProvider(),
      child: const EbookReaderApp(),
    ),
  );
}

class EbookReaderApp extends StatelessWidget {
  const EbookReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: '电子书阅读器',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(provider.theme),
          home: provider.hasBook
              ? const ReaderScreen()
              : const WelcomeScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.dark:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF64B5F6),
            brightness: Brightness.dark,
          ).copyWith(
            surface: const Color(0xFF1E1E1E),
            onSurface: const Color(0xFFDDDDDD),
          ),
          scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        );

      case AppTheme.sepia:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B6914),
          ).copyWith(
            surface: const Color(0xFFF4E4C1),
            onSurface: const Color(0xFF3D2B1F),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4E4C1),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFD4A853),
            foregroundColor: Color(0xFF3D2B1F),
          ),
        );

      case AppTheme.light:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
          ),
          scaffoldBackgroundColor: Colors.white,
        );
    }
  }
}
