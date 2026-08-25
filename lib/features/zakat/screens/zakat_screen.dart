import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/zakat_data.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الفرق بين الزكاة والصدقة
            _buildSectionHeader('الفرق بين الزكاة والصدقة', Icons.compare_arrows),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF132033),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFB8922A), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  ZakatData.differenceContent,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    color: Colors.white,
                    height: 2,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // قسم أنواع الزكاة
            _buildSectionHeader('أنواع الزكاة', Icons.account_balance_wallet),
            const SizedBox(height: 12),
            ...ZakatData.zakatTypes.map((zakat) => _buildInfoCard(zakat, isZakat: true)),

            const SizedBox(height: 30),

            // قسم أنواع الصدقات
            _buildSectionHeader('أنواع الصدقات', Icons.favorite),
            const SizedBox(height: 12),
            ...ZakatData.sadaqahTypes.map((sadaqah) => _buildInfoCard(sadaqah, isZakat: false)),
            
            const SizedBox(height: 30),
            
            // ملاحظة ختامية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, color: Color(0xFFB8922A), size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'قال رسول الله ﷺ:',
                    style: GoogleFonts.amiri(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"ما نقصت صدقة من مال"',
                    style: GoogleFonts.amiri(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '(رواه مسلم)',
                    style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFB8922A).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFB8922A), size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(ZakatInfo info, {required bool isZakat}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF132033),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isZakat ? const Color(0xFF4CAF50).withOpacity(0.5) : const Color(0xFF2196F3).withOpacity(0.5),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: const Color(0xFFB8922A),
        collapsedIconColor: Colors.white54,
        title: Row(
          children: [
            Text(info.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                info.title,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        children: [
          Text(
            info.content,
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.white70,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
