import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/quran_data.dart';
import '../../data/models/quran_surah.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../exploration/exploration_screen.dart';

class ManualPassageScreen extends StatefulWidget {
  final int? initialSurahNumber;
  final int? initialStartVerse;
  final int? initialEndVerse;

  const ManualPassageScreen({
    super.key,
    this.initialSurahNumber,
    this.initialStartVerse,
    this.initialEndVerse,
  });

  @override
  State<ManualPassageScreen> createState() => _ManualPassageScreenState();
}

class _ManualPassageScreenState extends State<ManualPassageScreen> {
  late QuranSurah _selectedSurah;
  late int _startVerse;
  late int _endVerse;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final surahNum = widget.initialSurahNumber ?? 1;
    _selectedSurah = QuranData.getByNumber(surahNum) ?? QuranData.surahs.first;
    _startVerse = widget.initialStartVerse ?? 1;
    _endVerse = widget.initialEndVerse ?? (_startVerse + 4 <= _selectedSurah.totalVerses ? _startVerse + 4 : _selectedSurah.totalVerses);

    // Validate bounds
    if (_startVerse > _selectedSurah.totalVerses) _startVerse = 1;
    if (_endVerse > _selectedSurah.totalVerses) _endVerse = _selectedSurah.totalVerses;
    if (_endVerse < _startVerse) _endVerse = _startVerse;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSurahChanged(QuranSurah newSurah) {
    setState(() {
      _selectedSurah = newSurah;
      _startVerse = 1;
      _endVerse = newSurah.totalVerses >= 5 ? 5 : newSurah.totalVerses;
    });
  }

  List<QuranSurah> get _filteredSurahs {
    if (_searchQuery.trim().isEmpty) return QuranData.surahs;
    final q = _searchQuery.toLowerCase().trim();
    return QuranData.surahs.where((s) {
      return s.number.toString() == q ||
          s.nameEn.toLowerCase().contains(q) ||
          s.nameTranslation.toLowerCase().contains(q) ||
          s.nameAr.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Passage'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 680,
          padding: ResponsiveLayout.defaultPadding(context, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Informational header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.secondaryContainer),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: isDark ? AppColors.darkPrimary : AppColors.primaryDark, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Passage Entry',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select any Surah and verse range from your physical Mushaf reading.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: Select Surah
            Text(
              '1. Choose Surah',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),

            // Surah Selector Card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
                  foregroundColor: isDark ? const Color(0xFF071F1A) : Colors.white,
                  child: Text('${_selectedSurah.number}'),
                ),
                title: Text(
                  _selectedSurah.nameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Text(
                  '${_selectedSurah.nameTranslation} • ${_selectedSurah.totalVerses} verses • ${_selectedSurah.revelationType}',
                  style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedSurah.nameAr,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkPrimary : AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down_circle_rounded, color: isDark ? AppColors.darkSecondary : AppColors.secondary),
                  ],
                ),
                onTap: _showSurahPickerModal,
              ),
            ),
            const SizedBox(height: 28),

            // Step 2: Verse Range
            Text(
              '2. Verse Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Surah ${_selectedSurah.nameEn} contains ${_selectedSurah.totalVerses} verses in total.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final cardPadding = isCompact ? 10.0 : 14.0;
                final btnConstraints = isCompact
                    ? const BoxConstraints.tightFor(width: 34, height: 34)
                    : const BoxConstraints.tightFor(width: 40, height: 40);

                return Row(
                  children: [
                    // Start Verse
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From Verse',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isCompact ? 12 : 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton.filledTonal(
                                    constraints: btnConstraints,
                                    padding: EdgeInsets.zero,
                                    iconSize: isCompact ? 18 : 22,
                                    icon: const Icon(Icons.remove),
                                    onPressed: _startVerse > 1
                                        ? () {
                                            setState(() {
                                              _startVerse--;
                                            });
                                          }
                                        : null,
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$_startVerse',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    constraints: btnConstraints,
                                    padding: EdgeInsets.zero,
                                    iconSize: isCompact ? 18 : 22,
                                    icon: const Icon(Icons.add),
                                    onPressed: _startVerse < _selectedSurah.totalVerses
                                        ? () {
                                            setState(() {
                                              _startVerse++;
                                              if (_endVerse < _startVerse) _endVerse = _startVerse;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 14),
                    // End Verse
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To Verse',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isCompact ? 12 : 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton.filledTonal(
                                    constraints: btnConstraints,
                                    padding: EdgeInsets.zero,
                                    iconSize: isCompact ? 18 : 22,
                                    icon: const Icon(Icons.remove),
                                    onPressed: _endVerse > _startVerse
                                        ? () {
                                            setState(() {
                                              _endVerse--;
                                            });
                                          }
                                        : null,
                                  ),
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$_endVerse',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    constraints: btnConstraints,
                                    padding: EdgeInsets.zero,
                                    iconSize: isCompact ? 18 : 22,
                                    icon: const Icon(Icons.add),
                                    onPressed: _endVerse < _selectedSurah.totalVerses
                                        ? () {
                                            setState(() {
                                              _endVerse++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Step 3: Passage Summary & Continue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBg : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Selected Passage',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Surah ${_selectedSurah.nameEn}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verses $_startVerse through $_endVerse (${_endVerse - _startVerse + 1} verses)',
                    style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkSecondary : AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.explore_rounded),
                      label: const Text('Explore Passage Meaning'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExplorationScreen(
                              surahNumber: _selectedSurah.number,
                              surahName: _selectedSurah.nameEn,
                              startVerse: _startVerse,
                              endVerse: _endVerse,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showSurahPickerModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final list = _filteredSurahs;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Center(
                  child: ResponsiveContainer(
                    maxWidth: 600,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            'Select Surah (1 to 114)',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, number, or translation...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setModalState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                _searchQuery = val;
                              });
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            itemCount: list.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                            itemBuilder: (ctx, index) {
                              final surah = list[index];
                              final isSelected = surah.number == _selectedSurah.number;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? (isDark ? AppColors.darkPrimaryContainer : AppColors.primary)
                                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                                  foregroundColor: isSelected
                                      ? (isDark ? AppColors.darkOnPrimaryContainer : Colors.white)
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                  child: Text('${surah.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                title: Text(
                                  surah.nameEn,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                  ),
                                ),
                                subtitle: Text(
                                  '${surah.nameTranslation} • ${surah.totalVerses} verses (${surah.revelationType})',
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Text(
                                  surah.nameAr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  _onSurahChanged(surah);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },

            );
          },
        );
      },
    );
  }
}
