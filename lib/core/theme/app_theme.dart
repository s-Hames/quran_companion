import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => getTheme(isDark: false, useGoogleFonts: true);
  static ThemeData get darkTheme => getTheme(isDark: true, useGoogleFonts: true);

  static ThemeData getTheme({bool isDark = false, bool useGoogleFonts = true}) {
    final baseTextTheme = useGoogleFonts
        ? GoogleFonts.outfitTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme)
        : (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme);

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.darkPrimary,
            onPrimary: Color(0xFF071F1A),
            primaryContainer: AppColors.darkPrimaryContainer,
            onPrimaryContainer: AppColors.darkOnPrimaryContainer,
            secondary: AppColors.darkSecondary,
            onSecondary: Color(0xFF11261E),
            secondaryContainer: AppColors.darkSecondaryContainer,
            onSecondaryContainer: AppColors.darkOnSecondaryContainer,
            tertiary: AppColors.accentGold,
            onTertiary: Colors.black,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkTextPrimary,
            surfaceContainerHighest: AppColors.darkSurfaceVariant,
            outline: AppColors.darkBorder,
            error: AppColors.error,
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: AppColors.primaryContainer,
            onPrimaryContainer: AppColors.onPrimaryContainer,
            secondary: AppColors.secondary,
            onSecondary: Colors.white,
            secondaryContainer: AppColors.secondaryContainer,
            onSecondaryContainer: AppColors.onSecondaryContainer,
            tertiary: AppColors.accentGold,
            onTertiary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            surfaceContainerHighest: AppColors.surfaceVariant,
            outline: AppColors.border,
            error: AppColors.error,
            onError: Colors.white,
          );

    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardColor = isDark ? AppColors.darkCardBg : AppColors.cardBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final primaryBtnColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryBtnColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBtnColor,
          foregroundColor: isDark ? const Color(0xFF071F1A) : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBtnColor,
          side: BorderSide(color: primaryBtnColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBtnColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 3,
        indicatorColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
            );
          }
          return GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
              size: 26,
            );
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        selectedColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 24,
      ),
      textTheme: useGoogleFonts
          ? baseTextTheme.copyWith(
              displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
              displayMedium: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
              headlineLarge: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary),
              headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
              headlineSmall: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w600, color: textPrimary),
              titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
              titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
              titleSmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary),
              bodyLarge: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6),
              bodyMedium: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary, height: 1.55),
              bodySmall: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
              labelLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
            )
          : baseTextTheme,
    );
  }

  // Dedicated typography style for Arabic Quranic verses
  static TextStyle arabicVerseStyle({bool isDark = false}) => GoogleFonts.amiri(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkArabicText : AppColors.arabicText,
    height: 2.1,
  );
}
