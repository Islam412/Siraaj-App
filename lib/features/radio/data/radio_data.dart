class RadioStation {
  final String id;
  final String name;
  final String country;
  final String city;
  final String mosque;
  final String streamUrl;
  final String flagEmoji;
  final bool isLive;
  final String? alternativeUrl;

  const RadioStation({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.mosque,
    required this.streamUrl,
    required this.flagEmoji,
    this.isLive = true,
    this.alternativeUrl,
  });
}

class RadioData {
  static const List<RadioStation> stations = [
    // السعودية - روابط موثوقة
    RadioStation(
      id: '1',
      name: 'إذاعة القرآن الكريم',
      country: 'السعودية',
      city: 'مكة المكرمة',
      mosque: 'المسجد الحرام',
      streamUrl: 'https://live.haramain.info/quran_128',
      flagEmoji: '🇸🇦',
    ),
    RadioStation(
      id: '2',
      name: 'إذاعة السنة النبوية',
      country: 'السعودية',
      city: 'المدينة المنورة',
      mosque: 'المسجد النبوي',
      streamUrl: 'https://live.haramain.info/sunnah_128',
      flagEmoji: '🇦',
    ),
    
    // مصر
    RadioStation(
      id: '3',
      name: 'إذاعة القرآن الكريم - مصر',
      country: 'مصر',
      city: 'القاهرة',
      mosque: 'إذاعة القرآن الكريم',
      streamUrl: 'https://n06.radiojar.com/8s5u5tpdtwzuv',
      flagEmoji: '🇪🇬',
    ),
    
    // الكويت
    RadioStation(
      id: '4',
      name: 'إذاعة القرآن الكريم',
      country: 'الكويت',
      city: 'الكويت',
      mosque: 'وزارة الأوقاف',
      streamUrl: 'https://qurango.net/radio/quran_kuwait',
      flagEmoji: '🇰🇼',
    ),
    
    // الأردن
    RadioStation(
      id: '5',
      name: 'إذاعة القرآن الكريم',
      country: 'الأردن',
      city: 'عمان',
      mosque: 'دائرة الإفتاء',
      streamUrl: 'https://qurango.net/radio/quran_jordan',
      flagEmoji: '🇴',
    ),
    
    // المغرب
    RadioStation(
      id: '6',
      name: 'إذاعة محمد السادس',
      country: 'المغرب',
      city: 'الرباط',
      mosque: 'مسجد الحسن الثاني',
      streamUrl: 'https://radio.mohammedvi.ma/radio/8000/radio.mp3',
      flagEmoji: '🇲🇦',
    ),
    
    // تونس
    RadioStation(
      id: '7',
      name: 'إذاعة القرآن الكريم',
      country: 'تونس',
      city: 'تونس',
      mosque: 'جامع الزيتونة',
      streamUrl: 'https://qurango.net/radio/quran_tunisia',
      flagEmoji: '🇹',
    ),
    
    // الإمارات
    RadioStation(
      id: '8',
      name: 'إذاعة القرآن الكريم',
      country: 'الإمارات',
      city: 'دبي',
      mosque: 'هيئة الشؤون الإسلامية',
      streamUrl: 'https://qurango.net/radio/quran_uae',
      flagEmoji: '🇦',
    ),
    
    // قطر
    RadioStation(
      id: '9',
      name: 'إذاعة القرآن الكريم',
      country: 'قطر',
      city: 'الدوحة',
      mosque: 'وزارة الأوقاف',
      streamUrl: 'https://qurango.net/radio/quran_qatar',
      flagEmoji: '🇶🇦',
    ),
    
    // البحرين
    RadioStation(
      id: '10',
      name: 'إذاعة القرآن الكريم',
      country: 'البحرين',
      city: 'المنامة',
      mosque: 'مسجد الفاتح',
      streamUrl: 'https://qurango.net/radio/quran_bahrain',
      flagEmoji: '🇧🇭',
    ),
    
    // عمان
    RadioStation(
      id: '11',
      name: 'إذاعة القرآن الكريم',
      country: 'عمان',
      city: 'مسقط',
      mosque: 'الجامع الكبير',
      streamUrl: 'https://qurango.net/radio/quran_oman',
      flagEmoji: '🇴🇲',
    ),
    
    // العراق
    RadioStation(
      id: '12',
      name: 'إذاعة القرآن الكريم',
      country: 'العراق',
      city: 'بغداد',
      mosque: 'ديوان الوقف السني',
      streamUrl: 'https://qurango.net/radio/quran_iraq',
      flagEmoji: '🇶',
    ),
    
    // سوريا
    RadioStation(
      id: '13',
      name: 'إذاعة القرآن الكريم',
      country: 'سوريا',
      city: 'دمشق',
      mosque: 'مسجد الأموي',
      streamUrl: 'https://qurango.net/radio/quran_syria',
      flagEmoji: '🇸🇾',
    ),
    
    // لبنان
    RadioStation(
      id: '14',
      name: 'إذاعة القرآن الكريم',
      country: 'لبنان',
      city: 'بيروت',
      mosque: 'دار الفتوى',
      streamUrl: 'https://qurango.net/radio/quran_lebanon',
      flagEmoji: '🇱🇧',
    ),
    
    // الجزائر
    RadioStation(
      id: '15',
      name: 'إذاعة القرآن الكريم',
      country: 'الجزائر',
      city: 'الجزائر',
      mosque: 'مسجد الجزائر',
      streamUrl: 'https://qurango.net/radio/quran_algeria',
      flagEmoji: '🇩🇿',
    ),
    
    // ليبيا
    RadioStation(
      id: '16',
      name: 'إذاعة القرآن الكريم',
      country: 'ليبيا',
      city: 'طرابلس',
      mosque: 'وزارة الأوقاف',
      streamUrl: 'https://qurango.net/radio/quran_libya',
      flagEmoji: '🇱🇾',
    ),
    
    // اليمن
    RadioStation(
      id: '17',
      name: 'إذاعة القرآن الكريم',
      country: 'اليمن',
      city: 'صنعاء',
      mosque: 'مسجد الصالح',
      streamUrl: 'https://qurango.net/radio/quran_yemen',
      flagEmoji: '🇾🇪',
    ),
    
    // السودان
    RadioStation(
      id: '18',
      name: 'إذاعة القرآن الكريم',
      country: 'السودان',
      city: 'الخرطوم',
      mosque: 'المسجد الوطني',
      streamUrl: 'https://qurango.net/radio/quran_sudan',
      flagEmoji: '🇸🇩',
    ),
    
    // الصومال
    RadioStation(
      id: '19',
      name: 'إذاعة القرآن الكريم',
      country: 'الصومال',
      city: 'مقديشو',
      mosque: 'مسجد الأرقم',
      streamUrl: 'https://qurango.net/radio/quran_somalia',
      flagEmoji: '🇸',
    ),
    
    // موريتانيا
    RadioStation(
      id: '20',
      name: 'إذاعة القرآن الكريم',
      country: 'موريتانيا',
      city: 'نواكشوط',
      mosque: 'مسجد الهدى',
      streamUrl: 'https://qurango.net/radio/quran_mauritania',
      flagEmoji: '🇲🇷',
    ),
    
    // فلسطين
    RadioStation(
      id: '21',
      name: 'صوت فلسطين',
      country: 'فلسطين',
      city: 'القدس',
      mosque: 'المسجد الأقصى',
      streamUrl: 'https://qurango.net/radio/quran',
      flagEmoji: '🇵🇸',
    ),
    
    // إذاعات عالمية
    RadioStation(
      id: '22',
      name: 'إذاعة الرحمة',
      country: 'عالمية',
      city: 'بث عالمي',
      mosque: 'إذاعة الرحمة',
      streamUrl: 'https://qurango.net/radio/quran',
      flagEmoji: '🌍',
    ),
  ];

  static List<RadioStation> getStationsByCountry(String country) {
    return stations.where((s) => s.country == country).toList();
  }

  static List<String> getCountries() {
    return stations.map((s) => s.country).toSet().toList();
  }
  
  static String getStationStatus(String country) {
    // الدول التي تعمل روابطها بشكل موثوق
    final workingCountries = [
      'السعودية',
      'مصر',
      'المغرب',
    ];
    
    if (workingCountries.contains(country)) {
      return 'working';
    }
    return 'unknown';
  }
}
