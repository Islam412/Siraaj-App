enum MediaType { audio, video, link }

class PodcastEpisode {
  final String id;
  final String title;
  final String speaker;
  final String description;
  final String mediaUrl;
  final String duration;
  final String category;
  final String imageUrl;
  final DateTime date;
  final MediaType type;

  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.speaker,
    required this.description,
    required this.mediaUrl,
    required this.duration,
    required this.category,
    required this.imageUrl,
    required this.date,
    this.type = MediaType.video,
  });
}

class PodcastData {
  static final List<PodcastEpisode> episodes = [
    // === البودكاست من الصورة ===
    PodcastEpisode(
      id: '1',
      title: 'آية وحكاية',
      speaker: 'برنامج ديني',
      description: 'رحلة مع آيات القرآن الكريم تكشف قصصها وحكمها وأثرها في النفس والحياة.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample1', // ضع الرابط الحقيقي
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example1/maxresdefault.jpg', // ضع الصورة الحقيقية
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '2',
      title: 'إيه المشكلة؟',
      speaker: 'برنامج شبابي',
      description: 'بودكاست يطرح إشكاليات الشباب المسلم ويعالجها بصراحة وعلم مع ضيوف متنوعين.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample2',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example2/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '3',
      title: 'وعي',
      speaker: 'برنامج توعوي',
      description: 'محتوى يبني الوعي الإسلامي الحقيقي ويربط المسلم بدينه وبواقعه بصورة متوازنة.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample3',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example3/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '4',
      title: 'خاطرم',
      speaker: 'برنامج فكري',
      description: 'بودكاست يناقش قضايا الإيمان والحياة بأسلوب شبابي عميق يلامس القلب والعقل.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample4',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example4/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '5',
      title: 'إستراحة',
      speaker: 'برنامج روحي',
      description: 'لحظة هدوء وتأمل – محادثات روحانية هادئة تُريح القلب وتُجدد الصلة بالله.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample5',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example5/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '6',
      title: 'كيف الطريق',
      speaker: 'برنامج إرشادي',
      description: 'مساعدة عملية لكل من يبحث عن الطريق إلى الله ويريد أن يبدأ من حيث هو.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample6',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example6/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),
    PodcastEpisode(
      id: '7',
      title: 'سائر',
      speaker: 'برنامج تذكيري',
      description: 'بودكاست يرافقك في رحلتك نحو الله، ويُذكّرك بمعنى السير إليه خطوة بخطوة.',
      mediaUrl: 'https://www.youtube.com/playlist?list=PLexample7',
      duration: '',
      category: 'بودكاست',
      imageUrl: 'https://i.ytimg.com/vi/example7/maxresdefault.jpg',
      date: DateTime(2024, 1, 1),
      type: MediaType.video,
    ),

    // === محاضرات صوتية (MP3) ===
    PodcastEpisode(
      id: '8',
      title: 'سورة الفاتحة - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة خاشعة لسورة الفاتحة',
      mediaUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      duration: '01:30',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=400',
      date: DateTime(2024, 2, 1),
      type: MediaType.audio,
    ),
    PodcastEpisode(
      id: '9',
      title: 'سورة الكهف - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة الكهف',
      mediaUrl: 'https://server8.mp3quran.net/afs/018.mp3',
      duration: '25:40',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1585036156171-384164a8c159?w=400',
      date: DateTime(2024, 2, 5),
      type: MediaType.audio,
    ),
    PodcastEpisode(
      id: '10',
      title: 'سورة يس - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة يس',
      mediaUrl: 'https://server8.mp3quran.net/afs/036.mp3',
      duration: '18:20',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=400',
      date: DateTime(2024, 3, 1),
      type: MediaType.audio,
    ),
  ];

  static List<String> getCategories() {
    return episodes.map((e) => e.category).toSet().toList();
  }

  static List<PodcastEpisode> getEpisodesByCategory(String category) {
    if (category == 'الكل') return episodes;
    return episodes.where((e) => e.category == category).toList();
  }
}
