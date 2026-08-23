import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarListWidget extends StatefulWidget {
  final dynamic category;

  const AzkarListWidget({super.key, required this.category});

  @override
  State<AzkarListWidget> createState() => _AzkarListWidgetState();
}

class _AzkarListWidgetState extends State<AzkarListWidget> {
  Map<int, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'azkar_${widget.category.name}';
    final savedCounts = prefs.getString(key);
    if (savedCounts != null) {
      // تحميل العدادات المحفوظة
    }
  }

  Future<void> _saveCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'azkar_${widget.category.name}';
    // حفظ العدادات
  }

  void _incrementCount(int index) {
    setState(() {
      _counts[index] = (_counts[index] ?? 0) + 1;
    });
    _saveCounts();
  }

  @override
  Widget build(BuildContext context) {
    final azkar = widget.category.azkar;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final zikr = azkar[index];
        final currentCount = _counts[index] ?? 0;
        final targetCount = zikr['count'] as int;
        final isCompleted = currentCount >= targetCount;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: isCompleted 
              ? Colors.green.withOpacity(0.2) 
              : Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isCompleted ? Colors.green : const Color(0xFFB8922A).withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        zikr['text'] as String,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.green : Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : const Color(0xFFB8922A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$currentCount / $targetCount',
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  zikr['arabic'] as String,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    color: Colors.white,
                    height: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (zikr['virtue'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8922A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFB8922A), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            zikr['virtue'] as String,
                            style: GoogleFonts.amiri(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCompleted ? null : () => _incrementCount(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.green : const Color(0xFF1565A8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'تم الإكمال' : 'اضغط للذكر',
                      style: GoogleFonts.amiri(fontSize: 16, color: Colors.white),
                    ),
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
