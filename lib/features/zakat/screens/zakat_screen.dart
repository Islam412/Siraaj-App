import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/zakat_data.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  // 0 للزكاة، 1 للصدقات
  int _selectedCategory = 0;

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
            const Icon(Icons.volunteer_activism, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'الزكاة والصدقات',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // بطاقة الفرق بين الزكاة والصدقة (ثابتة في الأعلى)
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDifferenceSection(),
          ),

          // شريط التبديل (Toggle Switch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF132033),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // زر الزكاة
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedCategory == 0 ? const Color(0xFF4CAF50) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'الزكاة',
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategory == 0 ? Colors.white : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // زر الصدقات
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedCategory == 1 ? const Color(0xFFE91E63) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'الصدقات',
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategory == 1 ? Colors.white : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // المحتوى المتغير حسب الاختيار
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedCategory == 0 
                  ? _buildZakatContent() 
                  : _buildSadaqahContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: Color(0xFFB8922A), size: 24),
              const SizedBox(width: 8),
              Text(
                'الفرق باختصار',
                style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMiniPoint('الزكاة: فرض', Colors.green),
                    _buildMiniPoint('نصاب ومقدار محدد', Colors.green),
                    _buildMiniPoint('8 مصارف شرعية', Colors.green),
                  ],
                ),
              ),
              const VerticalDivider(color: Colors.white24, width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMiniPoint('الصدقة: تطوع', Colors.orange),
                    _buildMiniPoint('أي مقدار وفي أي وقت', Colors.orange),
                    _buildMiniPoint('تجوز لأي شخص', Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: GoogleFonts.amiri(fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('أنواع الزكاة', Icons.account_balance_wallet, const Color(0xFF4CAF50)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: ZakatData.zakatTypes.map((zakat) {
              return _buildZakatCard(zakat, const Color(0xFF4CAF50));
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildHadithCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSadaqahContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('أنواع الصدقات', Icons.favorite, const Color(0xFFE91E63)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: ZakatData.sadaqahTypes.map((sadaqah) {
              return _buildZakatCard(sadaqah, const Color(0xFFE91E63));
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildHadithCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildZakatCard(ZakatInfo info, Color accentColor) {
    return GestureDetector(
      onTap: () => _showDetails(info, accentColor),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF132033), Color(0xFF1E3A5F)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getCategoryIcon(info.subcategory ?? ''), color: accentColor, size: 22),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  info.title,
                  style: GoogleFonts.amiri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.subcategory ?? '',
                  style: GoogleFonts.amiri(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'للمال': return Icons.attach_money;
      case 'للشخص': return Icons.person;
      case 'للأرض': return Icons.landscape;
      case 'للأنعام': return Icons.pets;
      case 'للمعادن': return Icons.diamond;
      case 'للديون': return Icons.credit_card;
      case 'للمتوفى': return Icons.bookmark;
      case 'مالية': return Icons.account_balance_wallet;
      case 'عن الغير': return Icons.group;
      case 'عن المتوفى': return Icons.bookmark;
      case 'جارية': return Icons.repeat;
      case 'بدنية': return Icons.fitness_center;
      case 'كفارات': return Icons.gavel;
      case 'متنوعة': return Icons.category;
      default: return Icons.info;
    }
  }

  void _showDetails(ZakatInfo info, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF132033),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Icon(_getCategoryIcon(info.subcategory ?? ''), color: accentColor, size: 45),
            ),
            const SizedBox(height: 20),
            Text(
              info.title,
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (info.subcategory != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(info.subcategory!, style: GoogleFonts.amiri(fontSize: 13, color: accentColor, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                info.content,
                style: GoogleFonts.amiri(fontSize: 17, color: Colors.white, height: 1.9),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFB8922A), Color(0xFF8B6914)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            'ما نقصت صدقة من مال',
            style: GoogleFonts.amiri(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '(رواه مسلم)',
            style: GoogleFonts.amiri(fontSize: 13, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
