import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/reading_session.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../exploration/exploration_screen.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final bookmarksAsync = ref.watch(
      bookmarksListProvider((profileId: activeProfile.id, filter: _selectedFilter)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Bookmarks'),
      ),
      body: Center(
        child: ResponsiveContainer(
          maxWidth: 680,
          child: Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all', 'All Bookmarks'),
                      const SizedBox(width: 8),
                      _filterChip('session', 'Reading Sessions'),
                      const SizedBox(width: 8),
                      _filterChip('passage', 'Passages'),
                      const SizedBox(width: 8),
                      _filterChip('reflection', 'Reflections'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // Bookmarks List
              Expanded(
                child: bookmarksAsync.when(
                  data: (bookmarks) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    if (bookmarks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 48,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Bookmarks Yet',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bookmark passages, explanations, or sessions while reading to quickly return to them here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookmarks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final item = bookmarks[i];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.accentGoldLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bookmark_rounded, color: AppColors.accentGold, size: 24),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  item.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatShortDate(item.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.textMuted),
                              tooltip: 'Remove Bookmark',
                              onPressed: () async {
                                final bookmarkRepo = ref.read(bookmarkRepositoryProvider);
                                await bookmarkRepo.removeBookmark(item.id);
                                if (item.sessionId != null) {
                                  final readingRepo = ref.read(readingRepositoryProvider);
                                  await readingRepo.toggleBookmark(item.sessionId!, false);
                                }
                                ref.read(sessionRefreshProvider.notifier).trigger();
                              },
                            ),
                            onTap: () async {
                              ReadingSession? session;
                              if (item.sessionId != null) {
                                session = await ref.read(readingRepositoryProvider).getSessionById(item.sessionId!);
                              }
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExplorationScreen(
                                    surahNumber: item.surahNumber,
                                    surahName: item.surahName,
                                    startVerse: item.startVerse,
                                    endVerse: item.endVerse,
                                    existingSession: session,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (e, _) => Center(child: Text('Error loading bookmarks: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _filterChip(String id, String label) {
    final isSelected = _selectedFilter == id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? (isDark ? AppColors.darkOnPrimaryContainer : Colors.white)
            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
            : (isDark ? AppColors.darkBorder : AppColors.border),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = id;
        });
      },
    );
  }
}
