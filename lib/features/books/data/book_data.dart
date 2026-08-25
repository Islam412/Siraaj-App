enum BookCategory { tafsir, aqeedah, faith, qiyamah, children, hadith, general }

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverImageUrl;
  final String pdfUrl; // رابط القراءة
  final String downloadUrl; // رابط التحميل
  final BookCategory category;
  final int pages;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverImageUrl,
    required this.pdfUrl,
    required this.downloadUrl,
    required this.category,
    required this.pages,
  });
}

class BookData {
  static final List<Book> books = [
    // === كتب التفسير ===
    Book(
      id: '1',
      title: 'تفسير القرآن العظيم',
      author: 'ابن كثير',
      description: 'أشهر كتب التفسير بالمأثور، يجمع بين الآيات والأحاديث وأقوال الصحابة والتابعين',
      coverImageUrl: 'https://example.com/covers/tafsir_ibn_kathir.jpg',
      pdfUrl: 'https://example.com/pdf/tafsir_ibn_kathir.pdf',
      downloadUrl: 'https://example.com/download/tafsir_ibn_kathir.pdf',
      category: BookCategory.tafsir,
      pages: 2500,
    ),
    Book(
      id: '2',
      title: 'جامع البيان (تفسير الطبري)',
      author: 'الإمام الطبري',
      description: 'أم كتب التفسير وأصلها، يعتمد الرواية والإسناد في استيعاب المعاني القرآنية',
      coverImageUrl: 'https://example.com/covers/tafsir_tabari.jpg',
      pdfUrl: 'https://example.com/pdf/tafsir_tabari.pdf',
      downloadUrl: 'https://example.com/download/tafsir_tabari.pdf',
      category: BookCategory.tafsir,
      pages: 3000,
    ),
    Book(
      id: '3',
      title: 'الجامع لأحكام القرآن',
      author: 'الإمام القرطبي',
      description: 'تفسير فقهي استنباطي شامل، يُعنى باستخراج الأحكام الشرعية من آيات القرآن',
      coverImageUrl: 'https://example.com/covers/tafsir_qurtubi.jpg',
      pdfUrl: 'https://example.com/pdf/tafsir_qurtubi.pdf',
      downloadUrl: 'https://example.com/download/tafsir_qurtubi.pdf',
      category: BookCategory.tafsir,
      pages: 2800,
    ),
    Book(
      id: '4',
      title: 'التفسير الميسر',
      author: 'مجمع الملك فهد',
      description: 'تفسير معاصر بأسلوب سهل واضح، يوضح معاني القرآن الكريم بإيجاز',
      coverImageUrl: 'https://example.com/covers/tafsir_muyassar.jpg',
      pdfUrl: 'https://example.com/pdf/tafsir_muyassar.pdf',
      downloadUrl: 'https://example.com/download/tafsir_muyassar.pdf',
      category: BookCategory.tafsir,
      pages: 600,
    ),
    Book(
      id: '5',
      title: 'علّمتني سورة البقرة',
      author: 'د. رقية محمود المحارب',
      description: 'رحلة روحية عميقة مع أعظم سور القرآن وكيف تُغيّر حياة المؤمن',
      coverImageUrl: 'https://example.com/covers/surat_albaqarah.jpg',
      pdfUrl: 'https://example.com/pdf/surat_albaqarah.pdf',
      downloadUrl: 'https://example.com/download/surat_albaqarah.pdf',
      category: BookCategory.tafsir,
      pages: 350,
    ),

    // === كتب العقيدة ===
    Book(
      id: '6',
      title: 'ما لا يسع المسلم جهله',
      author: 'د. محمد التويجري',
      description: 'دليل شامل وميسر للمسلم في أحكام الطهارة والصلاة والزكاة والحج وسائر العبادات',
      coverImageUrl: 'https://example.com/covers/ma_la_yasiu.jpg',
      pdfUrl: 'https://example.com/pdf/ma_la_yasiu.pdf',
      downloadUrl: 'https://example.com/download/ma_la_yasiu.pdf',
      category: BookCategory.aqeedah,
      pages: 450,
    ),
    Book(
      id: '7',
      title: 'العقيدة الطحاوية',
      author: 'الإمام الطحاوي',
      description: 'متن عقدي معتبر عند أهل السنة والجماعة، شرحه ابن عثيمين وابن باز',
      coverImageUrl: 'https://example.com/covers/aqeedah_tahawiyah.jpg',
      pdfUrl: 'https://example.com/pdf/aqeedah_tahawiyah.pdf',
      downloadUrl: 'https://example.com/download/aqeedah_tahawiyah.pdf',
      category: BookCategory.aqeedah,
      pages: 200,
    ),

    // === كتب الإيمان ===
    Book(
      id: '8',
      title: 'كتاب الإيمان',
      author: 'شيخ الإسلام ابن تيمية',
      description: 'بيان حقيقة الإيمان وأركانه وشروطه وما ينقضه',
      coverImageUrl: 'https://example.com/covers/kitab_aliman.jpg',
      pdfUrl: 'https://example.com/pdf/kitab_aliman.pdf',
      downloadUrl: 'https://example.com/download/kitab_aliman.pdf',
      category: BookCategory.faith,
      pages: 300,
    ),

    // === كتب علامات يوم القيامة ===
    Book(
      id: '9',
      title: 'نهاية العالم',
      author: 'د. عمر الأشقر',
      description: 'دراسة شاملة لعلامات الساعة الصغرى والكبرى',
      coverImageUrl: 'https://example.com/covers/alamah_qiyamah.jpg',
      pdfUrl: 'https://example.com/pdf/alamah_qiyamah.pdf',
      downloadUrl: 'https://example.com/download/alamah_qiyamah.pdf',
      category: BookCategory.qiyamah,
      pages: 400,
    ),

    // === كتب الأطفال ===
    Book(
      id: '10',
      title: 'قصص الأنبياء',
      author: 'محمد سعيد برغوث',
      description: 'قصص الأنبياء عليهم السلام بأسلوب شيق للأطفال',
      coverImageUrl: 'https://example.com/covers/qasas_anbiya.jpg',
      pdfUrl: 'https://example.com/pdf/qasas_anbiya.pdf',
      downloadUrl: 'https://example.com/download/qasas_anbiya.pdf',
      category: BookCategory.children,
      pages: 250,
    ),
    Book(
      id: '11',
      title: 'أطفال المسلمين',
      author: 'د. علي الخولي',
      description: 'كتاب تربوي للأطفال عن سيرة الصحابة والتابعين',
      coverImageUrl: 'https://example.com/covers/atfal_muslimin.jpg',
      pdfUrl: 'https://example.com/pdf/atfal_muslimin.pdf',
      downloadUrl: 'https://example.com/download/atfal_muslimin.pdf',
      category: BookCategory.children,
      pages: 180,
    ),

    // === كتب الحديث ===
    Book(
      id: '12',
      title: 'صحيح البخاري',
      author: 'الإمام البخاري',
      description: 'أصح كتب الأمة بعد كتاب الله',
      coverImageUrl: 'https://example.com/covers/sahih_bukhari.jpg',
      pdfUrl: 'https://example.com/pdf/sahih_bukhari.pdf',
      downloadUrl: 'https://example.com/download/sahih_bukhari.pdf',
      category: BookCategory.hadith,
      pages: 1800,
    ),
    Book(
      id: '13',
      title: 'صحيح مسلم',
      author: 'الإمام مسلم',
      description: 'ثاني أصح كتب الحديث بعد صحيح البخاري',
      coverImageUrl: 'https://example.com/covers/sahih_muslim.jpg',
      pdfUrl: 'https://example.com/pdf/sahih_muslim.pdf',
      downloadUrl: 'https://example.com/download/sahih_muslim.pdf',
      category: BookCategory.hadith,
      pages: 1600,
    ),
    Book(
      id: '14',
      title: 'سنن الترمذي',
      author: 'الإمام الترمذي',
      description: 'من أهم كتب السنن مع بيان درجة الأحاديث',
      coverImageUrl: 'https://example.com/covers/sunan_tirmidhi.jpg',
      pdfUrl: 'https://example.com/pdf/sunan_tirmidhi.pdf',
      downloadUrl: 'https://example.com/download/sunan_tirmidhi.pdf',
      category: BookCategory.hadith,
      pages: 1200,
    ),
    Book(
      id: '15',
      title: 'الأربعون النووية',
      author: 'الإمام النووي',
      description: 'أربعون حديثاً أصلاً في الدين',
      coverImageUrl: 'https://example.com/covers/arbaeen_nawawiyah.jpg',
      pdfUrl: 'https://example.com/pdf/arbaeen_nawawiyah.pdf',
      downloadUrl: 'https://example.com/download/arbaeen_nawawiyah.pdf',
      category: BookCategory.hadith,
      pages: 150,
    ),

    // === كتب عامة ===
    Book(
      id: '16',
      title: 'الداء والدواء',
      author: 'ابن القيم',
      description: 'كتاب في الطب النبوي وعلاج الأمراض بالأدوية الشرعية',
      coverImageUrl: 'https://example.com/covers/al_da_wa_al_dawa.jpg',
      pdfUrl: 'https://example.com/pdf/al_da_wa_al_dawa.pdf',
      downloadUrl: 'https://example.com/download/al_da_wa_al_dawa.pdf',
      category: BookCategory.general,
      pages: 400,
    ),
    Book(
      id: '17',
      title: 'علو الهمة',
      author: 'محمد بن إسماعيل',
      description: 'كتاب في تزكية النفس ورفع الهمة نحو الله',
      coverImageUrl: 'https://example.com/covers/uluw_al_himmah.jpg',
      pdfUrl: 'https://example.com/pdf/uluw_al_himmah.pdf',
      downloadUrl: 'https://example.com/download/uluw_al_himmah.pdf',
      category: BookCategory.general,
      pages: 200,
    ),
    Book(
      id: '18',
      title: 'رجال حول الرسول',
      author: 'عبد الرحمن رأفت الباشا',
      description: 'قصص الصحابة رضوان الله عليهم',
      coverImageUrl: 'https://example.com/covers/rijal_hawl_rasul.jpg',
      pdfUrl: 'https://example.com/pdf/rijal_hawl_rasul.pdf',
      downloadUrl: 'https://example.com/download/rijal_hawl_rasul.pdf',
      category: BookCategory.general,
      pages: 350,
    ),
    Book(
      id: '19',
      title: 'لا تحزن',
      author: 'د. عائض القرني',
      description: 'كتاب في علاج الهم والحزن من القرآن والسنة',
      coverImageUrl: 'https://example.com/covers/la_tahzan.jpg',
      pdfUrl: 'https://example.com/pdf/la_tahzan.pdf',
      downloadUrl: 'https://example.com/download/la_tahzan.pdf',
      category: BookCategory.general,
      pages: 300,
    ),
  ];

  static List<String> getCategories() {
    return books.map((e) => e.category.name).toSet().toList();
  }

  static List<Book> getBooksByCategory(BookCategory category) {
    return books.where((e) => e.category == category).toList();
  }

  static String getCategoryName(BookCategory category) {
    switch (category) {
      case BookCategory.tafsir: return 'التفسير';
      case BookCategory.aqeedah: return 'العقيدة';
      case BookCategory.faith: return 'الإيمان';
      case BookCategory.qiyamah: return 'يوم القيامة';
      case BookCategory.children: return 'الأطفال';
      case BookCategory.hadith: return 'الحديث';
      case BookCategory.general: return 'عامة';
    }
  }
}
