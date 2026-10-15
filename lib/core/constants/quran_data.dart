import '../../data/models/quran_surah.dart';

class QuranData {
  static const List<QuranSurah> surahs = [
    QuranSurah(number: 1, nameEn: 'Al-Fatihah', nameTranslation: 'The Opening', nameAr: 'الفاتحة', totalVerses: 7, revelationType: 'Makki'),
    QuranSurah(number: 2, nameEn: 'Al-Baqarah', nameTranslation: 'The Cow', nameAr: 'البقرة', totalVerses: 286, revelationType: 'Madani'),
    QuranSurah(number: 3, nameEn: "Ali 'Imran", nameTranslation: 'Family of Imran', nameAr: 'آل عمران', totalVerses: 200, revelationType: 'Madani'),
    QuranSurah(number: 4, nameEn: 'An-Nisa', nameTranslation: 'The Women', nameAr: 'النساء', totalVerses: 176, revelationType: 'Madani'),
    QuranSurah(number: 5, nameEn: "Al-Ma'idah", nameTranslation: 'The Table Spread', nameAr: 'المائدة', totalVerses: 120, revelationType: 'Madani'),
    QuranSurah(number: 6, nameEn: "Al-An'am", nameTranslation: 'The Cattle', nameAr: 'الأنعام', totalVerses: 165, revelationType: 'Makki'),
    QuranSurah(number: 7, nameEn: "Al-A'raf", nameTranslation: 'The Heights', nameAr: 'الأعراف', totalVerses: 206, revelationType: 'Makki'),
    QuranSurah(number: 8, nameEn: 'Al-Anfal', nameTranslation: 'The Spoils of War', nameAr: 'الأنفال', totalVerses: 75, revelationType: 'Madani'),
    QuranSurah(number: 9, nameEn: 'At-Tawbah', nameTranslation: 'The Repentance', nameAr: 'التوبة', totalVerses: 129, revelationType: 'Madani'),
    QuranSurah(number: 10, nameEn: 'Yunus', nameTranslation: 'Jonah', nameAr: 'يونس', totalVerses: 109, revelationType: 'Makki'),
    QuranSurah(number: 11, nameEn: 'Hud', nameTranslation: 'Hud', nameAr: 'هود', totalVerses: 123, revelationType: 'Makki'),
    QuranSurah(number: 12, nameEn: 'Yusuf', nameTranslation: 'Joseph', nameAr: 'يوسف', totalVerses: 111, revelationType: 'Makki'),
    QuranSurah(number: 13, nameEn: "Ar-Ra'd", nameTranslation: 'The Thunder', nameAr: 'الرعد', totalVerses: 43, revelationType: 'Madani'),
    QuranSurah(number: 14, nameEn: 'Ibrahim', nameTranslation: 'Abraham', nameAr: 'إبراهيم', totalVerses: 52, revelationType: 'Makki'),
    QuranSurah(number: 15, nameEn: 'Al-Hijr', nameTranslation: 'The Rocky Tract', nameAr: 'الحجر', totalVerses: 99, revelationType: 'Makki'),
    QuranSurah(number: 16, nameEn: 'An-Nahl', nameTranslation: 'The Bee', nameAr: 'النحل', totalVerses: 128, revelationType: 'Makki'),
    QuranSurah(number: 17, nameEn: 'Al-Isra', nameTranslation: 'The Night Journey', nameAr: 'الإسراء', totalVerses: 111, revelationType: 'Makki'),
    QuranSurah(number: 18, nameEn: 'Al-Kahf', nameTranslation: 'The Cave', nameAr: 'الكهف', totalVerses: 110, revelationType: 'Makki'),
    QuranSurah(number: 19, nameEn: 'Maryam', nameTranslation: 'Mary', nameAr: 'مريم', totalVerses: 98, revelationType: 'Makki'),
    QuranSurah(number: 20, nameEn: 'Taha', nameTranslation: 'Ta-Ha', nameAr: 'طه', totalVerses: 135, revelationType: 'Makki'),
    QuranSurah(number: 21, nameEn: 'Al-Anbiya', nameTranslation: 'The Prophets', nameAr: 'الأنبياء', totalVerses: 112, revelationType: 'Makki'),
    QuranSurah(number: 22, nameEn: 'Al-Hajj', nameTranslation: 'The Pilgrimage', nameAr: 'الحج', totalVerses: 78, revelationType: 'Madani'),
    QuranSurah(number: 23, nameEn: "Al-Mu'minun", nameTranslation: 'The Believers', nameAr: 'المؤمنون', totalVerses: 118, revelationType: 'Makki'),
    QuranSurah(number: 24, nameEn: 'An-Nur', nameTranslation: 'The Light', nameAr: 'النور', totalVerses: 64, revelationType: 'Madani'),
    QuranSurah(number: 25, nameEn: 'Al-Furqan', nameTranslation: 'The Criterion', nameAr: 'الفرقان', totalVerses: 77, revelationType: 'Makki'),
    QuranSurah(number: 26, nameEn: "Ash-Shu'ara", nameTranslation: 'The Poets', nameAr: 'الشعراء', totalVerses: 227, revelationType: 'Makki'),
    QuranSurah(number: 27, nameEn: 'An-Naml', nameTranslation: 'The Ant', nameAr: 'النمل', totalVerses: 93, revelationType: 'Makki'),
    QuranSurah(number: 28, nameEn: 'Al-Qasas', nameTranslation: 'The Stories', nameAr: 'القصص', totalVerses: 88, revelationType: 'Makki'),
    QuranSurah(number: 29, nameEn: "Al-'Ankabut", nameTranslation: 'The Spider', nameAr: 'العنكبوت', totalVerses: 69, revelationType: 'Makki'),
    QuranSurah(number: 30, nameEn: 'Ar-Rum', nameTranslation: 'The Romans', nameAr: 'الروم', totalVerses: 60, revelationType: 'Makki'),
    QuranSurah(number: 31, nameEn: 'Luqman', nameTranslation: 'Luqman', nameAr: 'لقمان', totalVerses: 34, revelationType: 'Makki'),
    QuranSurah(number: 32, nameEn: 'As-Sajdah', nameTranslation: 'The Prostration', nameAr: 'السجدة', totalVerses: 30, revelationType: 'Makki'),
    QuranSurah(number: 33, nameEn: 'Al-Ahzab', nameTranslation: 'The Combined Forces', nameAr: 'الأحزاب', totalVerses: 73, revelationType: 'Madani'),
    QuranSurah(number: 34, nameEn: 'Saba', nameTranslation: 'Sheba', nameAr: 'سبأ', totalVerses: 54, revelationType: 'Makki'),
    QuranSurah(number: 35, nameEn: 'Fatir', nameTranslation: 'Originator', nameAr: 'فاطر', totalVerses: 45, revelationType: 'Makki'),
    QuranSurah(number: 36, nameEn: 'Ya-Sin', nameTranslation: 'Ya-Sin', nameAr: 'يس', totalVerses: 83, revelationType: 'Makki'),
    QuranSurah(number: 37, nameEn: 'As-Saffat', nameTranslation: 'Those who set the Ranks', nameAr: 'الصافات', totalVerses: 182, revelationType: 'Makki'),
    QuranSurah(number: 38, nameEn: 'Sad', nameTranslation: 'The Letter Sad', nameAr: 'ص', totalVerses: 88, revelationType: 'Makki'),
    QuranSurah(number: 39, nameEn: 'Az-Zumar', nameTranslation: 'The Troops', nameAr: 'الزمر', totalVerses: 75, revelationType: 'Makki'),
    QuranSurah(number: 40, nameEn: 'Ghafir', nameTranslation: 'The Forgiver', nameAr: 'غافر', totalVerses: 85, revelationType: 'Makki'),
    QuranSurah(number: 41, nameEn: 'Fussilat', nameTranslation: 'Explained in Detail', nameAr: 'فصلت', totalVerses: 54, revelationType: 'Makki'),
    QuranSurah(number: 42, nameEn: 'Ash-Shura', nameTranslation: 'The Consultation', nameAr: 'الشورى', totalVerses: 53, revelationType: 'Makki'),
    QuranSurah(number: 43, nameEn: 'Az-Zukhruf', nameTranslation: 'The Ornaments of Gold', nameAr: 'الزخرف', totalVerses: 89, revelationType: 'Makki'),
    QuranSurah(number: 44, nameEn: 'Ad-Dukhan', nameTranslation: 'The Smoke', nameAr: 'الدخان', totalVerses: 59, revelationType: 'Makki'),
    QuranSurah(number: 45, nameEn: 'Al-Jathiyah', nameTranslation: 'The Crouching', nameAr: 'الجاثية', totalVerses: 37, revelationType: 'Makki'),
    QuranSurah(number: 46, nameEn: 'Al-Ahqaf', nameTranslation: 'The Wind-Curved Sandhills', nameAr: 'الأحقاف', totalVerses: 35, revelationType: 'Makki'),
    QuranSurah(number: 47, nameEn: 'Muhammad', nameTranslation: 'Muhammad', nameAr: 'محمد', totalVerses: 38, revelationType: 'Madani'),
    QuranSurah(number: 48, nameEn: 'Al-Fath', nameTranslation: 'The Victory', nameAr: 'الفتح', totalVerses: 29, revelationType: 'Madani'),
    QuranSurah(number: 49, nameEn: 'Al-Hujurat', nameTranslation: 'The Rooms', nameAr: 'الحجرات', totalVerses: 18, revelationType: 'Madani'),
    QuranSurah(number: 50, nameEn: 'Qaf', nameTranslation: 'The Letter Qaf', nameAr: 'ق', totalVerses: 45, revelationType: 'Makki'),
    QuranSurah(number: 51, nameEn: 'Adh-Dhariyat', nameTranslation: 'The Winnowing Winds', nameAr: 'الذاريات', totalVerses: 60, revelationType: 'Makki'),
    QuranSurah(number: 52, nameEn: 'At-Tur', nameTranslation: 'The Mount', nameAr: 'الطور', totalVerses: 49, revelationType: 'Makki'),
    QuranSurah(number: 53, nameEn: 'An-Najm', nameTranslation: 'The Star', nameAr: 'النجم', totalVerses: 62, revelationType: 'Makki'),
    QuranSurah(number: 54, nameEn: 'Al-Qamar', nameTranslation: 'The Moon', nameAr: 'القمر', totalVerses: 55, revelationType: 'Makki'),
    QuranSurah(number: 55, nameEn: 'Ar-Rahman', nameTranslation: 'The Beneficent', nameAr: 'الرحمن', totalVerses: 78, revelationType: 'Madani'),
    QuranSurah(number: 56, nameEn: 'Al-Waqi’ah', nameTranslation: 'The Inevitable', nameAr: 'الواقعة', totalVerses: 96, revelationType: 'Makki'),
    QuranSurah(number: 57, nameEn: 'Al-Hadid', nameTranslation: 'The Iron', nameAr: 'الحديد', totalVerses: 29, revelationType: 'Madani'),
    QuranSurah(number: 58, nameEn: 'Al-Mujadila', nameTranslation: 'The Pleading Woman', nameAr: 'المجادلة', totalVerses: 22, revelationType: 'Madani'),
    QuranSurah(number: 59, nameEn: 'Al-Hashr', nameTranslation: 'The Exile', nameAr: 'الحشر', totalVerses: 24, revelationType: 'Madani'),
    QuranSurah(number: 60, nameEn: 'Al-Mumtahanah', nameTranslation: 'She that is to be examined', nameAr: 'الممتحنة', totalVerses: 13, revelationType: 'Madani'),
    QuranSurah(number: 61, nameEn: 'As-Saff', nameTranslation: 'The Ranks', nameAr: 'الصف', totalVerses: 14, revelationType: 'Madani'),
    QuranSurah(number: 62, nameEn: "Al-Jumu'ah", nameTranslation: 'Friday', nameAr: 'الجمعة', totalVerses: 11, revelationType: 'Madani'),
    QuranSurah(number: 63, nameEn: 'Al-Munafiqun', nameTranslation: 'The Hypocrites', nameAr: 'المنافقون', totalVerses: 11, revelationType: 'Madani'),
    QuranSurah(number: 64, nameEn: 'At-Taghabun', nameTranslation: 'The Mutual Disillusion', nameAr: 'التغابن', totalVerses: 18, revelationType: 'Madani'),
    QuranSurah(number: 65, nameEn: 'At-Talaq', nameTranslation: 'The Divorce', nameAr: 'الطلاق', totalVerses: 12, revelationType: 'Madani'),
    QuranSurah(number: 66, nameEn: 'At-Tahrim', nameTranslation: 'The Prohibition', nameAr: 'التحريم', totalVerses: 12, revelationType: 'Madani'),
    QuranSurah(number: 67, nameEn: 'Al-Mulk', nameTranslation: 'The Sovereignty', nameAr: 'الملك', totalVerses: 30, revelationType: 'Makki'),
    QuranSurah(number: 68, nameEn: 'Al-Qalam', nameTranslation: 'The Pen', nameAr: 'القلم', totalVerses: 52, revelationType: 'Makki'),
    QuranSurah(number: 69, nameEn: 'Al-Haqqah', nameTranslation: 'The Reality', nameAr: 'الحاقة', totalVerses: 52, revelationType: 'Makki'),
    QuranSurah(number: 70, nameEn: "Al-Ma'arij", nameTranslation: 'The Ascending Stairways', nameAr: 'المعارج', totalVerses: 44, revelationType: 'Makki'),
    QuranSurah(number: 71, nameEn: 'Nuh', nameTranslation: 'Noah', nameAr: 'نوح', totalVerses: 28, revelationType: 'Makki'),
    QuranSurah(number: 72, nameEn: 'Al-Jinn', nameTranslation: 'The Jinn', nameAr: 'الجن', totalVerses: 28, revelationType: 'Makki'),
    QuranSurah(number: 73, nameEn: 'Al-Muzzammil', nameTranslation: 'The Enshrouded One', nameAr: 'المزمل', totalVerses: 20, revelationType: 'Makki'),
    QuranSurah(number: 74, nameEn: 'Al-Muddaththir', nameTranslation: 'The Cloaked One', nameAr: 'المدثر', totalVerses: 56, revelationType: 'Makki'),
    QuranSurah(number: 75, nameEn: 'Al-Qiyamah', nameTranslation: 'The Resurrection', nameAr: 'القيامة', totalVerses: 40, revelationType: 'Makki'),
    QuranSurah(number: 76, nameEn: 'Al-Insan', nameTranslation: 'Man', nameAr: 'الإنسان', totalVerses: 31, revelationType: 'Madani'),
    QuranSurah(number: 77, nameEn: 'Al-Mursalat', nameTranslation: 'The Emissaries', nameAr: 'المرسلات', totalVerses: 50, revelationType: 'Makki'),
    QuranSurah(number: 78, nameEn: 'An-Naba', nameTranslation: 'The Tidings', nameAr: 'النبأ', totalVerses: 40, revelationType: 'Makki'),
    QuranSurah(number: 79, nameEn: "An-Nazi'at", nameTranslation: 'Those who drag forth', nameAr: 'النازعات', totalVerses: 46, revelationType: 'Makki'),
    QuranSurah(number: 80, nameEn: "'Abasa", nameTranslation: 'He Frowned', nameAr: 'عبس', totalVerses: 42, revelationType: 'Makki'),
    QuranSurah(number: 81, nameEn: 'At-Takwir', nameTranslation: 'The Overthrowing', nameAr: 'التكوير', totalVerses: 29, revelationType: 'Makki'),
    QuranSurah(number: 82, nameEn: 'Al-Infitar', nameTranslation: 'The Cleaving', nameAr: 'الانفطار', totalVerses: 19, revelationType: 'Makki'),
    QuranSurah(number: 83, nameEn: 'Al-Mutaffifin', nameTranslation: 'The Defrauding', nameAr: 'المطففين', totalVerses: 36, revelationType: 'Makki'),
    QuranSurah(number: 84, nameEn: 'Al-Inshiqaq', nameTranslation: 'The Splitting Open', nameAr: 'الانشقاق', totalVerses: 25, revelationType: 'Makki'),
    QuranSurah(number: 85, nameEn: 'Al-Buruj', nameTranslation: 'The Mansions of the Stars', nameAr: 'البروج', totalVerses: 22, revelationType: 'Makki'),
    QuranSurah(number: 86, nameEn: 'At-Tariq', nameTranslation: 'The Morning Star', nameAr: 'الطارق', totalVerses: 17, revelationType: 'Makki'),
    QuranSurah(number: 87, nameEn: "Al-A'la", nameTranslation: 'The Most High', nameAr: 'الأعلى', totalVerses: 19, revelationType: 'Makki'),
    QuranSurah(number: 88, nameEn: 'Al-Ghashiyah', nameTranslation: 'The Overwhelming', nameAr: 'الغاشية', totalVerses: 26, revelationType: 'Makki'),
    QuranSurah(number: 89, nameEn: 'Al-Fajr', nameTranslation: 'The Dawn', nameAr: 'الفجر', totalVerses: 30, revelationType: 'Makki'),
    QuranSurah(number: 90, nameEn: 'Al-Balad', nameTranslation: 'The City', nameAr: 'البلد', totalVerses: 20, revelationType: 'Makki'),
    QuranSurah(number: 91, nameEn: 'Ash-Shams', nameTranslation: 'The Sun', nameAr: 'الشمس', totalVerses: 15, revelationType: 'Makki'),
    QuranSurah(number: 92, nameEn: 'Al-Layl', nameTranslation: 'The Night', nameAr: 'الليل', totalVerses: 21, revelationType: 'Makki'),
    QuranSurah(number: 93, nameEn: 'Ad-Duhaa', nameTranslation: 'The Morning Hours', nameAr: 'الضحى', totalVerses: 11, revelationType: 'Makki'),
    QuranSurah(number: 94, nameEn: 'Ash-Sharh', nameTranslation: 'The Relief', nameAr: 'الشرح', totalVerses: 8, revelationType: 'Makki'),
    QuranSurah(number: 95, nameEn: 'At-Tin', nameTranslation: 'The Fig', nameAr: 'التين', totalVerses: 8, revelationType: 'Makki'),
    QuranSurah(number: 96, nameEn: "Al-'Alaq", nameTranslation: 'The Clot', nameAr: 'العلق', totalVerses: 19, revelationType: 'Makki'),
    QuranSurah(number: 97, nameEn: 'Al-Qadr', nameTranslation: 'The Power', nameAr: 'القدر', totalVerses: 5, revelationType: 'Makki'),
    QuranSurah(number: 98, nameEn: 'Al-Bayyinah', nameTranslation: 'The Clear Proof', nameAr: 'البينة', totalVerses: 8, revelationType: 'Madani'),
    QuranSurah(number: 99, nameEn: 'Az-Zalzalah', nameTranslation: 'The Earthquake', nameAr: 'الزلزلة', totalVerses: 8, revelationType: 'Madani'),
    QuranSurah(number: 100, nameEn: "Al-'Adiyat", nameTranslation: 'The Courser', nameAr: 'العاديات', totalVerses: 11, revelationType: 'Makki'),
    QuranSurah(number: 101, nameEn: "Al-Qari'ah", nameTranslation: 'The Calamity', nameAr: 'القارعة', totalVerses: 11, revelationType: 'Makki'),
    QuranSurah(number: 102, nameEn: 'At-Takathur', nameTranslation: 'The Rivalry in World Increase', nameAr: 'التكاثر', totalVerses: 8, revelationType: 'Makki'),
    QuranSurah(number: 103, nameEn: "Al-'Asr", nameTranslation: 'The Declining Day', nameAr: 'العصر', totalVerses: 3, revelationType: 'Makki'),
    QuranSurah(number: 104, nameEn: 'Al-Humazah', nameTranslation: 'The Traducer', nameAr: 'الهمزة', totalVerses: 9, revelationType: 'Makki'),
    QuranSurah(number: 105, nameEn: 'Al-Fil', nameTranslation: 'The Elephant', nameAr: 'الفيل', totalVerses: 5, revelationType: 'Makki'),
    QuranSurah(number: 106, nameEn: 'Quraysh', nameTranslation: 'Quraysh', nameAr: 'قريش', totalVerses: 4, revelationType: 'Makki'),
    QuranSurah(number: 107, nameEn: "Al-Ma'un", nameTranslation: 'The Small Kindness', nameAr: 'الماعون', totalVerses: 7, revelationType: 'Makki'),
    QuranSurah(number: 108, nameEn: 'Al-Kawthar', nameTranslation: 'The Abundance', nameAr: 'الكوثر', totalVerses: 3, revelationType: 'Makki'),
    QuranSurah(number: 109, nameEn: 'Al-Kafirun', nameTranslation: 'The Disbelievers', nameAr: 'الكافرون', totalVerses: 6, revelationType: 'Makki'),
    QuranSurah(number: 110, nameEn: 'An-Nasr', nameTranslation: 'The Divine Support', nameAr: 'النصر', totalVerses: 3, revelationType: 'Madani'),
    QuranSurah(number: 111, nameEn: 'Al-Masad', nameTranslation: 'The Palm Fiber', nameAr: 'المسد', totalVerses: 5, revelationType: 'Makki'),
    QuranSurah(number: 112, nameEn: 'Al-Ikhlas', nameTranslation: 'The Sincerity', nameAr: 'الإخلاص', totalVerses: 4, revelationType: 'Makki'),
    QuranSurah(number: 113, nameEn: 'Al-Falaq', nameTranslation: 'The Daybreak', nameAr: 'الفلق', totalVerses: 5, revelationType: 'Makki'),
    QuranSurah(number: 114, nameEn: 'An-Nas', nameTranslation: 'Mankind', nameAr: 'الناس', totalVerses: 6, revelationType: 'Makki'),
  ];

  static QuranSurah? getByNumber(int number) {
    if (number < 1 || number > 114) return null;
    return surahs[number - 1];
  }

  static QuranSurah? findByName(String query) {
    final clean = query.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    for (final s in surahs) {
      final sClean = s.nameEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (sClean == clean || sClean.contains(clean) || clean.contains(sClean)) {
        return s;
      }
    }
    return null;
  }

  static bool isValidVerseRange(int surahNumber, int startVerse, int endVerse) {
    final surah = getByNumber(surahNumber);
    if (surah == null) return false;
    if (startVerse < 1 || endVerse < startVerse) return false;
    if (endVerse > surah.totalVerses) return false;
    return true;
  }
}
