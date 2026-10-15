import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/quran_explanation.dart';

class ScholarlyViewsCard extends StatelessWidget {
  final List<ScholarlyView> scholarlyViews;
  final double textScale;

  const ScholarlyViewsCard({
    super.key,
    required this.scholarlyViews,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (scholarlyViews.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scholarly Perspectives (Tafsir)',
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
            const SizedBox(height: 14),
            ...scholarlyViews.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.scholarOrWork,
                              style: TextStyle(
                                fontSize: 13 * textScale,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.primaryDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (item.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.perspective,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.5 * textScale,
                        height: 1.55,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.notes,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12 * textScale,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
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
