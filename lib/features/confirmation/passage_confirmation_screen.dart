import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/quran_data.dart';
import '../../data/models/passage_identification.dart';
import '../../data/models/quran_surah.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../exploration/exploration_screen.dart';
import '../passage_selection/manual_passage_screen.dart';

class PassageConfirmationScreen extends StatefulWidget {
  final PassageIdentification identification;
  final String? imagePath;

  const PassageConfirmationScreen({
    super.key,
    required this.identification,
    this.imagePath,
  });

  @override
  State<PassageConfirmationScreen> createState() => _PassageConfirmationScreenState();
}

class _PassageConfirmationScreenState extends State<PassageConfirmationScreen> {
  late QuranSurah _surah;
  late int _startVerse;
  late int _endVerse;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final surahNum = widget.identification.surahNumber > 0 ? widget.identification.surahNumber : 1;
    _surah = QuranData.getByNumber(surahNum) ??
        QuranData.findByName(widget.identification.surahName) ??
        QuranData.surahs.first;

    _startVerse = widget.identification.startVerse;
    _endVerse = widget.identification.endVerse;

    // Bounds checking
    if (_startVerse < 1) _startVerse = 1;
    if (_startVerse > _surah.totalVerses) _startVerse = 1;
    if (_endVerse < _startVerse) _endVerse = _startVerse;
    if (_endVerse > _surah.totalVerses) _endVerse = _surah.totalVerses;
  }

  Color _getConfidenceColor(String conf) {
    switch (conf.toLowerCase()) {
      case 'high':
        return AppColors.success;
      case 'medium':
        return const Color(0xFFD46B08);
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confColor = _getConfidenceColor(widget.identification.confidence);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Passage'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 680,
          padding: ResponsiveLayout.defaultPadding(context, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer.withAlpha(120),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.secondaryContainer),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please verify the identified passage matches the physical page you read from your Mushaf.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Image Preview Card (if image exists)
              if (widget.imagePath != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                          child: kIsWeb
                              ? Image.network(widget.imagePath!, fit: BoxFit.cover)
                              : Image.file(File(widget.imagePath!), fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Uploaded Page Photo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: confColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Confidence: ${widget.identification.confidence.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: confColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.identification.uncertainties.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  widget.identification.uncertainties.first,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Detected Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Identified Passage',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, size: 18),
                            label: Text(_isEditing ? 'Done Editing' : 'Correct Passage'),
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (!_isEditing) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                '${_surah.number}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _surah.nameEn,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                    ),
                                  ),
                                  Text(
                                    '${_surah.nameTranslation} • ${_surah.revelationType}',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _surah.nameAr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Verse Range:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Verses $_startVerse through $_endVerse',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Interactive Correction Controls
                        Text(
                          'Change Surah:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<QuranSurah>(
                          initialValue: _surah,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkCardBg : Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: QuranData.surahs.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                '${s.number}. ${s.nameEn} (${s.nameAr})',
                                style: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (newSurah) {
                            if (newSurah != null) {
                              setState(() {
                                _surah = newSurah;
                                _startVerse = 1;
                                _endVerse = newSurah.totalVerses >= 5 ? 5 : newSurah.totalVerses;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isVeryNarrow = constraints.maxWidth < 280;
                            final stepperContent = [
                              Expanded(
                                flex: isVeryNarrow ? 0 : 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Start Verse', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: IconButton.filledTonal(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(Icons.remove),
                                            onPressed: _startVerse > 1
                                                ? () => setState(() => _startVerse--)
                                                : null,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text('$_startVerse', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: IconButton.filledTonal(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(Icons.add),
                                            onPressed: _startVerse < _surah.totalVerses
                                                ? () => setState(() {
                                                      _startVerse++;
                                                      if (_endVerse < _startVerse) _endVerse = _startVerse;
                                                    })
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: isVeryNarrow ? 0 : 14, height: isVeryNarrow ? 12 : 0),
                              Expanded(
                                flex: isVeryNarrow ? 0 : 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('End Verse', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: IconButton.filledTonal(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(Icons.remove),
                                            onPressed: _endVerse > _startVerse
                                                ? () => setState(() => _endVerse--)
                                                : null,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text('$_endVerse', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: IconButton.filledTonal(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            icon: const Icon(Icons.add),
                                            onPressed: _endVerse < _surah.totalVerses
                                                ? () => setState(() => _endVerse++)
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ];

                            return isVeryNarrow
                                ? Column(children: stepperContent)
                                : Row(children: stepperContent);
                          },
                        ),
                      ],

                      // Extracted Arabic snippet if available
                      if (widget.identification.extractedText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Detected Text Snippet:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF9F7F1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE8E2D2)),
                          ),
                          child: Text(
                            widget.identification.extractedText,
                            textAlign: TextAlign.right,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.8,
                              color: isDark ? AppColors.darkArabicText : AppColors.arabicText,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Confirm & Explore Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Confirm & Explore Meaning'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExplorationScreen(
                          surahNumber: _surah.number,
                          surahName: _surah.nameEn,
                          startVerse: _startVerse,
                          endVerse: _endVerse,
                          imagePath: widget.imagePath,
                          extractedArabicSnippet: widget.identification.extractedText,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Retry or Manual Selection
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 340;
                  final buttons = [
                    Expanded(
                      flex: isNarrow ? 0 : 1,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry Photo'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 10 : 0),
                    Expanded(
                      flex: isNarrow ? 0 : 1,
                      child: TextButton.icon(
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('Select Manually'),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManualPassageScreen(
                                initialSurahNumber: _surah.number,
                                initialStartVerse: _startVerse,
                                initialEndVerse: _endVerse,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ];
                  return isNarrow
                      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons)
                      : Row(children: buttons);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
