import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryDark = Color(0xFF14171e);
  static const Color secondaryDark = Color(0xFF181b22);
  static const Color tertiaryDark = Color(0xFF0b0e13);
  static const Color surfaceDark = Color(0xFF181d23);
  static const Color backgroundDark = Color(0xFF101318);

  static const Color errorRed = Color(0xFFd03437);
  static const Color successGreen = Color(0xFF2ba471);
  static const Color warningYellow = Color(0xFFe6a935);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color dividerColor = Color(0xFF2A2D35);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryDark,
    scaffoldBackgroundColor: primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: successGreen,
      secondary: warningYellow,
      error: errorRed,
      surface: surfaceDark,
      background: backgroundDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: successGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: successGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: successGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      hintStyle: const TextStyle(color: textSecondary),
      labelStyle: const TextStyle(color: textSecondary),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.all(16),
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarTheme(
      backgroundColor: secondaryDark,
      selectedItemColor: successGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: textSecondary,
    ),
  );

  // Custom colors for specific use cases
  static const Color busColor = Color(0xFF4CAF50);
  static const Color routeColor = Color(0xFF2196F3);
  static const Color stopColor = Color(0xFFFF9800);

  static var accentColor;

  static var cardColor;

  static var backgroundColor;

  static var primaryColor;
}

// Custom button styles
class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.successGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: AppTheme.textPrimary,
    side: const BorderSide(color: AppTheme.textSecondary),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorRed,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
