import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../passage_selection/manual_passage_screen.dart';
import '../upload/upload_reading_screen.dart';
import 'widgets/month_summary_card.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/recent_session_card.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileProvider);
    final recentSessionsAsync = ref.watch(recentSessionsProvider(activeProfile.id));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_stories_rounded, color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Quran Companion'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(sessionRefreshProvider.notifier).trigger();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContainer(
            maxWidth: 680,
            padding: ResponsiveLayout.defaultPadding(context, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personal Greeting Header
              const ProfileHeaderCard(),
              const SizedBox(height: 24),

              // 2. Primary Actions: "Upload Today's Reading" & "Manual Entry"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: AppColors.accentGoldLight, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Read with Gemini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Photograph your physical Mushaf page to identify verses and uncover simple explanations, stories, and reflections.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryDark),
                        label: const Text('Upload Today\'s Reading'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UploadReadingScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          'Or Enter Passage Manually',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ManualPassageScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Most Recent Reading Session Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Most Recent Reading',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                    ),
                  ),
                  if (onNavigateTab != null)
                    TextButton(
                      onPressed: () => onNavigateTab!(1), // Go to My Journey
                      child: const Text('View All Journey'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              recentSessionsAsync.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardBg : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 36,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No readings recorded yet for ${activeProfile.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Capture a page from your physical Quran or select a passage to begin this journey.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RecentSessionCard(session: sessions.first);
                },
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => Text('Error loading session: $e'),
              ),
              const SizedBox(height: 24),

              // 4. This Month's Summary Card
              Text(
                'Monthly Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              MonthSummaryCard(profileId: activeProfile.id),
              const SizedBox(height: 24),

              // 5. Quick Access to Bookmarks
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.accentGoldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_rounded, color: AppColors.accentGold, size: 22),
                  ),
                  title: const Text(
                    'Saved Bookmarks & Reflections',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Your saved passages, explanations, and personal notes'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    if (onNavigateTab != null) {
                      onNavigateTab!(2); // Navigate to Bookmarks tab
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }
}
