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
            primary: Color(0xFF2997FF),
            secondary: Color(0xFF2997FF),
            surface: Color(0xFF1C1C1E),
            onSurface: Color(0xFFFFFFFF),
            surfaceContainerHighest: Color(0xFF2C2C2E),
            outline: Color(0xFF38383A),
          ),
          scaffoldBackgroundColor: const Color(0xFF000000),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCC000000),
            foregroundColor: Color(0xFFFFFFFF),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          dividerColor: const Color(0xFF38383A),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFF2997FF),
            thumbColor: Color(0xFF2997FF),
            inactiveTrackColor: Color(0xFF3A3A3C),
          ),
        );

      case AppTheme.sepia:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B6914),
          ).copyWith(
            primary: const Color(0xFF8B6914),
            surface: const Color(0xFFF4E4C1),
            onSurface: const Color(0xFF3D2B1F),
            surfaceContainerHighest: const Color(0xFFEED9A8),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4E4C1),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCCF4E4C1),
            foregroundColor: Color(0xFF3D2B1F),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF3D2B1F),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          dividerColor: const Color(0x33D4A853),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFF8B6914),
            thumbColor: Color(0xFF8B6914),
          ),
        );

      case AppTheme.light:
        return ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0071E3),
            secondary: Color(0xFF0066CC),
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF1D1D1F),
            surfaceContainerHighest: Color(0xFFF5F5F7),
            outline: Color(0x1F000000),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xCCF5F5F7),
            foregroundColor: Color(0xFF1D1D1F),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          dividerColor: const Color(0x1F000000),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFF0071E3),
            thumbColor: Color(0xFF0071E3),
            inactiveTrackColor: Color(0xFFD1D1D6),
          ),
        );
    }
  }
}
