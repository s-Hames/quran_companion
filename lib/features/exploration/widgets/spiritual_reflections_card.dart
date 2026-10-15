import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/quran_explanation.dart';

class SpiritualReflectionsCard extends StatelessWidget {
  final List<SpiritualReflection> reflections;
  final double textScale;

  const SpiritualReflectionsCard({
    super.key,
    required this.reflections,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (reflections.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentGold.withAlpha(isDark ? 80 : 120),
            width: 1.2,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkCardBg, const Color(0xFF26231A)]
                : [Colors.white, AppColors.accentGoldLight.withAlpha(80)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accentGold,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Spiritual Meanings & Sayings of Awliya',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Inner contemplations from the classical Islamic spiritual tradition.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 12 * textScale,
              ),
            ),
            const SizedBox(height: 14),
            ...reflections.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFEADBBE),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 20 : 6),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.format_quote_rounded,
                                size: 18,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.attributedTo,
                                  style: TextStyle(
                                    fontSize: 14 * textScale,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCardBg
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: isDark
                                ? Border.all(color: AppColors.darkBorder)
                                : null,
                          ),
                          child: Text(
                            item.kind,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkSecondary
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.reflection,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.5 * textScale,
                        height: 1.6,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontStyle:
                            item.kind.contains('Quote') ||
                                item.kind.contains('Saying')
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
