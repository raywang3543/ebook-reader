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
          home: provider.hasBook ? const ReaderScreen() : const WelcomeScreen(),
        );
      },
    );
  }

  ThemeData _buildTheme(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.dark:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF9F88),
            secondary: Color(0xFFFFD93D),
            surface: Color(0xFF3D3A45),
            onSurface: Color(0xFFFFF9F0),
            surfaceContainerHighest: Color(0xFF4A4655),
            outline: Color(0xFF4A4655),
          ),
          scaffoldBackgroundColor: const Color(0xFF2D2A32),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCC2D2A32),
            foregroundColor: Color(0xFFFFF9F0),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFFFF9F0),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          dividerColor: const Color(0xFF4A4655),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFFFF9F88),
            thumbColor: Color(0xFFFF9F88),
            inactiveTrackColor: Color(0xFF4A4655),
          ),
        );

      case AppTheme.sepia:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE76F51),
          ).copyWith(
            primary: const Color(0xFFE76F51),
            surface: const Color(0xFFFFE8D6),
            onSurface: const Color(0xFF3D2B1F),
            surfaceContainerHighest: const Color(0xFFFFE0CC),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFE8D6),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCCFFE8D6),
            foregroundColor: Color(0xFF3D2B1F),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF3D2B1F),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          dividerColor: const Color(0x33E76F51),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFFE76F51),
            thumbColor: Color(0xFFE76F51),
          ),
        );

      case AppTheme.light:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFFF7A5C),
            secondary: Color(0xFFFFC93C),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF2D2A32),
            surfaceContainerHighest: Color(0xFFFFF0E0),
            outline: Color(0x1F000000),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF9F0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCCFFF9F0),
            foregroundColor: Color(0xFF2D2A32),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF2D2A32),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          dividerColor: const Color(0x1F000000),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFFFF7A5C),
            thumbColor: Color(0xFFFF7A5C),
            inactiveTrackColor: Color(0xFFFFD4CA),
          ),
        );
    }
  }
}
