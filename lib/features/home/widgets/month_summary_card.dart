import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/app_providers.dart';

class MonthSummaryCard extends ConsumerWidget {
  final String profileId;

  const MonthSummaryCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider(profileId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkSecondary : AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatMonthYear(DateTime.now()),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            statsAsync.when(
              data: (stats) {
                final thisMonth = stats['thisMonthSessions'] ?? 0;
                final distinctSurahs = stats['distinctSurahs'] ?? 0;
                final totalSessions = stats['totalSessions'] ?? 0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = constraints.maxWidth < 340 ? 6.0 : 10.0;
                    return Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Sessions',
                            sublabel: 'This Month',
                            value: '$thisMonth',
                            icon: Icons.menu_book_rounded,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatBox(
                            label: 'Distinct',
                            sublabel: 'Surahs',
                            value: '$distinctSurahs',
                            icon: Icons.auto_stories_rounded,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatBox(
                            label: 'All-Time',
                            sublabel: 'Readings',
                            value: '$totalSessions',
                            icon: Icons.history_edu_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (error, stack) => const Text('Could not load monthly stats'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String? sublabel;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    this.sublabel,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.darkPrimary : AppColors.primary,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel != null ? '$label\n$sublabel' : label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.2,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

