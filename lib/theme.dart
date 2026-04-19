import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF1A1A1F);
  static const Color card = Color(0xFF1E1E26);
  static const Color purple = Color(0xFF9B59FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color green = Color(0xFF2ECC71);
  static const Color red = Color(0xFFE74C3C);
  static const Color border = Color(0xFF2A2A3A);

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: purple,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          hintStyle: const TextStyle(color: textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: purple),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: textPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
}