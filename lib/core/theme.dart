/*
Copyright 2022-2026 Victor Carreras

This file is part of Drag-PDF.

Drag-PDF is free software: you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any
later version.

Drag-PDF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General
Public License along with Drag-PDF. If not, see
<https://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightPrimary = Color(0xFF4F46E5); // Indigo 600
  static const Color lightSecondary = Color(0xFF0EA5E9); // Sky 500
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200

  static const Color darkPrimary = Color(0xFF818CF8); // Indigo 400
  static const Color darkSecondary = Color(0xFF38BDF8); // Sky 400
  static const Color darkBackground = Color(0xFF090D16); // Deep space slate
  static const Color darkSurface = Color(0xFF111827); // Slate 900
  static const Color darkBorder = Color(0xFF1F2937); // Slate 800

  static const Color errorColor = Color(0xFFEF4444); // Red 500

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: lightSurface,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0.0,
      scrolledUnderElevation: 1.0,
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0.0,
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        side: BorderSide(color: lightBorder, width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      thickness: 1.0,
      space: 1.0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Color(0xFF334155),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF64748B),
        height: 1.4,
      ),
      headlineLarge: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1E293B),
        letterSpacing: -0.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: lightPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0.0,
        foregroundColor: Color(0xFF334155),
        side: BorderSide(color: lightBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0.0,
      scrolledUnderElevation: 1.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0.0,
      color: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        side: BorderSide(color: darkBorder, width: 1.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      thickness: 1.0,
      space: 1.0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Color(0xFFCBD5E1),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF94A3B8),
        height: 1.4,
      ),
      headlineLarge: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w800,
        color: Color(0xFFF1F5F9),
        letterSpacing: -0.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: darkPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0.0,
        foregroundColor: Color(0xFFE2E8F0),
        side: BorderSide(color: darkBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        textStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
