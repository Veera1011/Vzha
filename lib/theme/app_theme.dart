import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData getTheme(Color primaryColor, String fontFamily) {
    TextTheme Function([TextTheme?]) fontMethod;
    
    // Map string to GoogleFonts method
    switch (fontFamily) {
      case 'Roboto':
        fontMethod = GoogleFonts.robotoTextTheme;
        break;
      case 'Poppins':
        fontMethod = GoogleFonts.poppinsTextTheme;
        break;
      case 'Outfit':
        fontMethod = GoogleFonts.outfitTextTheme;
        break;
      case 'Inter':
      default:
        fontMethod = GoogleFonts.interTextTheme;
        break;
    }

    // Material 3 automatically generates a full tonal palette from the seed color
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light);
    final baseTextTheme = fontMethod();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF84D8E3), // Amazon light teal
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontFamily: baseTextTheme.titleLarge?.fontFamily,
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, fontFamily: baseTextTheme.bodyLarge?.fontFamily),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 28);
          }
          return const IconThemeData(color: Colors.black54, size: 26);
        }),
      ),
    );
  }
}
