class QuranData {
  static final List<SurahData> surahs = [
    SurahData(
      number: 1,
      name: 'الفاتحة',
      englishName: 'Al-Fatiha',
      versesCount: 7,
      revelationType: 'Meccan',
      verses: [
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'الرَّحْمَٰنِ الرَّحِيمِ',
        'مَالِكِ يَوْمِ الدِّينِ',
        'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      ],
    ),
    SurahData(
      number: 2,
      name: 'البقرة',
      englishName: 'Al-Baqara',
      versesCount: 286,
      revelationType: 'Medinan',
      verses: [
        // آيات سورة البقرة كاملة (هنا نضع الآيات الـ 286)
        'الم',
        'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
        // ... بقية الآيات
      ],
    ),
    // ... بقية السور الـ 114
  ];
}

class SurahData {
  final int number;
  final String name;
  final String englishName;
  final int versesCount;
  final String revelationType;
  final List<String> verses;

  SurahData({
    required this.number,
    required this.name,
    required this.englishName,
    required this.versesCount,
    required this.revelationType,
    required this.verses,
  });
}