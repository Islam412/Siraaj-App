import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/azkar_data.dart';
import '../widgets/azkar_list_widget.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  int _selectedIndex = 0;

  void _handleAllCompleted(int totalCount) {
    // يمكن إضافة منطق إضافي هنا عند إكمال جميع الأذكار
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إكمال جميع الأذكار! بارك الله فيك',
          style: GoogleFonts.amiri(fontSize: 16),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: Text('أذكار اليوم', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // القائمة الجانبية للأقسام
          Container(
            width: 250,
            color: const Color(0xFF132033),
            child: ListView.builder(
              itemCount: AzkarData.categories.length,
              itemBuilder: (context, index) {
                final category = AzkarData.categories[index];
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
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          
          // محتوى الأذكار
          Expanded(
            child: AzkarListWidget(
              category: AzkarData.categories[_selectedIndex],
              onAllCompleted: _handleAllCompleted,
            ),
          ),
        ],
      ),
    );
  }
}
