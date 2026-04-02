import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF13EC5B); // #13ec5b
  static const Color backgroundLight = Color(0xFFF6F8F6); // #f6f8f6
  static const Color backgroundDark = Color(0xFF102216); // #102216
  static const Color textLightPrimary = Color(0xFF333333);
  static const Color textLightSecondary = Color(0xFF888888);
  static const Color textDarkPrimary = Color(0xFFF7F8FA);
  static const Color textDarkSecondary = Color(0xFFD0D5DD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      extensions: const [],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: backgroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      extensions: const [],
    );
  }
}
