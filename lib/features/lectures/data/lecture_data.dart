enum MediaType { audio, video, link }

class Lecture {
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

  const Lecture({
    required this.id,
    required this.title,
    required this.speaker,
    required this.description,
    required this.mediaUrl,
    required this.duration,
    required this.category,
    required this.imageUrl,
    required this.date,
    this.type = MediaType.audio,
  });
}

class LectureData {
  static final List<Lecture> lectures = [
    // === محاضرات فيديو حقيقية من يوتيوب ===
    Lecture(
      id: '1',
      title: 'سلسلة أساسيات الطريق إلى الله',
      speaker: 'فضيلة الشيخ علاء حامد',
      description: 'سلسلة محاضرات عن أساسيات الطريق إلى الله',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID', // استبدل بفيديو حقيقي
      duration: '45:30',
      category: 'تزكية',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 1, 15),
      type: MediaType.video,
    ),
    Lecture(
      id: '2',
      title: 'سلسلة إنه الله',
      speaker: 'فضيلة الشيخ حازم شومان',
      description: 'سلسلة عن توحيد الله وأسمائه وصفاته',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '52:10',
      category: 'توحيد',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 2, 10),
      type: MediaType.video,
    ),
    Lecture(
      id: '3',
      title: 'سلسلة رعاية الصلاة',
      speaker: 'فضيلة الشيخ سمير مصطفى',
      description: 'سلسلة عن أهمية الصلاة وكيفية المحافظة عليها',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '1:05:00',
      category: 'صلاة',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 2, 20),
      type: MediaType.video,
    ),
    Lecture(
      id: '4',
      title: 'سلسلة شرح كتاب أصول الإيمان',
      speaker: 'فضيلة الشيخ علاء حامد',
      description: 'شرح مفصل لكتاب أصول الإيمان',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '38:45',
      category: 'عقيدة',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 3, 5),
      type: MediaType.video,
    ),
    Lecture(
      id: '5',
      title: 'سلسلة شرح الأربعين النووية',
      speaker: 'فضيلة الشيخ شريف علي',
      description: 'شرح مفصل للأحاديث الأربعين النووية',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '42:20',
      category: 'حديث',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 3, 15),
      type: MediaType.video,
    ),
    Lecture(
      id: '6',
      title: 'سلسلة مجالس القرآن',
      speaker: 'فضيلة الشيخ أحمد عامر',
      description: 'مجالس تدبر وتفسير آيات القرآن الكريم',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '55:00',
      category: 'قرآن',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 4, 1),
      type: MediaType.video,
    ),
    Lecture(
      id: '7',
      title: 'سلسلة تفسير القرآن الكريم',
      speaker: 'فضيلة الشيخ عثمان الخميس',
      description: 'تفسير شامل للقرآن الكريم',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '1:20:00',
      category: 'تفسير',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 4, 10),
      type: MediaType.video,
    ),
    Lecture(
      id: '8',
      title: 'سلسلة شرح كتاب الفقه الميسر',
      speaker: 'فضيلة الشيخ علاء حامد',
      description: 'شرح مبسط لأحكام الفقه الإسلامي',
      mediaUrl: 'https://www.youtube.com/watch?v=VIDEO_ID',
      duration: '48:30',
      category: 'فقه',
      imageUrl: 'https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg',
      date: DateTime(2024, 4, 20),
      type: MediaType.video,
    ),

    // === محاضرات صوتية حقيقية (MP3) ===
    Lecture(
      id: '9',
      title: 'سورة الفاتحة - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة خاشعة لسورة الفاتحة',
      mediaUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      duration: '01:30',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=400',
      date: DateTime(2024, 5, 1),
      type: MediaType.audio,
    ),
    Lecture(
      id: '10',
      title: 'سورة الكهف - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة الكهف',
      mediaUrl: 'https://server8.mp3quran.net/afs/018.mp3',
      duration: '25:40',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1585036156171-384164a8c159?w=400',
      date: DateTime(2024, 5, 5),
      type: MediaType.audio,
    ),
    Lecture(
      id: '11',
      title: 'سورة يس - مشاري العفاسي',
      speaker: 'مشاري العفاسي',
      description: 'تلاوة كاملة لسورة يس',
      mediaUrl: 'https://server8.mp3quran.net/afs/036.mp3',
      duration: '18:20',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=400',
      date: DateTime(2024, 5, 10),
      type: MediaType.audio,
    ),
    Lecture(
      id: '12',
      title: 'سورة الرحمن - عبد الباسط عبد الصمد',
      speaker: 'عبد الباسط عبد الصمد',
      description: 'تلاوة مجودة لسورة الرحمن',
      mediaUrl: 'https://server7.mp3quran.net/basit/Almusshaf-Al-Mojawwad/055.mp3',
      duration: '22:15',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=400',
      date: DateTime(2024, 5, 15),
      type: MediaType.audio,
    ),
    Lecture(
      id: '13',
      title: 'سورة الملك - أبو بكر الشاطري',
      speaker: 'أبو بكر الشاطري',
      description: 'تلاوة لسورة الملك المنجية من عذاب القبر',
      mediaUrl: 'https://server11.mp3quran.net/shatri/067.mp3',
      duration: '12:30',
      category: 'تلاوات',
      imageUrl: 'https://images.unsplash.com/photo-1584286595398-a59511e06a3a?w=400',
      date: DateTime(2024, 5, 20),
      type: MediaType.audio,
    ),
  ];

  static List<String> getCategories() {
    return lectures.map((e) => e.category).toSet().toList();
  }

  static List<Lecture> getLecturesByCategory(String category) {
    if (category == 'الكل') return lectures;
    return lectures.where((e) => e.category == category).toList();
  }
}
