import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dua_data.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  List<Dua> _getFilteredDuas() {
    List<Dua> duas;
    if (_selectedCategory == 'الكل') {
      duas = DuaData.duas;
    } else {
      final category = DuaData.getCategoryFromString(_selectedCategory);
      duas = DuaData.getDuasByCategory(category);
    }

    if (_searchQuery.isNotEmpty) {
      duas = duas.where((dua) {
        return dua.title.contains(_searchQuery) || 
               dua.text.contains(_searchQuery) ||
               dua.virtue.contains(_searchQuery);
      }).toList();
    }

    return duas;
  }

  @override
  Widget build(BuildContext context) {
    final categories = DuaData.getCategories();
    final duas = _getFilteredDuas();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'الأدعية المختارة',
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
                hintText: 'ابحث عن دعاء...',
                hintStyle: GoogleFonts.amiri(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB8922A)),
                filled: true,
                fillColor: const Color(0xFF132033),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // شريط التصنيفات
          Container(
            height: 50,
            color: const Color(0xFF132033),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFB8922A) : const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (category != 'الكل')
                            Text(
                              DuaData.getCategoryIcon(DuaData.getCategoryFromString(category)),
                              style: const TextStyle(fontSize: 16),
                            ),
                          if (category != 'الكل') const SizedBox(width: 4),
                          Text(
                            category,
                            style: GoogleFonts.amiri(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // قائمة الأدعية
          Expanded(
            child: duas.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد أدعية',
                      style: GoogleFonts.amiri(fontSize: 18, color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: duas.length,
                    itemBuilder: (context, index) {
                      final dua = duas[index];
                      return _buildDuaCard(dua);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(Dua dua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            color: const Color(0xFFB8922A).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والمصدر
            Row(
              children: [
                Expanded(
                  child: Text(
                    dua.title,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB8922A),
                    ),
                  ),
                ),
                if (dua.repeatCount > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8922A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '×${dua.repeatCount}',
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: const Color(0xFFB8922A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // نص الدعاء
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                dua.text,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  color: Colors.white,
                  height: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // الفضل والمصدر
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFB8922A), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dua.virtue,
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.book, color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text(
                  dua.source,
                  style: GoogleFonts.amiri(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // أزرار النسخ والمشاركة
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyDua(dua),
                    icon: const Icon(Icons.copy, size: 18),
                    label: Text(
                      'نسخ',
                      style: GoogleFonts.amiri(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareDua(dua),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      'مشاركة',
                      style: GoogleFonts.amiri(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8922A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyDua(Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n${dua.virtue}\n\n${dua.source}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الدعاء', style: GoogleFonts.amiri()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareDua(Dua dua) {
    final text = '${dua.title}\n\n${dua.text}\n\n${dua.virtue}\n\n${dua.source}';
    // يمكن إضافة مشاركة هنا
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ الدعاء للمشاركة', style: GoogleFonts.amiri()),
        backgroundColor: const Color(0xFFB8922A),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
