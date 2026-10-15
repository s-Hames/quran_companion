class QuranSurah {
  final int number;
  final String nameEn;
  final String nameTranslation;
  final String nameAr;
  final int totalVerses;
  final String revelationType; // 'Makki' or 'Madani'

  const QuranSurah({
    required this.number,
    required this.nameEn,
    required this.nameTranslation,
    required this.nameAr,
    required this.totalVerses,
    required this.revelationType,
  });

  String get displayName => '$number. $nameEn ($nameTranslation)';
  String get shortDisplayName => '$nameEn ($number)';
}
