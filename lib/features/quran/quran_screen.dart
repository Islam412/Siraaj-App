import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A5F),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E3A5F), Color(0xFF0B1623)]),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.menu_book_rounded, size: 60, color: Color(0xFFB8922A)),
                    const SizedBox(height: 12),
                    Text('القرآن الكريم', style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا', style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A), fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.85),
              delegate: SliverChildListDelegate([
                _buildQuranCard(context, 'المصحف الشريف', 'قراءة مع المشايخ', Icons.auto_stories, const Color(0xFF2196F3), '/quran-reader', true),
                _buildQuranCard(context, 'اختبار الحفظ', 'تسميع ذكي', Icons.psychology, const Color(0xFF9C27B0), '/memorization', true),
                _buildQuranCard(context, 'الورد اليومي', 'متابعة الختم', Icons.book_online, const Color(0xFF4CAF50), '/quran-tracker', false),
                _buildQuranCard(context, 'التفسير', 'كتب التفسير', Icons.translate, const Color(0xFFFF9800), '/tafsir', false),
                _buildQuranCard(context, 'فضائل السور', 'أحاديث وفضل', Icons.star_outline, const Color(0xFFE91E63), '/fadael', false),
                _buildQuranCard(context, 'أحكام التجويد', 'الإعراب والتجويد', Icons.format_quote, const Color(0xFF00BCD4), '/tajweed', false),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route, bool isPrimary) {
    return GestureDetector(
      onTap: () {
        try { context.push(route); } 
        catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title - قيد التطوير', style: GoogleFonts.amiri(fontSize: 16)), backgroundColor: color, behavior: SnackBarBehavior.floating)); }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isPrimary ? [color, color.withOpacity(0.7)] : [color.withOpacity(0.15), color.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isPrimary ? Colors.transparent : color.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(isPrimary ? 0.4 : 0.1), blurRadius: isPrimary ? 20 : 10, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(isPrimary ? 0.2 : 0.1), shape: BoxShape.circle), child: Icon(icon, size: isPrimary ? 45 : 40, color: isPrimary ? Colors.white : color)),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: isPrimary ? 22 : 20, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : color)),
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.amiri(fontSize: 13, color: isPrimary ? Colors.white.withOpacity(0.9) : color.withOpacity(0.8), height: 1.4))),
            if (isPrimary) ...[const SizedBox(height: 16), Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('ابدأ الآن', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: color)))],
          ],
        ),
      ),
    );
  }
}
