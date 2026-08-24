import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/hadith_data.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  int _selectedIndex = 0;

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
            const Icon(Icons.menu_book, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text('الأحاديث النبوية', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // القائمة الجانبية المحسنة
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF132033),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565A8), Color(0xFF1E3A5F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.library_books, size: 50, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(height: 10),
                      Text(
                        'مكتبة الأحاديث',
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // القائمة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: HadithData.categories.length,
                    itemBuilder: (context, index) {
                      final category = HadithData.categories[index];
                      final isSelected = index == _selectedIndex;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Color(int.parse(category.color)).withOpacity(0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Color(int.parse(category.color)), width: 2)
                              : null,
                        ),
                        child: ListTile(
                          selected: isSelected,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Color(int.parse(category.color)).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Color(int.parse(category.color))),
                            ),
                            child: Center(
                              child: Text(
                                category.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: GoogleFonts.amiri(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          subtitle: Text(
                            '${category.hadiths.length} حديث',
                            style: GoogleFonts.amiri(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : Colors.white54,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.arrow_forward, color: Color(int.parse(category.color)))
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'جميع الأحاديث صحيحة',
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // محتوى الأحاديث
          Expanded(
            child: _buildHadithList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithList() {
    final category = HadithData.categories[_selectedIndex];
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: category.hadiths.length,
      itemBuilder: (context, index) {
        final hadith = category.hadiths[index];
        final sourceColor = _getSourceColor(hadith['source'] as String);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(int.parse(category.color)).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رقم الحديث والمصدر
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(int.parse(category.color)),
                            Color(int.parse(category.color)).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Color(int.parse(category.color)).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bookmark, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'حديث ${hadith['number']}',
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sourceColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sourceColor),
                      ),
                      child: Text(
                        hadith['source'] as String,
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          color: sourceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // نص الحديث
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    hadith['text'] as String,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      color: Colors.white,
                      height: 2.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 16),
                
                // الراوي
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(category.color)).withOpacity(0.3),
                        Color(int.parse(category.color)).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(int.parse(category.color)).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(int.parse(category.color)).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.person_outline, color: Color(int.parse(category.color)), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الراوي',
                              style: GoogleFonts.amiri(
                                fontSize: 12,
                                color: Color(int.parse(category.color)),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hadith['narrator'] as String,
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSourceColor(String source) {
    if (source.contains('متفق')) return Colors.green;
    if (source.contains('البخاري')) return const Color(0xFF1565A8);
    if (source.contains('مسلم')) return const Color(0xFF2E7D32);
    return const Color(0xFFB8922A);
  }
}
