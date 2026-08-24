class PodcastEpisode {
  final String id;
  final String title;
  final String speaker;
  final String description;
  final String audioUrl;
  final String duration;
  final String category;
  final String imageUrl;
  final DateTime date;

  const PodcastEpisode({
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

class PodcastData {
  // استخدم static final بدلاً من static const للسماح بـ DateTime
  static final List<PodcastEpisode> episodes = [
    PodcastEpisode(
      id: '1',
      title: 'سورة الفاتحة',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة خاشعة لسورة الفاتحة',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3',
      duration: '01:30',
      category: 'تلاوات',
      imageUrl: 'assets/images/podcast/quran.jpg',
      date: DateTime(2024, 1, 15),
    ),
    PodcastEpisode(
      id: '2',
      title: 'سورة الكهف',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة الكهف',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/018.mp3',
      duration: '25:40',
      category: 'تلاوات',
      imageUrl: 'assets/images/podcast/tafsir.jpg',
      date: DateTime(2024, 2, 5),
    ),
    PodcastEpisode(
      id: '3',
      title: 'سورة يس',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة يس',
      audioUrl: 'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/036.mp3',
      duration: '18:20',
      category: 'تلاوات',
      imageUrl: 'assets/images/podcast/yaseen.jpg',
      date: DateTime(2024, 3, 5),
    ),
    PodcastEpisode(
      id: '4',
      title: 'سورة الرحمن',
      speaker: 'عبد الباسط عبد الصمد',
      description: 'تلاوة مجودة لسورة الرحمن',
      audioUrl: 'https://download.quranicaudio.com/quran/abdul_basit_abdul_samad/055.mp3',
      duration: '22:15',
      category: 'تلاوات',
      imageUrl: 'assets/images/podcast/ruqyah.jpg',
      date: DateTime(2024, 2, 15),
    ),
    PodcastEpisode(
      id: '5',
      title: 'سورة الملك',
      speaker: 'أبو بكر الشاطري',
      description: 'تلاوة لسورة الملك المنجية من عذاب القبر',
      audioUrl: 'https://download.quranicaudio.com/quran/abu_bakr_ash_shaatree/067.mp3',
      duration: '12:30',
      category: 'تلاوات',
      imageUrl: 'assets/images/podcast/jannah.jpg',
      date: DateTime(2024, 3, 10),
    ),
  ];

  static List<String> getCategories() {
    return episodes.map((e) => e.category).toSet().toList();
  }

  static List<PodcastEpisode> getEpisodesByCategory(String category) {
    if (category == 'الكل') {
      return episodes;
    }
    return episodes.where((e) => e.category == category).toList();
  }
}
