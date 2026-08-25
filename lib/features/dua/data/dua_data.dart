enum DuaCategory {
  prophets,
  rizq,
  rain,
  morning,
  evening,
  distress,
  travel,
  sickness,
  parents,
  forgiveness,
  guidance,
  protection,
  daily,
  quran,
  miscellaneous
}

class Dua {
  final String id;
  final String title;
  final String text;
  final String virtue; // فضل الدعاء
  final DuaCategory category;
  final String source; // المصدر (البخاري، مسلم، etc.)
  final int repeatCount; // عدد التكرار المستحب

  const Dua({
    required this.id,
    required this.title,
    required this.text,
    required this.virtue,
    required this.category,
    required this.source,
    this.repeatCount = 1,
  });
}

class DuaData {
  static final List<Dua> duas = [
    // ==========================================
    // === أدعية الأنبياء ===
    // ==========================================
    Dua(
      id: '1',
      title: 'دعاء سيدنا آدم',
      text: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      virtue: 'دعاء آدم وحواء بعد الأكل من الشجرة',
      category: DuaCategory.prophets,
      source: 'سورة الأعراف: 23',
      repeatCount: 1,
    ),
    Dua(
      id: '2',
      title: 'دعاء سيدنا نوح',
      text: 'رَّبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ ۖ وَإِلَّا تَغْفِرْ لِي وَتَرْحَمْنِي أَكُن مِّنَ الْخَاسِرِينَ',
      virtue: 'دعاء نوح عليه السلام',
      category: DuaCategory.prophets,
      source: 'سورة هود: 47',
      repeatCount: 1,
    ),
    Dua(
      id: '3',
      title: 'دعاء سيدنا إبراهيم',
      text: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      virtue: 'دعاء إبراهيم عليه السلام',
      category: DuaCategory.prophets,
      source: 'سورة إبراهيم: 40',
      repeatCount: 1,
    ),
    Dua(
      id: '4',
      title: 'دعاء سيدنا إبراهيم (الرزق)',
      text: 'رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
      virtue: 'دعاء إبراهيم عند بناء الكعبة',
      category: DuaCategory.prophets,
      source: 'سورة البقرة: 127',
      repeatCount: 1,
    ),
    Dua(
      id: '5',
      title: 'دعاء سيدنا يونس (ذو النون)',
      text: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      virtue: 'ما دعا بها رجل مسلم في شيء قط إلا استجاب الله له',
      category: DuaCategory.prophets,
      source: 'سورة الأنبياء: 87 - رواه الترمذي',
      repeatCount: 1,
    ),
    Dua(
      id: '6',
      title: 'دعاء سيدنا أيوب',
      text: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
      virtue: 'دعاء أيوب عند المرض',
      category: DuaCategory.prophets,
      source: 'سورة الأنبياء: 83',
      repeatCount: 1,
    ),
    Dua(
      id: '7',
      title: 'دعاء سيدنا زكريا',
      text: 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ',
      virtue: 'دعاء زكريا عليه السلام',
      category: DuaCategory.prophets,
      source: 'سورة الأنبياء: 89',
      repeatCount: 1,
    ),
    Dua(
      id: '8',
      title: 'دعاء سيدنا موسى',
      text: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
      virtue: 'دعاء موسى عند طلب العلم',
      category: DuaCategory.prophets,
      source: 'سورة طه: 25-28',
      repeatCount: 1,
    ),
    Dua(
      id: '9',
      title: 'دعاء سيدنا سليمان',
      text: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
      virtue: 'دعاء سليمان عليه السلام',
      category: DuaCategory.prophets,
      source: 'سورة النمل: 19',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية الرزق ===
    // ==========================================
    Dua(
      id: '10',
      title: 'دعاء الرزق الواسع',
      text: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      virtue: 'من قالها كفاه الله هم الدنيا',
      category: DuaCategory.rizq,
      source: 'رواه الترمذي',
      repeatCount: 3,
    ),
    Dua(
      id: '11',
      title: 'دعاء سداد الدين',
      text: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      virtue: 'دعاء سداد الدين',
      category: DuaCategory.rizq,
      source: 'رواه الترمذي',
      repeatCount: 1,
    ),
    Dua(
      id: '12',
      title: 'دعاء البركة في الرزق',
      text: 'اللَّهُمَّ بَارِكْ لَنَا فِيمَا رَزَقْتَنَا، وَقِنَا عَذَابَ النَّارِ',
      virtue: 'دعاء البركة',
      category: DuaCategory.rizq,
      source: 'رواه ابن ماجه',
      repeatCount: 1,
    ),
    Dua(
      id: '13',
      title: 'دعاء طلب الرزق الحلال',
      text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا طَيِّبًا، وَعَمَلًا مُتَقَبَّلًا',
      virtue: 'من قالها بعد الفجر بارك الله له في يومه',
      category: DuaCategory.rizq,
      source: 'رواه ابن ماجه',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية المطر ===
    // ==========================================
    Dua(
      id: '14',
      title: 'دعاء نزول المطر',
      text: 'اللَّهُمَّ صَيِّبًا نَافِعًا',
      virtue: 'كان النبي ﷺ يقولها عند نزول المطر',
      category: DuaCategory.rain,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '15',
      title: 'دعاء بعد المطر',
      text: 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ',
      virtue: 'من قالها بعد المطر',
      category: DuaCategory.rain,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '16',
      title: 'دعاء طلب المطر (الاستسقاء)',
      text: 'اللَّهُمَّ اسْقِنَا غَيْثًا مُغِيثًا مَرِيئًا مَرِيعًا نَافِعًا غَيْرَ ضَارٍّ، عَاجِلًا غَيْرَ آجِلٍ',
      virtue: 'دعاء الاستسقاء',
      category: DuaCategory.rain,
      source: 'رواه أبو داود',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية الصباح ===
    // ==========================================
    Dua(
      id: '17',
      title: 'دعاء الصباح',
      text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      virtue: 'من قالها حين يصبح فقد أدى ما عليه',
      category: DuaCategory.morning,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    Dua(
      id: '18',
      title: 'دعاء الصباح (اللهم بك أصبحنا)',
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      virtue: 'ذكر عظيم',
      category: DuaCategory.morning,
      source: 'رواه الترمذي',
      repeatCount: 1,
    ),
    Dua(
      id: '19',
      title: 'دعاء الصباح (اللهم أنت ربي)',
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      virtue: 'من قالها موقناً بها فمات من يومه دخل الجنة',
      category: DuaCategory.morning,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '20',
      title: 'دعاء الصباح (حسبي الله)',
      text: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      virtue: 'من قالها سبع مرات كفاه الله ما أهمه',
      category: DuaCategory.morning,
      source: 'رواه أبو داود',
      repeatCount: 7,
    ),

    // ==========================================
    // === أدعية المساء ===
    // ==========================================
    Dua(
      id: '21',
      title: 'دعاء المساء',
      text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      virtue: 'من قالها حين يمسي فقد أدى ما عليه',
      category: DuaCategory.evening,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    Dua(
      id: '22',
      title: 'دعاء المساء (أعوذ بكلمات الله)',
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      virtue: 'من قالها ثلاثاً لم تضره حمة تلك الليلة',
      category: DuaCategory.evening,
      source: 'رواه مسلم',
      repeatCount: 3,
    ),

    // ==========================================
    // === أدعية الكرب والهم ===
    // ==========================================
    Dua(
      id: '23',
      title: 'دعاء الكرب',
      text: 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ',
      virtue: 'دعاء الكرب',
      category: DuaCategory.distress,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '24',
      title: 'دعاء الهم والحزن',
      text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      virtue: 'دعاء الهم والحزن',
      category: DuaCategory.distress,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '25',
      title: 'دعاء ضيق الصدر',
      text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ',
      virtue: 'دعاء جامع',
      category: DuaCategory.distress,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '26',
      title: 'دعاء تفريج الهم',
      text: 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو، فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ',
      virtue: 'من قالها في كرب فرج الله عنه',
      category: DuaCategory.distress,
      source: 'رواه أبو داود',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية السفر ===
    // ==========================================
    Dua(
      id: '27',
      title: 'دعاء السفر',
      text: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
      virtue: 'دعاء السفر',
      category: DuaCategory.travel,
      source: 'سورة الزخرف: 13-14',
      repeatCount: 1,
    ),
    Dua(
      id: '28',
      title: 'دعاء دخول البلدة',
      text: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ، وَرَبَّ الْأَرَضِينَ وَمَا أَقْلَلْنَ',
      virtue: 'دعاء دخول البلدة',
      category: DuaCategory.travel,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية المرض ===
    // ==========================================
    Dua(
      id: '29',
      title: 'دعاء المريض',
      text: 'أَذْهِبِ الْبَأْسَ رَبَّ النَّاسِ، وَاشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      virtue: 'من قالها على المريض شفي بإذن الله',
      category: DuaCategory.sickness,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '30',
      title: 'دعاء عيادة المريض',
      text: 'لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
      virtue: 'دعاء عيادة المريض',
      category: DuaCategory.sickness,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية الوالدين ===
    // ==========================================
    Dua(
      id: '31',
      title: 'دعاء للوالدين',
      text: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      virtue: 'دعاء للوالدين',
      category: DuaCategory.parents,
      source: 'سورة الإسراء: 24',
      repeatCount: 1,
    ),
    Dua(
      id: '32',
      title: 'دعاء للوالدين (موسع)',
      text: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      virtue: 'دعاء للوالدين',
      category: DuaCategory.parents,
      source: 'سورة إبراهيم: 41',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية المغفرة ===
    // ==========================================
    Dua(
      id: '33',
      title: 'سيد الاستغفار',
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      virtue: 'من قالها موقناً بها فمات دخل الجنة',
      category: DuaCategory.forgiveness,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '34',
      title: 'دعاء الاستغفار',
      text: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      virtue: 'من قالها غفرت ذنوبه وإن كان فاراً من الزحف',
      category: DuaCategory.forgiveness,
      source: 'رواه أبو داود',
      repeatCount: 3,
    ),

    // ==========================================
    // === أدعية الهداية ===
    // ==========================================
    Dua(
      id: '35',
      title: 'دعاء الهداية',
      text: 'اللَّهُمَّ اهْدِنِي وَسَدِّدْنِي',
      virtue: 'دعاء الهداية',
      category: DuaCategory.guidance,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    Dua(
      id: '36',
      title: 'دعاء تثبيت القلب',
      text: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      virtue: 'كان النبي ﷺ يكثر من هذا الدعاء',
      category: DuaCategory.guidance,
      source: 'رواه الترمذي',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية الحماية ===
    // ==========================================
    Dua(
      id: '37',
      title: 'دعاء الحماية من الشر',
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      virtue: 'من قالها ثلاثاً لم تضره حمة تلك الليلة',
      category: DuaCategory.protection,
      source: 'رواه مسلم',
      repeatCount: 3,
    ),
    Dua(
      id: '38',
      title: 'دعاء الحماية من العين',
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      virtue: 'دعاء الحماية من العين',
      category: DuaCategory.protection,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية يومية ===
    // ==========================================
    Dua(
      id: '39',
      title: 'دعاء قبل النوم',
      text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      virtue: 'دعاء قبل النوم',
      category: DuaCategory.daily,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '40',
      title: 'دعاء الاستيقاظ',
      text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      virtue: 'دعاء الاستيقاظ',
      category: DuaCategory.daily,
      source: 'رواه البخاري',
      repeatCount: 1,
    ),
    Dua(
      id: '41',
      title: 'دعاء دخول المسجد',
      text: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      virtue: 'دعاء دخول المسجد',
      category: DuaCategory.daily,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    Dua(
      id: '42',
      title: 'دعاء الخروج من المسجد',
      text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      virtue: 'دعاء الخروج من المسجد',
      category: DuaCategory.daily,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
    Dua(
      id: '43',
      title: 'دعاء قبل الطعام',
      text: 'بِسْمِ اللَّهِ',
      virtue: 'من قالها قبل الطعام برك الله له فيه',
      category: DuaCategory.daily,
      source: 'رواه أبو داود',
      repeatCount: 1,
    ),
    Dua(
      id: '44',
      title: 'دعاء بعد الطعام',
      text: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      virtue: 'من قالها غفر الله له ما تقدم من ذنبه',
      category: DuaCategory.daily,
      source: 'رواه الترمذي',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية من القرآن ===
    // ==========================================
    Dua(
      id: '45',
      title: 'ربنا آتنا في الدنيا حسنة',
      text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      virtue: 'كان النبي ﷺ يكثر من هذا الدعاء',
      category: DuaCategory.quran,
      source: 'سورة البقرة: 201',
      repeatCount: 1,
    ),
    Dua(
      id: '46',
      title: 'ربنا لا تزغ قلوبنا',
      text: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ',
      virtue: 'دعاء من القرآن',
      category: DuaCategory.quran,
      source: 'سورة آل عمران: 8',
      repeatCount: 1,
    ),
    Dua(
      id: '47',
      title: 'ربنا هب لنا من أزواجنا',
      text: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      virtue: 'دعاء من القرآن',
      category: DuaCategory.quran,
      source: 'سورة الفرقان: 74',
      repeatCount: 1,
    ),

    // ==========================================
    // === أدعية متنوعة ===
    // ==========================================
    Dua(
      id: '48',
      title: 'دعاء ختام المجلس',
      text: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
      virtue: 'من قالها في مجلس غفر له ما كان فيه',
      category: DuaCategory.miscellaneous,
      source: 'رواه أبو داود',
      repeatCount: 1,
    ),
    Dua(
      id: '49',
      title: 'دعاء الوتر',
      text: 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ',
      virtue: 'دعاء القنوت في الوتر',
      category: DuaCategory.miscellaneous,
      source: 'رواه أبو داود',
      repeatCount: 1,
    ),
    Dua(
      id: '50',
      title: 'دعاء جامع',
      text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى',
      virtue: 'دعاء جامع',
      category: DuaCategory.miscellaneous,
      source: 'رواه مسلم',
      repeatCount: 1,
    ),
  ];

  static List<Dua> getDuasByCategory(DuaCategory category) {
    return duas.where((d) => d.category == category).toList();
  }

  static List<String> getCategories() {
    return [
      'الكل',
      'أدعية الأنبياء',
      'أدعية الرزق',
      'أدعية المطر',
      'أدعية الصباح',
      'أدعية المساء',
      'أدعية الكرب',
      'أدعية السفر',
      'أدعية المرض',
      'أدعية الوالدين',
      'أدعية المغفرة',
      'أدعية الهداية',
      'أدعية الحماية',
      'أدعية يومية',
      'أدعية قرآنية',
      'أدعية متنوعة'
    ];
  }

  static DuaCategory getCategoryFromString(String category) {
    switch (category) {
      case 'أدعية الأنبياء': return DuaCategory.prophets;
      case 'أدعية الرزق': return DuaCategory.rizq;
      case 'أدعية المطر': return DuaCategory.rain;
      case 'أدعية الصباح': return DuaCategory.morning;
      case 'أدعية المساء': return DuaCategory.evening;
      case 'أدعية الكرب': return DuaCategory.distress;
      case 'أدعية السفر': return DuaCategory.travel;
      case 'أدعية المرض': return DuaCategory.sickness;
      case 'أدعية الوالدين': return DuaCategory.parents;
      case 'أدعية المغفرة': return DuaCategory.forgiveness;
      case 'أدعية الهداية': return DuaCategory.guidance;
      case 'أدعية الحماية': return DuaCategory.protection;
      case 'أدعية يومية': return DuaCategory.daily;
      case 'أدعية قرآنية': return DuaCategory.quran;
      case 'أدعية متنوعة': return DuaCategory.miscellaneous;
      default: return DuaCategory.miscellaneous;
    }
  }

  static String getCategoryIcon(DuaCategory category) {
    switch (category) {
      case DuaCategory.prophets: return '🕌';
      case DuaCategory.rizq: return '💰';
      case DuaCategory.rain: return '🌧️';
      case DuaCategory.morning: return '🌅';
      case DuaCategory.evening: return '';
      case DuaCategory.distress: return '💔';
      case DuaCategory.travel: return '✈️';
      case DuaCategory.sickness: return '❤️';
      case DuaCategory.parents: return '👨‍👩👧';
      case DuaCategory.forgiveness: return '🤲';
      case DuaCategory.guidance: return '🧭';
      case DuaCategory.protection: return '🛡️';
      case DuaCategory.daily: return '';
      case DuaCategory.quran: return '📖';
      case DuaCategory.miscellaneous: return '✨';
      default: return '📿';
    }
  }
}
