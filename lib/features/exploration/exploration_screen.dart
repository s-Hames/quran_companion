import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/quran_data.dart';
import '../../data/models/quran_explanation.dart';
import '../../data/models/reading_session.dart';
import '../../providers/app_providers.dart';
import 'widgets/ask_gemini_bottom_sheet.dart';
import 'widgets/historical_context_card.dart';
import 'widgets/lessons_reflections_card.dart';
import 'widgets/related_stories_card.dart';
import 'widgets/scholarly_views_card.dart';
import 'widgets/session_notes_sheet.dart';
import 'widgets/simple_explanation_card.dart';
import 'widgets/spiritual_reflections_card.dart';
import 'widgets/verse_translation_card.dart';

class ExplorationScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final String? imagePath;
  final String? extractedArabicSnippet;
  final ReadingSession? existingSession;

  const ExplorationScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    this.imagePath,
    this.extractedArabicSnippet,
    this.existingSession,
  });

  @override
  ConsumerState<ExplorationScreen> createState() => _ExplorationScreenState();
}

class _ExplorationScreenState extends ConsumerState<ExplorationScreen> {
  QuranExplanation? _explanation;
  bool _isLoading = true;
  String? _errorMessage;
  String _notes = '';
  bool _isBookmarked = false;
  bool _isSavedToJourney = false;
  String? _sessionId;
  bool _isUrdu = false;
  bool _isTranslatingUrdu = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSession != null) {
      _notes = widget.existingSession!.notes ?? '';
      _isBookmarked = widget.existingSession!.isBookmarked;
      _isSavedToJourney = true;
      _sessionId = widget.existingSession!.id;
    }
    _loadExplanation();
  }

  Future<void> _toggleLanguage(bool toUrdu) async {
    setState(() {
      _isUrdu = toUrdu;
    });

    if (toUrdu && _explanation != null && _explanation!.simpleExplanationUrdu.trim().isEmpty) {
      final readingRepo = ref.read(readingRepositoryProvider);

      // 1. First check if SQLite cache already has the Urdu explanation stored locally
      final cached = await readingRepo.getCachedExplanation(
        widget.surahNumber,
        widget.startVerse,
        widget.endVerse,
      );

      if (cached != null && cached.isNotEmpty) {
        try {
          final cachedParsed = QuranExplanation.fromRawString(cached);
          if (cachedParsed.simpleExplanationUrdu.trim().isNotEmpty) {
            final merged = _explanation!.copyWith(
              simpleExplanationUrdu: cachedParsed.simpleExplanationUrdu,
              translationUrdu: _explanation!.translationUrdu.trim().isEmpty &&
                      cachedParsed.translationUrdu.trim().isNotEmpty
                  ? cachedParsed.translationUrdu
                  : _explanation!.translationUrdu,
            );
            if (!mounted) return;
            setState(() {
              _explanation = merged;
            });
            if (_sessionId != null) {
              await readingRepo.updateExplanation(
                _sessionId!,
                jsonEncode(merged.toJson()),
              );
              ref.read(sessionRefreshProvider.notifier).trigger();
            }
            return;
          }
        } catch (_) {}
      }

      // 2. Not in local storage yet: fetch on demand from Gemini
      setState(() {
        _isTranslatingUrdu = true;
      });

      try {
        final gemini = ref.read(geminiServiceProvider);
        final urduExplanation = await gemini.generateUrduExplanationOnDemand(
          surahNumber: widget.surahNumber,
          surahName: widget.surahName,
          startVerse: widget.startVerse,
          endVerse: widget.endVerse,
          englishExplanation: _explanation!.simpleExplanation,
        );

        if (!mounted) return;
        final updated = _explanation!.copyWith(simpleExplanationUrdu: urduExplanation);
        setState(() {
          _explanation = updated;
          _isTranslatingUrdu = false;
        });

        final encoded = jsonEncode(updated.toJson());

        // Save locally to cached_explanations
        await readingRepo.saveCachedExplanation(
          widget.surahNumber,
          widget.startVerse,
          widget.endVerse,
          encoded,
        );

        // Save locally to reading_sessions if session exists
        if (_sessionId != null) {
          await readingRepo.updateExplanation(_sessionId!, encoded);
          ref.read(sessionRefreshProvider.notifier).trigger();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isTranslatingUrdu = false;
          });
        }
      }
    }
  }

  Future<void> _loadExplanation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final readingRepo = ref.read(readingRepositoryProvider);

      // Auto-link session if one exists for this passage and profile
      if (_sessionId == null && widget.existingSession == null) {
        final activeProfile = ref.read(activeProfileProvider);
        final existingForPassage = await readingRepo.getSessionsForPassage(
          activeProfile.id,
          widget.surahNumber,
          widget.startVerse,
          widget.endVerse,
        );
        if (existingForPassage.isNotEmpty) {
          final found = existingForPassage.first;
          _sessionId = found.id;
          _isSavedToJourney = true;
          _isBookmarked = found.isBookmarked;
          _notes = found.notes ?? '';
        }
      }

      // 1. Check existing session
      if (widget.existingSession?.explanationJson != null &&
          widget.existingSession!.explanationJson!.isNotEmpty) {
        QuranExplanation parsed = QuranExplanation.fromRawString(
          widget.existingSession!.explanationJson!,
        );

        // Display existing session content immediately
        setState(() {
          _explanation = parsed;
          _isLoading = false;
        });

        // Check SQLite cache if Urdu explanation or translation was fetched and stored
        if (parsed.simpleExplanationUrdu.trim().isEmpty) {
          try {
            final cached = await readingRepo.getCachedExplanation(
              widget.surahNumber,
              widget.startVerse,
              widget.endVerse,
            );
            if (cached != null && cached.isNotEmpty) {
              final cachedParsed = QuranExplanation.fromRawString(cached);
              final needUrduExplanation = parsed.simpleExplanationUrdu.trim().isEmpty &&
                  cachedParsed.simpleExplanationUrdu.trim().isNotEmpty;
              final needUrduTranslation = parsed.translationUrdu.trim().isEmpty &&
                  cachedParsed.translationUrdu.trim().isNotEmpty;

              if (needUrduExplanation || needUrduTranslation) {
                final merged = parsed.copyWith(
                  simpleExplanationUrdu: needUrduExplanation
                      ? cachedParsed.simpleExplanationUrdu
                      : parsed.simpleExplanationUrdu,
                  translationUrdu: needUrduTranslation
                      ? cachedParsed.translationUrdu
                      : parsed.translationUrdu,
                );
                if (mounted) {
                  setState(() {
                    _explanation = merged;
                  });
                }
                if (_sessionId != null) {
                  await readingRepo.updateExplanation(
                    _sessionId!,
                    jsonEncode(merged.toJson()),
                  );
                }
              }
            }
          } catch (_) {}
        }
        return;
      }

      // 2. Check SQLite local cache
      final cached = await readingRepo.getCachedExplanation(
        widget.surahNumber,
        widget.startVerse,
        widget.endVerse,
      );

      if (cached != null && cached.isNotEmpty) {
        final parsed = QuranExplanation.fromRawString(cached);
        setState(() {
          _explanation = parsed;
          _isLoading = false;
        });
        return;
      }

      // 3. Request from Gemini
      final gemini = ref.read(geminiServiceProvider);
      final explanation = await gemini.generateExplanation(
        surahNumber: widget.surahNumber,
        surahName: widget.surahName,
        startVerse: widget.startVerse,
        endVerse: widget.endVerse,
        knownArabicSnippet: widget.extractedArabicSnippet,
      );

      // Save to cache
      await readingRepo.saveCachedExplanation(
        widget.surahNumber,
        widget.startVerse,
        widget.endVerse,
        jsonEncode(explanation.toJson()),
      );

      if (!mounted) return;

      setState(() {
        _explanation = explanation;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSessionToJourney() async {
    if (_explanation == null) return;

    final activeProfile = ref.read(activeProfileProvider);
    final readingRepo = ref.read(readingRepositoryProvider);

    final sessionId =
        _sessionId ??
        '${DateTime.now().millisecondsSinceEpoch}_${activeProfile.id}';
    final session = ReadingSession(
      id: sessionId,
      profileId: activeProfile.id,
      readAt: widget.existingSession?.readAt ?? DateTime.now(),
      surahNumber: widget.surahNumber,
      surahName: widget.surahName,
      startVerse: widget.startVerse,
      endVerse: widget.endVerse,
      imagePath: widget.imagePath ?? widget.existingSession?.imagePath,
      extractedText:
          widget.extractedArabicSnippet ??
          widget.existingSession?.extractedText,
      explanationJson: jsonEncode(_explanation!.toJson()),
      notes: _notes,
      isBookmarked: _isBookmarked,
      createdAt: widget.existingSession?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (_sessionId != null) {
      await readingRepo.updateSession(session);
    } else {
      await readingRepo.saveSession(session);
    }

    ref.read(sessionRefreshProvider.notifier).trigger();

    setState(() {
      _sessionId = sessionId;
      _isSavedToJourney = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reading session saved for ${activeProfile.name}!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    final newStatus = !_isBookmarked;
    setState(() {
      _isBookmarked = newStatus;
    });

    if (_sessionId != null) {
      final readingRepo = ref.read(readingRepositoryProvider);
      await readingRepo.toggleBookmark(_sessionId!, newStatus);
      final bookmarkRepo = ref.read(bookmarkRepositoryProvider);
      if (newStatus) {
        final session = await readingRepo.getSessionById(_sessionId!);
        if (session != null) {
          await bookmarkRepo.toggleSessionBookmark(session);
        }
      } else {
        await bookmarkRepo.removeBookmarkBySessionId(_sessionId!);
      }
      ref.read(sessionRefreshProvider.notifier).trigger();
    }
  }

  void _showNotesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SessionNotesSheet(
        initialNotes: _notes,
        onSave: (newNotes) async {
          setState(() {
            _notes = newNotes;
          });
          if (_sessionId != null) {
            final readingRepo = ref.read(readingRepositoryProvider);
            await readingRepo.updateNotes(_sessionId!, newNotes);
            ref.read(sessionRefreshProvider.notifier).trigger();
          } else {
            // Automatically save session when user writes a note
            await _saveSessionToJourney();
          }
        },
      ),
    );
  }

  void _showAskGeminiSheet() {
    if (_explanation == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AskGeminiBottomSheet(explanation: _explanation!),
    );
  }

  void _showFontSizeDialog() {
    final currentScale = ref.read(textScaleProvider);
    showDialog(
      context: context,
      builder: (ctx) {
        double tempScale = currentScale;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Adjust Text Size'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Customize text size for comfortable reading:'),
                  const SizedBox(height: 16),
                  Slider(
                    value: tempScale,
                    min: 1.0,
                    max: 1.5,
                    divisions: 5,
                    label: '${(tempScale * 100).round()}%',
                    onChanged: (val) {
                      setDialogState(() {
                        tempScale = val;
                      });
                      ref.read(textScaleProvider.notifier).setScale(val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Standard', style: TextStyle(fontSize: 12)),
                      Text(
                        'Preview (${(tempScale * 100).round()}%)',
                        style: TextStyle(
                          fontSize: 14 * tempScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Extra Large', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
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
    final textScale = ref.watch(textScaleProvider);
    final surahInfo = QuranData.getByNumber(widget.surahNumber);
    final passageTitle =
        '${widget.surahName} (${widget.surahNumber}:${widget.startVerse}${widget.endVerse > widget.startVerse ? '-${widget.endVerse}' : ''})';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          passageTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Language Switcher (EN / اردو)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _toggleLanguage(!_isUrdu),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isUrdu
                        ? AppColors.accentGold.withAlpha(Theme.of(context).brightness == Brightness.dark ? 50 : 35)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isUrdu
                          ? AppColors.accentGold
                          : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isTranslatingUrdu)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accentGold,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.translate_rounded,
                          size: 15,
                          color: _isUrdu
                              ? AppColors.accentGold
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isUrdu ? 'اردو' : 'EN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isUrdu
                              ? AppColors.accentGold
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Adjust Text Size',
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppColors.accentGold : null,
            ),
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 20),
                  Text(
                    'Preparing Quranic Study Guide...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gathering verses, translations, tafsir, and reflections for $passageTitle',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 54,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to Load Explanation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      onPressed: _loadExplanation,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Surah details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.primaryContainer.withAlpha(140),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorder
                            : AppColors.secondaryContainer,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.surahName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.primaryDark,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Verses ${widget.startVerse} to ${widget.endVerse} • ${surahInfo?.revelationType ?? "Quran"}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (surahInfo != null)
                          Text(
                            surahInfo.nameAr,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkPrimary
                                  : AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section A: Verse and Translation
                  VerseTranslationCard(
                    surahName: widget.surahName,
                    surahNumber: widget.surahNumber,
                    startVerse: widget.startVerse,
                    endVerse: widget.endVerse,
                    arabicText: _explanation!.arabicText,
                    translation: _explanation!.translation,
                    translationUrdu: _explanation!.translationUrdu,
                    translationSource: _explanation!.translationSource,
                    isUrdu: _isUrdu,
                    textScale: textScale,
                  ),
                  const SizedBox(height: 16),

                  // Section B: Simple Explanation
                  SimpleExplanationCard(
                    explanation: _explanation!.simpleExplanation,
                    explanationUrdu: _explanation!.simpleExplanationUrdu,
                    isUrdu: _isUrdu,
                    isLoading: _isTranslatingUrdu,
                    onLanguageToggle: (val) => _toggleLanguage(val),
                    textScale: textScale,
                  ),
                  const SizedBox(height: 16),

                  // Section C: Historical Context
                  HistoricalContextCard(
                    contextData: _explanation!.historicalContext,
                    textScale: textScale,
                  ),
                  const SizedBox(height: 16),

                  // Section D: Related Stories
                  if (_explanation!.relatedStories.isNotEmpty) ...[
                    RelatedStoriesCard(
                      stories: _explanation!.relatedStories,
                      textScale: textScale,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section E: Lessons & Reflections
                  if (_explanation!.lessons.isNotEmpty) ...[
                    LessonsReflectionsCard(
                      lessons: _explanation!.lessons,
                      textScale: textScale,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section F: Scholarly Perspectives
                  if (_explanation!.scholarlyInterpretations.isNotEmpty) ...[
                    ScholarlyViewsCard(
                      scholarlyViews: _explanation!.scholarlyInterpretations,
                      textScale: textScale,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section G: Spiritual Meanings & Sayings of Awliya
                  if (_explanation!.spiritualReflections.isNotEmpty) ...[
                    SpiritualReflectionsCard(
                      reflections: _explanation!.spiritualReflections,
                      textScale: textScale,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Personal Notes Display (if any)
                  if (_notes.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Your Private Note',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _showNotesSheet,
                                  child: const Text('Edit Note'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _notes,
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section: Transparent AI Disclaimer
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _explanation!.cautionDisclaimer,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  ), // Bottom padding for sticky actions
                ],
              ),
            ),
      bottomSheet: _explanation != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBg
                    : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.border,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      Theme.of(context).brightness == Brightness.dark ? 24 : 8,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Ask Gemini button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Ask Gemini'),
                        onPressed: _showAskGeminiSheet,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Notes button
                    IconButton.filledTonal(
                      icon: Icon(
                        _notes.isNotEmpty
                            ? Icons.sticky_note_2_rounded
                            : Icons.edit_note_rounded,
                      ),
                      tooltip: 'Personal Notes',
                      onPressed: _showNotesSheet,
                    ),
                    const SizedBox(width: 10),
                    // Save Session button
                    ElevatedButton.icon(
                      icon: Icon(
                        _isSavedToJourney
                            ? Icons.check_circle_rounded
                            : Icons.bookmark_add_rounded,
                        size: 18,
                      ),
                      label: Text(_isSavedToJourney ? 'Saved' : 'Save Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSavedToJourney
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      onPressed: _saveSessionToJourney,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
