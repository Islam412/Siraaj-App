class Reciter {
  final String id;
  final String name;
  final String englishName;
  final String format;
  final String? audioUrl;

  Reciter({
    required this.id,
    required this.name,
    required this.englishName,
    this.format = 'audio',
    this.audioUrl,
  });
}

class RecitersData {
  static final List<Reciter> reciters = [
    Reciter(
      id: 'ar.alafasy',
      name: 'مشاري راشد العفاسي',
      englishName: 'Mishari Rashid Alafasy',
    ),
    Reciter(
      id: 'ar.abdurrahmaansudais',
      name: 'عبد الرحمن السديس',
      englishName: 'Abdurrahmaan As-Sudais',
    ),
    Reciter(
      id: 'ar.saoodshuraym',
      name: 'سعود الشريم',
      englishName: 'Saood Shuraym',
    ),
    Reciter(
      id: 'ar.mahermuaiqly',
      name: 'ماهر المعيقلي',
      englishName: 'Maher Al Muaiqly',
    ),
    Reciter(
      id: 'ar.abdullahbasfar',
      name: 'عبدالله بصفر',
      englishName: 'Abdullah Basfar',
    ),
    Reciter(
      id: 'ar.husary',
      name: 'محمود خليل الحصري',
      englishName: 'Mahmoud Khalil Al-Husary',
    ),
    Reciter(
      id: 'ar.husarymujawwad',
      name: 'الحصري (مجود)',
      englishName: 'Mahmoud Khalil Al-Husary (Mujawwad)',
    ),
    Reciter(
      id: 'ar.minshawi',
      name: 'محمد صديق المنشاوي',
      englishName: 'Mohammad Siddiq Al-Minshawi',
    ),
    Reciter(
      id: 'ar.minshawimujawwad',
      name: 'المنشاوي (مجود)',
      englishName: 'Mohammad Siddiq Al-Minshawi (Mujawwad)',
    ),
    Reciter(
      id: 'ar.abdulbasitmurattal',
      name: 'عبد الباسط (مرتل)',
      englishName: 'Abdul Basit (Murattal)',
    ),
    Reciter(
      id: 'ar.abdulbasitmujawwad',
      name: 'عبد الباسط (مجود)',
      englishName: 'Abdul Basit (Mujawwad)',
    ),
    Reciter(
      id: 'ar.muhammadayyoub',
      name: 'محمد أيوب',
      englishName: 'Muhammad Ayyoub',
    ),
    Reciter(
      id: 'ar.muhammadjibreel',
      name: 'محمد جبريل',
      englishName: 'Muhammad Jibreel',
    ),
    Reciter(
      id: 'ar.ibrahimakhdar',
      name: 'إبراهيم الأخضر',
      englishName: 'Ibrahim Akhdar',
    ),
    Reciter(
      id: 'ar.hanirifai',
      name: 'هاني الرفاعي',
      englishName: 'Hani Rifai',
    ),
    Reciter(
      id: 'ar.ahmadajamy',
      name: 'أحمد الأعجمي',
      englishName: 'Ahmed Al-Ajamy',
    ),
    Reciter(
      id: 'ar.shaatree',
      name: 'أبو بكر الشاطري',
      englishName: 'Abu Bakr Ash-Shaatree',
    ),
    Reciter(
      id: 'ar.aliabdurrahman',
      name: 'علي الحذيفي',
      englishName: 'Ali Abdur-Rahman',
    ),
    Reciter(
      id: 'ar.yasserdossari',
      name: 'ياسر الدوسري',
      englishName: 'Yasser Ad-Dossari',
    ),
  ];
}