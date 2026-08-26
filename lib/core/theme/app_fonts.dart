import 'package:flutter/material.dart';

class AppFonts {
  static const String uthmani = 'Uthmani';
  static const String amiri = 'Amiri';
  
  static ThemeData getThemeWithQuranFont() {
    return ThemeData(
      fontFamily: amiri,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: amiri),
        bodyMedium: TextStyle(fontFamily: amiri),
        titleLarge: TextStyle(fontFamily: amiri),
      ),
    );
  }
}
