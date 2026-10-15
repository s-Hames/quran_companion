import 'package:flutter/material.dart';

class AppColors {
  // Deep reverent forest greens
  static const Color primary = Color(0xFF16423C);
  static const Color primaryDark = Color(0xFF0F2E2A);
  static const Color primaryLight = Color(0xFF235C54);
  static const Color primaryContainer = Color(0xFFD6E8E2);
  static const Color onPrimaryContainer = Color(0xFF0A2622);

  // Muted sage and soft olive
  static const Color secondary = Color(0xFF6A8E7F);
  static const Color secondaryContainer = Color(0xFFE2ECE7);
  static const Color onSecondaryContainer = Color(0xFF1D352B);

  // Warm gold / subtle ochre accent
  static const Color accentGold = Color(0xFFC49A45);
  static const Color accentGoldLight = Color(0xFFF7F1E1);

  // Warm ivory / cream surfaces
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3EFE8);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A2621);
  static const Color textSecondary = Color(0xFF53665D);
  static const Color textMuted = Color(0xFF869990);
  static const Color arabicText = Color(0xFF0D2E20);

  // Status and feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF0288D1);

  // Dividers & borders
  static const Color border = Color(0xFFE3DDD3);
  static const Color divider = Color(0xFFEEEAE2);

  // Dark Mode Tokens (Deep Emerald & Muted Sage)
  static const Color darkBackground = Color(0xFF0F1815);
  static const Color darkSurface = Color(0xFF162420);
  static const Color darkSurfaceVariant = Color(0xFF1E312B);
  static const Color darkCardBg = Color(0xFF162420);
  static const Color darkBorder = Color(0xFF263C35);
  static const Color darkDivider = Color(0xFF20332D);

  static const Color darkPrimary = Color(0xFF5DB09C);
  static const Color darkPrimaryContainer = Color(0xFF1D4239);
  static const Color darkOnPrimaryContainer = Color(0xFFD6F3EB);

  static const Color darkSecondary = Color(0xFF8EAA9E);
  static const Color darkSecondaryContainer = Color(0xFF283B33);
  static const Color darkOnSecondaryContainer = Color(0xFFD6E6DF);

  static const Color darkTextPrimary = Color(0xFFEBE8E1);
  static const Color darkTextSecondary = Color(0xFFA1B3AB);
  static const Color darkTextMuted = Color(0xFF6E8279);
  static const Color darkArabicText = Color(0xFFF3F7F4);

  // Theme-aware helper methods
  static Color textPrimaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color textSecondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;

  static Color textMutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : textMuted;

  static Color surfaceVariantOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceVariant : surfaceVariant;

  static Color cardBgOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardBg : cardBg;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : border;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimary : primary;

  static Color primaryDarkOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimary : primaryDark;

  static Color primaryContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimaryContainer : primaryContainer;

  static Color onPrimaryContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkOnPrimaryContainer : primaryDark;

  static Color secondaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondary : secondary;

  static Color secondaryContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondaryContainer : secondaryContainer;

  static Color onSecondaryContainerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkOnSecondaryContainer : onSecondaryContainer;
}

