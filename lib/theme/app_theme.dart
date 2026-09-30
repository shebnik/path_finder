import 'package:flutter/material.dart';

class AppTheme {
  static const startColor = Color(0xFF64FFDA);
  static const endColor = Color(0xFF009688);
  static const blockedColor = Color(0xFF000000);
  static const pathColor = Color(0xFF4CAF50);
  static const emptyColor = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    colorSchemeSeed: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(48),
      ),
    ),
  );
}
