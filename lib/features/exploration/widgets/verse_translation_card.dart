import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/arabic_text_view.dart';

class VerseTranslationCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int startVerse;
  final int endVerse;
  final String arabicText;
  final String translation;
  final String translationUrdu;
  final String translationSource;
  final bool isUrdu;
  final double textScale;

  const VerseTranslationCard({
    super.key,
    required this.surahName,
    required this.surahNumber,
    required this.startVerse,
    required this.endVerse,
    required this.arabicText,
    required this.translation,
    this.translationUrdu = '',
    required this.translationSource,
    this.isUrdu = false,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasUrdu = translationUrdu.trim().isNotEmpty;
    final activeTranslation = isUrdu && hasUrdu
        ? translationUrdu
        : (translation.isNotEmpty ? translation : 'Translation is being loaded...');
    final activeSource = isUrdu && hasUrdu
        ? 'اردو ترجمہ (سلیس و مستند مطالعہ)'
        : translationSource;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUrdu ? 'آیات اور ترجمہ' : 'Verse & Translation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Text(
                      '$surahName $surahNumber:$startVerse${endVerse > startVerse ? '-$endVerse' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Arabic Quranic Verse
            if (arabicText.trim().isNotEmpty) ...[
              ArabicTextView(text: arabicText, fontSize: 24 * textScale),
              const SizedBox(height: 16),
            ],

            // Translation (English or Urdu)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkSecondary : AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          activeSource,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 11 * textScale,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Directionality(
                    textDirection: isUrdu && hasUrdu ? TextDirection.rtl : TextDirection.ltr,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        activeTranslation,
                        textAlign: TextAlign.center,
                        style: isUrdu && hasUrdu
                            ? GoogleFonts.amiri(
                                fontSize: 18 * textScale,
                                height: 1.85,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              )
                            : Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 16 * textScale,
                                height: 1.6,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
