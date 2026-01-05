import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0E0E0E);
  static const Color card = Color(0xFF181818);
  static const Color gold = Color(0xFFC9A24D);
  static const Color text = Color(0xFFF5F5F5);
  static const Color muted = Color(0xFF9E9E9E);
  static const Color border = Color(0xFF2A2A2A);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      cardColor: card,
      dividerColor: border,
      primaryColor: gold,
      useMaterial3: false,

      // 🔒 KUNCI FONT GLOBAL
      fontFamily: 'Inter',

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontWeight: FontWeight.bold,
          color: text,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontWeight: FontWeight.bold,
          color: text,
        ),
        bodyMedium: TextStyle(
          color: text,
        ),
        bodySmall: TextStyle(
          color: muted,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: text,
        ),
        iconTheme: IconThemeData(color: text),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold),
        ),
        labelStyle: const TextStyle(color: muted),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: gold,
        textColor: text,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.black,
      ),
    );
  }
}
