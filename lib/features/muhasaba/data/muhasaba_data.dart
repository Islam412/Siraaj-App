class MuhasabaQuestion {
  final String id;
  final String category;
  final String question;
  final String icon;
  final String color;

  const MuhasabaQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.icon,
    required this.color,
  });
}

class MuhasabaData {
  static const List<MuhasabaQuestion> questions = [
    // === الإيمان والعقيدة ===
    MuhasabaQuestion(
      id: '1',
      category: 'الإيمان',
      question: 'هل حافظت على الصلوات الخمس في وقتها؟',
      icon: '🕌',
      color: '0xFF4CAF50',
    ),
    MuhasabaQuestion(
      id: '2',
      category: 'الإيمان',
      question: 'هل قرأت وردك اليومي من القرآن؟',
      icon: '',
      color: '0xFF4CAF50',
    ),
    MuhasabaQuestion(
      id: '3',
      category: 'الإيمان',
      question: 'هل حافظت على أذكار الصباح والمساء؟',
      icon: '📿',
      color: '0xFF4CAF50',
    ),
    MuhasabaQuestion(
      id: '4',
      category: 'الإيمان',
      question: 'هل دعوت الله وطلبت منه حاجاتك؟',
      icon: '🤲',
      color: '0xFF4CAF50',
    ),

    // === الأخلاق ===
    MuhasabaQuestion(
      id: '5',
      category: 'الأخلاق',
      question: 'هل غضبت اليوم وسببت أذى للآخرين؟',
      icon: '😠',
      color: '0xFF2196F3',
    ),
    MuhasabaQuestion(
      id: '6',
      category: 'الأخلاق',
      question: 'هل اغتبت أو نممت على أحد؟',
      icon: '🗣️',
      color: '0xFF2196F3',
    ),
    MuhasabaQuestion(
      id: '7',
      category: 'الأخلاق',
      question: 'هل كنت صادقاً في معاملاتك؟',
      icon: '🤝',
      color: '0xFF2196F3',
    ),
    MuhasabaQuestion(
      id: '8',
      category: 'الأخلاق',
      question: 'هل تصدقت اليوم ولو بالقليل؟',
      icon: '💝',
      color: '0xFF2196F3',
    ),

    // === العبادات ===
    MuhasabaQuestion(
      id: '9',
      category: 'العبادات',
      question: 'هل صليت ركعتي الضحى؟',
      icon: '🌅',
      color: '0xFF9C27B0',
    ),
    MuhasabaQuestion(
      id: '10',
      category: 'العبادات',
      question: 'هل صليت الوتر قبل النوم؟',
      icon: '🌙',
      color: '0xFF9C27B0',
    ),
    MuhasabaQuestion(
      id: '11',
      category: 'العبادات',
      question: 'هل صمت يوماً تطوعاً؟',
      icon: '🍽️',
      color: '0xFF9C27B0',
    ),
    MuhasabaQuestion(
      id: '12',
      category: 'العبادات',
      question: 'هل قمت الليل ولو بركعتين؟',
      icon: '🌃',
      color: '0xFF9C27B0',
    ),

    // === العلاقات ===
    MuhasabaQuestion(
      id: '13',
      category: 'العلاقات',
      question: 'هل بررت والديك اليوم؟',
      icon: '👨‍👩👧',
      color: '0xFFFF9800',
    ),
    MuhasabaQuestion(
      id: '14',
      category: 'العلاقات',
      question: 'هل تواصلت مع أرحامك؟',
      icon: '👥',
      color: '0xFFFF9800',
    ),
    MuhasabaQuestion(
      id: '15',
      category: 'العلاقات',
      question: 'هل ساعدت محتاجاً اليوم؟',
      icon: '',
      color: '0xFFFF9800',
    ),
    MuhasabaQuestion(
      id: '16',
      category: 'العلاقات',
      question: 'هل سامحت من أخطأ في حقك؟',
      icon: '',
      color: '0xFFFF9800',
    ),

    // === النفس ===
    MuhasabaQuestion(
      id: '17',
      category: 'النفس',
      question: 'هل ضيعت وقتك في اللهو واللعب؟',
      icon: '⏰',
      color: '0xFFE91E63',
    ),
    MuhasabaQuestion(
      id: '18',
      category: 'النفس',
      question: 'هل نظرت إلى ما حرم الله؟',
      icon: '️',
      color: '0xFFE91E63',
    ),
    MuhasabaQuestion(
      id: '19',
      category: 'النفس',
      question: 'هل أكلت من حلال؟',
      icon: '🍎',
      color: '0xFFE91E63',
    ),
    MuhasabaQuestion(
      id: '20',
      category: 'النفس',
      question: 'هل استغفرت الله اليوم؟',
      icon: '',
      color: '0xFFE91E63',
    ),
  ];

  static List<MuhasabaQuestion> getQuestionsByCategory(String category) {
    if (category == 'الكل') return questions;
    return questions.where((q) => q.category == category).toList();
  }

  static List<String> getCategories() {
    return ['الكل', 'الإيمان', 'الأخلاق', 'العبادات', 'العلاقات', 'النفس'];
  }
}
