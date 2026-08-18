import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AsmaAllahScreen extends StatelessWidget {
  const AsmaAllahScreen({super.key});

  final List<Map<String, String>> _names = const [
    {
      'ar': 'الرَّحْمَنُ',
      'en': 'Ar-Rahman',
      'meaning': 'ذو الرحمة الواسعة التي تشمل جميع الخلق في الدنيا.',
      'virtue': 'من قالها موقناً بها دخل الجنة.'
    },
    {
      'ar': 'الرَّحِيمُ',
      'en': 'Ar-Raheem',
      'meaning': 'الموصل للرحمة إلى من يشاء من عباده المؤمنين.',
      'virtue': 'اسم خاص برحمة الله للمؤمنين يوم القيامة.'
    },
    {
      'ar': 'الْمَلِكُ',
      'en': 'Al-Malik',
      'meaning': 'المالك لكل شيء، والمتصرف في الكون بأمره.',
      'virtue': 'أصدق كلمة قالها الشاعر: لا ملك إلا الله.'
    },
    {
      'ar': 'الْقُدُّوسُ',
      'en': 'Al-Quddus',
      'meaning': 'الطاهر المنزه عن كل نقص وعيب.',
      'virtue': 'تسبيح الملائكة المستمر لربهم بهذا الاسم.'
    },
    {
      'ar': 'السَّلَامُ',
      'en': 'As-Salam',
      'meaning': 'السالم من كل عيب، والمسلم لعباده المؤمنين في الجنة.',
      'virtue': 'من أمن الناس من شره.'
    },
    // ... يمكن إضافة باقي الأسماء هنا
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أسماء الله الحسنى')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _names.length,
        itemBuilder: (context, index) {
          final name = _names[index];
          return Card(
            child: InkWell(
              onTap: () => _showNameDetails(context, name),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name['ar']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name['en']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'اضغط للتفاصيل',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100)).scale();
        },
      ),
    );
  }

  void _showNameDetails(BuildContext context, Map<String, String> name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
              name['ar']!,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'Amiri', color: Color(0xFF1565A8)),
            ),
            Text(
              name['en']!,
              style: const TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildDetailBox('المعنى', name['meaning']!, Icons.info_outline),
            const SizedBox(height: 16),
            _buildDetailBox('الفضل والأثر', name['virtue']!, Icons.star_outline, isGold: true),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String title, String content, IconData icon, {bool isGold = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGold ? const Color(0xFFB8922A).withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isGold ? const Color(0xFFB8922A).withOpacity(0.3) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isGold ? const Color(0xFFB8922A) : const Color(0xFF1565A8), size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isGold ? const Color(0xFF8B6914) : const Color(0xFF1565A8))),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}