class KhatamPlan {
  final String id;
  final String name;
  final int durationDays;
  final int pagesPerDay;
  final String description;

  const KhatamPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.pagesPerDay,
    required this.description,
  });
}

class SurahInfo {
  final int number;
  final String name;
  final int ayahCount;

  const SurahInfo({required this.number, required this.name, required this.ayahCount});
}

class QuranTrackerData {
  // خطط الختم المتاحة
  static const List<KhatamPlan> plans = [
    KhatamPlan(
      id: '1',
      name: 'ختم في شهر',
      durationDays: 30,
      pagesPerDay: 20, // جزء يومياً
      description: 'قراءة جزء واحد يومياً (20 صفحة)',
    ),
    KhatamPlan(
      id: '2',
      name: 'ختم في شهرين',
      durationDays: 60,
      pagesPerDay: 10, // نصف جزء يومياً
      description: 'قراءة نصف جزء يومياً (10 صفحات)',
    ),
    KhatamPlan(
      id: '3',
      name: 'ختم في 3 أشهر',
      durationDays: 90,
      pagesPerDay: 7, // تقريباً
      description: 'قراءة 7 صفحات يومياً',
    ),
    KhatamPlan(
      id: '4',
      name: 'ختم في 6 أشهر',
      durationDays: 180,
      pagesPerDay: 3,
      description: 'قراءة 3 صفحات يومياً (مثالي للمبتدئين)',
    ),
  ];

  // قائمة السور لتتبع الحفظ (يمكن توسيعها لتشمل 114 سورة)
  static const List<SurahInfo> surahs = [
    SurahInfo(number: 1, name: 'الفاتحة', ayahCount: 7),
    SurahInfo(number: 2, name: 'البقرة', ayahCount: 286),
    SurahInfo(number: 18, name: 'الكهف', ayahCount: 110),
    SurahInfo(number: 36, name: 'يس', ayahCount: 83),
    SurahInfo(number: 56, name: 'الواقعة', ayahCount: 96),
    SurahInfo(number: 67, name: 'الملك', ayahCount: 30),
    SurahInfo(number: 78, name: 'النبأ', ayahCount: 40),
    SurahInfo(number: 79, name: 'النازعات', ayahCount: 46),
    SurahInfo(number: 80, name: 'عبس', ayahCount: 42),
    SurahInfo(number: 81, name: 'التكوير', ayahCount: 29),
    SurahInfo(number: 82, name: 'الانفطار', ayahCount: 19),
    SurahInfo(number: 83, name: 'المطففين', ayahCount: 36),
    SurahInfo(number: 84, name: 'الانشقاق', ayahCount: 25),
    SurahInfo(number: 85, name: 'البروج', ayahCount: 22),
    SurahInfo(number: 86, name: 'الطارق', ayahCount: 17),
    SurahInfo(number: 87, name: 'الأعلى', ayahCount: 19),
    SurahInfo(number: 88, name: 'الغاشية', ayahCount: 26),
    SurahInfo(number: 89, name: 'الفجر', ayahCount: 30),
    SurahInfo(number: 90, name: 'البلد', ayahCount: 20),
    SurahInfo(number: 91, name: 'الشمس', ayahCount: 15),
    SurahInfo(number: 92, name: 'الليل', ayahCount: 21),
    SurahInfo(number: 93, name: 'الضحى', ayahCount: 11),
    SurahInfo(number: 94, name: 'الشرح', ayahCount: 8),
    SurahInfo(number: 95, name: 'التين', ayahCount: 8),
    SurahInfo(number: 96, name: 'العلق', ayahCount: 19),
    SurahInfo(number: 97, name: 'القدر', ayahCount: 5),
    SurahInfo(number: 98, name: 'البينة', ayahCount: 8),
    SurahInfo(number: 99, name: 'الزلزلة', ayahCount: 8),
    SurahInfo(number: 100, name: 'العاديات', ayahCount: 11),
    SurahInfo(number: 101, name: 'القارعة', ayahCount: 11),
    SurahInfo(number: 102, name: 'التكاثر', ayahCount: 8),
    SurahInfo(number: 103, name: 'العصر', ayahCount: 3),
    SurahInfo(number: 104, name: 'الهمزة', ayahCount: 9),
    SurahInfo(number: 105, name: 'الفيل', ayahCount: 5),
    SurahInfo(number: 106, name: 'قريش', ayahCount: 4),
    SurahInfo(number: 107, name: 'الماعون', ayahCount: 7),
    SurahInfo(number: 108, name: 'الكوثر', ayahCount: 3),
    SurahInfo(number: 109, name: 'الكافرون', ayahCount: 6),
    SurahInfo(number: 110, name: 'النصر', ayahCount: 3),
    SurahInfo(number: 111, name: 'المسد', ayahCount: 5),
    SurahInfo(number: 112, name: 'الإخلاص', ayahCount: 4),
    SurahInfo(number: 113, name: 'الفلق', ayahCount: 5),
    SurahInfo(number: 114, name: 'الناس', ayahCount: 6),
  ];
}
