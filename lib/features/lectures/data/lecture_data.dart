class Lecture {
  final String id;
  final String title;
  final String speaker;
  final String description;
  final String audioUrl;
  final String duration;
  final String category;
  final String imageUrl;
  final DateTime date;

  const Lecture({
    required this.id,
    required this.title,
    required this.speaker,
    required this.description,
    required this.audioUrl,
    required this.duration,
    required this.category,
    required this.imageUrl,
    required this.date,
  });
}

class LectureData {
  // استخدام static final لتجنب مشكلة DateTime مع const
  static final List<Lecture> lectures = [
    Lecture(
      id: '1',
      title: 'أشراط الساعة الصغرى والكبرى',
      speaker: 'الشيخ محمد حسان',
      description: 'شرح مفصل وبيان لأشراط الساعة وما يجب على المسلم فعله',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3',
      duration: '45:30',
      category: 'عقيدة',
      imageUrl: 'assets/images/lectures/aqeedah.jpg',
      date: DateTime(2024, 1, 15),
    ),
    Lecture(
      id: '2',
      title: 'فقه الصلاة وأحكامها',
      speaker: 'الشيخ سعد الشثري',
      description: 'بيان أركان الصلاة وواجباتها وسننها ومبطلاتها',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/002.mp3',
      duration: '52:10',
      category: 'فقه',
      imageUrl: 'assets/images/lectures/fiqh.jpg',
      date: DateTime(2024, 2, 10),
    ),
    Lecture(
      id: '3',
      title: 'قصص من السيرة النبوية',
      speaker: 'الدكتور راغب السرجاني',
      description: 'مواقف وعبر من حياة النبي صلى الله عليه وسلم',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/003.mp3',
      duration: '1:05:00',
      category: 'سيرة',
      imageUrl: 'assets/images/lectures/seerah.jpg',
      date: DateTime(2024, 2, 20),
    ),
    Lecture(
      id: '4',
      title: 'تزكية النفس وتهذيب الأخلاق',
      speaker: 'الشيخ محمد العريفي',
      description: 'كيفية تطهير القلب من الأمراض وتحليته بالأخلاق الحميدة',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/004.mp3',
      duration: '38:45',
      category: 'تزكية',
      imageUrl: 'assets/images/lectures/tazkiyah.jpg',
      date: DateTime(2024, 3, 5),
    ),
    Lecture(
      id: '5',
      title: 'أهمية طلب العلم الشرعي',
      speaker: 'الشيخ عبد المحسن العباد',
      description: 'فضل العلم والعلماء وآداب طالب العلم',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/005.mp3',
      duration: '42:20',
      category: 'منهجية',
      imageUrl: 'assets/images/lectures/manhaj.jpg',
      date: DateTime(2024, 3, 15),
    ),
  ];

  static List<String> getCategories() {
    return lectures.map((e) => e.category).toSet().toList();
  }

  static List<Lecture> getLecturesByCategory(String category) {
    if (category == 'الكل') {
      return lectures;
    }
    return lectures.where((e) => e.category == category).toList();
  }
}
