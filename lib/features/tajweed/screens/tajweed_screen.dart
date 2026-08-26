import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            const Icon(Icons.auto_stories, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text('أحكام التجويد', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB8922A),
          labelColor: const Color(0xFFB8922A),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'النون الساكنة'),
            Tab(text: 'المدود'),
            Tab(text: 'الميم الساكنة'),
            Tab(text: 'اللامات'),
            Tab(text: 'أحكام عامة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNoonSakinah(),
          _buildMadd(),
          _buildMeemSakinah(),
          _buildLaam(),
          _buildGeneralRules(),
        ],
      ),
    );
  }

  Widget _buildNoonSakinah() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('النون الساكنة والتنوين'),
          const SizedBox(height: 16),
          _buildRuleCard(
            'الظهار',
            'إخراج النون من مخرجها من غير غنة',
            'حروفه: ء هـ ع ح غ خ',
            'مثال: ﴿مَنْ آمَنَ﴾، ﴿عَلِيمٌ حَكِيمٌ﴾',
            Colors.green,
          ),
          _buildRuleCard(
            'الإدغام',
            'إدخال النون في الحرف الذي بعدها',
            'حروفه: ي ر م ل و ن (يرملون)',
            'مثال: ﴿مَن يَقُولُ﴾، ﴿مِن رَّبِّهِمْ﴾',
            Colors.blue,
          ),
          _buildRuleCard(
            'الإقلاب',
            'قلب النون ميماً عند الباء',
            'حرفه: الباء',
            'مثال: ﴿مِن بَعْدِ﴾، ﴿سَمِيعٌ بَصِيرٌ﴾',
            Colors.orange,
          ),
          _buildRuleCard(
            'الإخفاء',
            'النطق بالنون بين الظهار والإدغام مع بقاء الغنة',
            'حروفه: 15 حرفاً (ص ذ ث ج ش ق س ك ض ظ ز ف ت د ط)',
            'مثال: ﴿مِن صَلَاتِهِمْ﴾، ﴿مِن ذَهَبٍ﴾',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMadd() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('المدود'),
          const SizedBox(height: 16),
          _buildRuleCard(
            'المد الطبيعي',
            'المد بمقدار حركتين (ألف - واو - ياء)',
            'مثال: ﴿قَالَ﴾، ﴿قُولُوا﴾، ﴿قِيلَ﴾',
            'مقداره: حركتان',
            Colors.green,
          ),
          _buildRuleCard(
            'المد المتصل',
            'المد الذي يأتي بعده همز في كلمة واحدة',
            'مثال: ﴿جَاءَ﴾، ﴿السَّمَاءِ﴾، ﴿جِيءَ﴾',
            'مقداره: 4-5 حركات',
            Colors.blue,
          ),
          _buildRuleCard(
            'المد المنفصل',
            'المد الذي يأتي بعده همز في كلمة أخرى',
            'مثال: ﴿يَا أَيُّهَا﴾، ﴿هَؤُلَاءِ﴾',
            'مقداره: 4-5 حركات',
            Colors.orange,
          ),
          _buildRuleCard(
            'المد اللازم',
            'المد الذي يأتي بعده ساكن أصلي',
            'مثال: ﴿الضَّالِّينَ﴾، ﴿الحَاقَّةُ﴾',
            'مقداره: 6 حركات',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMeemSakinah() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('الميم الساكنة'),
          const SizedBox(height: 16),
          _buildRuleCard(
            'الظهار الشفوي',
            'إظهار الميم عند الباء',
            'حرفه: الباء',
            'مثال: ﴿تَرْمِيهِم بِحِجَارَةٍ﴾',
            Colors.green,
          ),
          _buildRuleCard(
            'الإدغام الشفوي',
            'إدغام الميم في الميم',
            'حرفه: الميم',
            'مثال: ﴿لَكُم مَّا﴾، ﴿آمَنتُم بِهِ﴾',
            Colors.blue,
          ),
          _buildRuleCard(
            'الإخفاء الشفوي',
            'إخفاء الميم عند الواو والفاء',
            'حروفه: الواو، الفاء',
            'مثال: ﴿تَرْمُونَهُ﴾، ﴿هُمْ فِيهَا﴾',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildLaam() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('أحكام اللامات'),
          const SizedBox(height: 16),
          _buildRuleCard(
            'لام التعريف',
            'تفخم مع الحروف القمرية، ترقق مع الشمسية',
            'القمرية: 14 حرفاً (ابغ حجك وخف عقيمه)',
            'الشمسية: 14 حرفاً (طب ثم صل رحماً تفز ضف ذا نعم)',
            Colors.green,
          ),
          _buildRuleCard(
            'لام الفعل',
            'تفخم إذا كانت مفتوحة أو مضمومة، ترقق إذا كانت مكسورة',
            'مثال التفخيم: ﴿قُلْ﴾، ﴿يَقُولُ﴾',
            'مثال الترقيق: ﴿قُلِ اللَّهُ﴾',
            Colors.blue,
          ),
          _buildRuleCard(
            'لام الحرف',
            'في ﴿لَكِن﴾ و﴿لَٰكِنَّ﴾ ترقق',
            'مثال: ﴿لَكِنِ اللَّهُ﴾',
            '',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('أحكام عامة'),
          const SizedBox(height: 16),
          _buildRuleCard(
            'الغنة',
            'صوت يخرج من الأنف',
            'مقدارها: حركتان',
            'تكون في النون والميم المشددتين',
            Colors.green,
          ),
          _buildRuleCard(
            'القلقلة',
            'اضطراب الصوت عند النطق بالحرف الساكن',
            'حروفها: قطب جد',
            'مثال: ﴿يَطْمَعُ﴾، ﴿قَدْ﴾',
            Colors.blue,
          ),
          _buildRuleCard(
            'الإدغام',
            'إدخال حرف في حرف',
            'أنواعه: إدغام بغنة (ينمو)، إدغام بغير غنة (ل ر)',
            'مثال: ﴿مَن يَقُولُ﴾، ﴿مِن رَّبِّهِمْ﴾',
            Colors.orange,
          ),
          _buildRuleCard(
            'الوقف والابتداء',
            'كيفية الوقف على الكلمات والابتداء',
            'علامات الوقف: م، لا، ج، صلى، قلى',
            'يجود الوقف على رؤوس الآي',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB8922A), Color(0xFF8B6914)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRuleCard(String title, String definition, String letters, String example, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('التعريف:', definition, color),
          if (letters.isNotEmpty) _buildInfoRow('الحروف:', letters, color),
          if (example.isNotEmpty) _buildInfoRow('المثال:', example, color),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          children: [
            TextSpan(
              text: text,
              style: GoogleFonts.amiri(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
