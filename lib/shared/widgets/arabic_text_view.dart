import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ArabicTextView extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final Color? color;

  const ArabicTextView({
    super.key,
    required this.text,
    this.fontSize = 26,
    this.textAlign = TextAlign.center,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF7F5EE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE5DECF)),
        ),
        child: Text(
          text,
          textAlign: textAlign,
          style: GoogleFonts.amiri(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? AppColors.darkArabicText : AppColors.arabicText),
            height: 2.2,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
