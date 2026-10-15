import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/quran_data.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/reading_session.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../exploration/exploration_screen.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _confirmDeleteSession(ReadingSession session) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Reading Session?'),
          content: Text(
            'Are you sure you want to remove the session for ${session.passageReference}? This will delete the session and its saved reflections.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(ctx);
                final readingRepo = ref.read(readingRepositoryProvider);
                await readingRepo.deleteSession(session.id);
                ref.read(sessionRefreshProvider.notifier).trigger();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session deleted.')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editPassageRange(ReadingSession session) {
    int start = session.startVerse;
    int end = session.endVerse;
    final surah = QuranData.getByNumber(session.surahNumber);
    final maxVerses = surah?.totalVerses ?? 100;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${session.surahName} Verses'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total verses in Surah: $maxVerses', style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Start Verse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: start > 1 ? () => setDialogState(() => start--) : null,
                                ),
                                Text('$start', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: start < maxVerses
                                      ? () => setDialogState(() {
                                            start++;
                                            if (end < start) end = start;
                                          })
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('End Verse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: end > start ? () => setDialogState(() => end--) : null,
                                ),
                                Text('$end', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: end < maxVerses ? () => setDialogState(() => end++) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final readingRepo = ref.read(readingRepositoryProvider);
                    await readingRepo.updatePassageRange(
                      session.id,
                      session.surahNumber,
                      session.surahName,
                      start,
                      end,
                    );
                    ref.read(sessionRefreshProvider.notifier).trigger();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final statsAsync = ref.watch(profileStatsProvider(activeProfile.id));
    final calendarDatesAsync = ref.watch(calendarDatesProvider(activeProfile.id));
    final selectedDaySessionsAsync = ref.watch(
      dateSessionsProvider((profileId: activeProfile.id, date: _selectedDay)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journey'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 680,
          padding: ResponsiveLayout.defaultPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Stats Overview
            statsAsync.when(
              data: (stats) {
                final total = stats['totalSessions'] ?? 0;
                final surahs = stats['distinctSurahs'] ?? 0;
                final verses = stats['versesCovered'] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _JourneyStatItem(
                          label: 'Total Sessions',
                          value: '$total',
                          icon: Icons.auto_stories_rounded,
                        ),
                      ),
                      Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
                      Expanded(
                        child: _JourneyStatItem(
                          label: 'Surahs Read',
                          value: '$surahs / 114',
                          icon: Icons.menu_book_rounded,
                        ),
                      ),
                      Container(width: 1, height: 40, color: isDark ? AppColors.darkDivider : AppColors.divider),
                      Expanded(
                        child: _JourneyStatItem(
                          label: 'Unique Verses',
                          value: '$verses',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 70, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Reading Calendar Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: calendarDatesAsync.when(
                  data: (readingDates) {
                    return TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      currentDay: DateTime.now(),
                      selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark),
                        rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primaryLight.withAlpha(70),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                        defaultTextStyle: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        weekendTextStyle: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        outsideTextStyle: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                      eventLoader: (day) {
                        final normalized = DateTime(day.year, day.month, day.day);
                        return readingDates.contains(normalized) ? ['read'] : [];
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isNotEmpty) {
                            return Positioned(
                              bottom: 4,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    );
                  },
                  loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
                  error: (error, stack) => const Text('Could not load reading calendar'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sessions on Selected Date
            Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Readings on ${DateFormatter.formatShortDate(_selectedDay)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            selectedDaySessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBg : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No reading recorded on this date.',
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final session = sessions[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer,
                          child: Text(
                            '${session.surahNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkOnPrimaryContainer : AppColors.primaryDark,
                            ),
                          ),
                        ),
                        title: Text(
                          session.passageReference,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${DateFormatter.formatFriendly(session.readAt)}${session.notes != null && session.notes!.isNotEmpty ? ' • Note saved' : ''}',
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _editPassageRange(session);
                            } else if (val == 'delete') {
                              _confirmDeleteSession(session);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Verse Range'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Session', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

class _JourneyStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _JourneyStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.darkSecondary : AppColors.secondary),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

