class TafsirBook {
  final String id;
  final String name;
  final String author;
  final String description;
  final String? apiEndpoint;

  TafsirBook({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    this.apiEndpoint,
  });
}

class TafsirData {
  static final List<TafsirBook> books = [
    TafsirBook(
      id: 'muyassar',
      name: 'التفسير الميسر',
      author: 'مجمع الملك فهد لطباعة المصحف',
      description: 'تفسير مختصر وسهل الفهم',
      apiEndpoint: 'ar.muyassar',
    ),
    TafsirBook(
      id: 'jalalayn',
      name: 'تفسير الجلالين',
      author: 'جلال الدين المحلي وجلال الدين السيوطي',
      description: 'من أشهر التفاسير المختصرة',
      apiEndpoint: 'ar.jalalayn',
    ),
    TafsirBook(
      id: 'saddi',
      name: 'تفسير السعدي',
      author: 'عبد الرحمن بن ناصر السعدي',
      description: 'تفسير واضح ومختصر',
      apiEndpoint: 'ar.saddi',
    ),
    TafsirBook(
      id: 'baghawy',
      name: 'تفسير البغوي',
      author: 'الحسين بن مسعود البغوي',
      description: 'معالم التنزيل في تفسير القرآن',
      apiEndpoint: 'ar.baghawy',
    ),
    TafsirBook(
      id: 'qurtubi',
      name: 'تفسير القرطبي',
      author: 'محمد بن أحمد القرطبي',
      description: 'الجامع لأحكام القرآن',
      apiEndpoint: 'ar.qurtubi',
    ),
    TafsirBook(
      id: 'tabari',
      name: 'تفسير الطبري',
      author: 'محمد بن جرير الطبري',
      description: 'جامع البيان عن تأويل آي القرآن',
      apiEndpoint: 'ar.tabari',
    ),
    TafsirBook(
      id: 'ibnkathir',
      name: 'تفسير ابن كثير',
      author: 'إسماعيل بن عمر بن كثير',
      description: 'تفسير القرآن العظيم',
      apiEndpoint: 'ar.ibnkathir',
    ),
  ];
}