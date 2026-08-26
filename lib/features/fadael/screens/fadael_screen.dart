import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FadaelScreen extends StatefulWidget {
  const FadaelScreen({super.key});

  @override
  State<FadaelScreen> createState() => _FadaelScreenState();
}

class _FadaelScreenState extends State<FadaelScreen> {
  int _selectedSurah = 1;

  final List<Map<String, dynamic>> _surahFadael = [
    {
      'number': 1,
      'name': 'الفاتحة',
      'fadael': [
        'عن أبي هريرة رضي الله عنه عن النبي صلى الله عليه وسلم قال: "الحمد لله رب العالمين هي السبع المثاني والقرآن العظيم الذي أوتيته"',
        'قال الله تعالى في الحديث القدسي: "قسمت الصلاة بيني وبين عبدي نصفين، فالنصف لي والنصف لعبدي"',
      ],
    },
    {
      'number': 2,
      'name': 'البقرة',
      'fadael': [
        'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "لا تجعلوا بيوتكم مقابر، إن الشيطان ينفر من البيت الذي تقرأ فيه سورة البقرة"',
        'عن أبي مسعود رضي الله عنه قال: قال النبي صلى الله عليه وسلم: "من قرأ بالآيتين من آخر سورة البقرة في ليلة كفتاه"',
        'هي أفضل سورة في القرآن كما جاء في الحديث: "أفضل سورة في القرآن سورة البقرة"',
      ],
    },
    {
      'number': 18,
      'name': 'الكهف',
      'fadael': [
        'عن أبي سعيد الخدري رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "من قرأ سورة الكهف في يوم الجمعة أضاء له من النور ما بين الجمعتين"',
        'عن البراء بن عازب رضي الله عنه قال: كان رجل يقرأ سورة الكهف وإلى جانبه حصان مربوط بشطنين فتغشته سحابة فجعلت تدنو وتنفر منه',
        'من حفظ عشر آيات من أول سورة الكهف عصم من الدجال',
      ],
    },
    {
      'number': 36,
      'name': 'يس',
      'fadael': [
        'عن معقل بن يسار رضي الله عنه قال: قال النبي صلى الله عليه وسلم: "يس قلب القرآن، لا يقرأها رجل يريد الله والدار الآخرة إلا غفر الله له"',
        'عن أنس رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "إن لكل شيء قلباً، وقلب القرآن يس"',
      ],
    },
    {
      'number': 55,
      'name': 'الرحمن',
      'fadael': [
        'عن عبد الله بن مسعود رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "كل شيء له عروس، وعروس القرآن الرحمن"',
        'قال تعالى فيها: ﴿فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ﴾ تتكرر 31 مرة',
      ],
    },
    {
      'number': 56,
      'name': 'الواقعة',
      'fadael': [
        'عن عبد الله بن مسعود رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "من قرأ سورة الواقعة في كل ليلة لم تصبه فاقة أبداً"',
        'أمر النبي صلى الله عليه وسلم أن تعلمها النساء',
      ],
    },
    {
      'number': 67,
      'name': 'الملك',
      'fadael': [
        'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "إن سورة من القرآن ثلاثون آية شفعت لرجل حتى غفر له، وهي سورة الملك"',
        'هي المانعة من عذاب القبر',
        'كان النبي صلى الله عليه وسلم لا ينام حتى يقرأها',
      ],
    },
    {
      'number': 112,
      'name': 'الإخلاص',
      'fadael': [
        'عن أبي سعيد رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "والذي نفسي بيده، إنها لتعدل ثلث القرآن"',
        'عن عائشة رضي الله عنها قال: بعث النبي صلى الله عليه وسلم رجلاً على سرية فكان يقرأ في صلاته بـ ﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾',
        'عن أبي الدرداء رضي الله عنه قال: قال النبي صلى الله عليه وسلم: "أيعجز أحدكم أن يقرأ في ليلة ثلث القرآن؟"',
      ],
    },
    {
      'number': 113,
      'name': 'الفلق',
      'fadael': [
        'عن عقبة بن عامر رضي الله عنه قال: قال لي رسول الله صلى الله عليه وسلم: "ألا أخبرك بخير سورتين أنزلتا في التوراة والإنجيل والقرآن؟"',
        'قال: "قل أعوذ برب الفلق وقل أعوذ برب الناس"',
        'كان النبي صلى الله عليه وسلم يتعوذ بهما في دبر كل صلاة',
      ],
    },
    {
      'number': 114,
      'name': 'الناس',
      'fadael': [
        'عن عائشة رضي الله عنها قالت: كان النبي صلى الله عليه وسلم إذا اشتكى قرأ على نفسه بالمعوذات ونفث',
        'عن أبي سعيد الخدري رضي الله عنه قال: كان النبي صلى الله عليه وسلم يتعوذ من الجان وعين الإنسان حتى نزلت المعوذات',
        'هي مع سورة الفلق أفضل ما يتعوذ به',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text('فضائل السور', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSurahSelector(),
          Expanded(child: _buildFadaelContent()),
        ],
      ),
    );
  }

  Widget _buildSurahSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF132033),
      child: DropdownButton<int>(
        value: _selectedSurah,
        isExpanded: true,
        dropdownColor: const Color(0xFF1E3A5F),
        style: GoogleFonts.amiri(fontSize: 18, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
        underline: const SizedBox(),
        items: _surahFadael.map<DropdownMenuItem<int>>((s) {
          return DropdownMenuItem<int>(
            value: s['number'] as int,
            child: Text('سورة ${s['name']}', style: GoogleFonts.amiri(fontSize: 16)),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _selectedSurah = v);
        },
      ),
    );
  }

  Widget _buildFadaelContent() {
    final surahData = _surahFadael.firstWhere((s) => s['number'] == _selectedSurah);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB8922A), Color(0xFF8B6914)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB8922A).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.star, size: 50, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'سورة ${surahData['name']}',
                  style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'فضائل وأحاديث',
                  style: GoogleFonts.amiri(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'الأحاديث الصحيحة:',
            style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)),
          ),
          const SizedBox(height: 16),
          ...(surahData['fadael'] as List<String>).map((hadith) => _buildHadithCard(hadith)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHadithCard(String hadith) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8922A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.format_quote, color: Color(0xFFB8922A), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'حديث شريف',
                style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hadith,
            style: GoogleFonts.amiri(fontSize: 18, height: 2.0, color: Colors.white),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
