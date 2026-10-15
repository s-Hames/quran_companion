import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/quran_explanation.dart';

class HistoricalContextCard extends StatelessWidget {
  final HistoricalContext contextData;
  final double textScale;

  const HistoricalContextCard({
    super.key,
    required this.contextData,
    this.textScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historical Context',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
                if (contextData.classification.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Text(
                      contextData.classification,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              contextData.content.trim().isNotEmpty
                  ? contextData.content
                  : 'This passage forms an essential part of the revelation, offering timeless lessons for contemplation and righteous action.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15.5 * textScale,
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            if (contextData.occasionsOfRevelation.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Occasion of Revelation (Sabab al-Nuzul)',
                            style: TextStyle(
                              fontSize: 12 * textScale,
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
                      contextData.occasionsOfRevelation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.5 * textScale,
                        height: 1.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
