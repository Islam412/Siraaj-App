class Qiraah {
  final String id;
  final String name;
  final String description;
  final String reader;

  Qiraah({
    required this.id,
    required this.name,
    required this.description,
    required this.reader,
  });
}

class QiraatData {
  static final List<Qiraah> qiraat = [
    Qiraah(
      id: 'hafs',
      name: 'حفص عن عاصم',
      description: 'رواية حفص عن الإمام عاصم بن أبي النجود',
      reader: 'الأكثر انتشاراً في العالم الإسلامي',
    ),
    Qiraah(
      id: 'warsh',
      name: 'ورش عن نافع',
      description: 'رواية ورش عن الإمام نافع المدني',
      reader: 'شائعة في المغرب وشمال أفريقيا',
    ),
    Qiraah(
      id: 'qaloon',
      name: 'قالون عن نافع',
      description: 'رواية قالون عن الإمام نافع المدني',
      reader: 'شائعة في ليبيا وتونس',
    ),
    Qiraah(
      id: 'shubah',
      name: 'شعبة عن عاصم',
      description: 'رواية شعبة عن الإمام عاصم',
      reader: 'من روايات الكوفة',
    ),
    Qiraah(
      id: 'khalaf',
      name: 'خلف عن حمزة',
      description: 'رواية خلف عن الإمام حمزة',
      reader: 'من روايات الكوفة',
    ),
    Qiraah(
      id: 'khalifah',
      name: 'خلف عن يعقوب',
      description: 'رواية خلف عن الإمام يعقوب',
      reader: 'من روايات البصرة',
    ),
  ];
}