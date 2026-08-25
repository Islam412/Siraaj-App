import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/asma_allah_data.dart';

class AsmaAllahScreen extends StatefulWidget {
  const AsmaAllahScreen({super.key});

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredNames = AsmaAllahData.searchNames(_searchQuery);

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
            Text(
              'أسماء الله الحسنى',
              style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.amiri(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم أو معنى...',
                hintStyle: GoogleFonts.amiri(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB8922A)),
                filled: true,
                fillColor: const Color(0xFF132033),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),

          // شبكة الأسماء
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: filteredNames.length,
              itemBuilder: (context, index) {
                final asma = filteredNames[index];
                return _buildAsmaCard(asma);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsmaCard(AsmaAllah asma) {
    return GestureDetector(
      onTap: () => _showDetails(asma),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF132033), Color(0xFF1E3A5F)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الرقم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFB8922A).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _toArabicNumbers(asma.number),
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  color: const Color(0xFFB8922A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // الاسم
            Text(
              asma.name,
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.remove, color: Color(0xFFB8922A), size: 20),
          ],
        ),
      ),
    );
  }

  void _showDetails(AsmaAllah asma) {
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
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              asma.name,
              style: GoogleFonts.amiri(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB8922A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الرقم ${_toArabicNumbers(asma.number)} من أسماء الله الحسنى',
              style: GoogleFonts.amiri(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
              ),
              child: Text(
                asma.meaning,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  color: Colors.white,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _toArabicNumbers(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String res = number.toString();
    for (int i = 0; i < english.length; i++) {
      res = res.replaceAll(english[i], arabic[i]);
    }
    return res;
  }
}
