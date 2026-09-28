import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocalLensApp());
}

class VocalLensApp extends StatefulWidget {
  const VocalLensApp({super.key});

  @override
  State<VocalLensApp> createState() => _VocalLensAppState();
}

class _VocalLensAppState extends State<VocalLensApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Premium Dark Theme Palette
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F131D),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1), // Electric Indigo
        onPrimary: Colors.white,
        secondary: Color(0xFFEC4899), // Pink / Rose
        onSecondary: Colors.white,
        tertiary: Color(0xFF0EA5E9), // Sky Blue
        surface: Color(0xFF161B26),
        onSurface: Color(0xFFF3F4F6),
        surfaceContainerHighest: Color(0xFF1E2433),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF131722),
        elevation: 0,
        centerTitle: false,
      ),
    );

    // Premium Light Theme Palette
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        onPrimary: Colors.white,
        secondary: Color(0xFFDB2777),
        onSecondary: Colors.white,
        tertiary: Color(0xFF0284C7),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
        surfaceContainerHighest: Color(0xFFF1F5F9),
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );

    return MaterialApp(
      title: 'VocalLens - Photo & Text Voice AI',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
