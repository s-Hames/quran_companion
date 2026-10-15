import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/reading_session.dart';
import '../../../providers/app_providers.dart';
import '../../exploration/exploration_screen.dart';

class RecentSessionCard extends ConsumerWidget {
  final ReadingSession session;

  const RecentSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExplorationScreen(
                surahNumber: session.surahNumber,
                surahName: session.surahName,
                startVerse: session.startVerse,
                endVerse: session.endVerse,
                existingSession: session,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.passageReference,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatFriendly(session.readAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      session.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: session.isBookmarked ? AppColors.accentGold : AppColors.textMuted,
                    ),
                    tooltip: 'Bookmark',
                    onPressed: () async {
                      final bookmarkRepo = ref.read(bookmarkRepositoryProvider);
                      await bookmarkRepo.toggleSessionBookmark(session);
                      ref.read(sessionRefreshProvider.notifier).trigger();
                    },
                  ),
                ],
              ),
              if (session.notes != null && session.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkSecondary : AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSecondaryContainer : AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${session.verseCount} ${session.verseCount == 1 ? 'verse' : 'verses'} read',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkOnSecondaryContainer : AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reopen Meaning',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
