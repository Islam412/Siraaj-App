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
        title: Text('الأحاديث النبوية', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // القائمة الجانبية للأقسام
          Container(
            width: 250,
            color: const Color(0xFF132033),
            child: ListView.builder(
              itemCount: HadithData.categories.length,
              itemBuilder: (context, index) {
                final category = HadithData.categories[index];
                final isSelected = index == _selectedIndex;
                
                return ListTile(
                  selected: isSelected,
                  selectedColor: const Color(0xFFB8922A),
                  selectedTileColor: const Color(0xFF1565A8),
                  leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    category.name,
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${category.hadiths.length} حديث',
                    style: GoogleFonts.amiri(fontSize: 12, color: Colors.white54),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
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
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: const Color(0xFFB8922A).withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رقم الحديث والمصدر
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8922A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'حديث ${hadith['number']}',
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        hadith['source'] as String,
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // نص الحديث
                Text(
                  hadith['text'] as String,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    color: Colors.white,
                    height: 2.2,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                
                // الراوي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8922A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Color(0xFFB8922A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hadith['narrator'] as String,
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
}
