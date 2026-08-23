import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AzkarListWidget extends StatefulWidget {
  final dynamic category;
  final Function(int) onAllCompleted;

  const AzkarListWidget({
    super.key,
    required this.category,
    required this.onAllCompleted,
  });

  @override
  State<AzkarListWidget> createState() => _AzkarListWidgetState();
}

class _AzkarListWidgetState extends State<AzkarListWidget> {
  Map<int, int> _counts = {};
  bool _isLoading = true;
  bool _allCompleted = false;

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
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'azkar_${widget.category.name}';
    // حفظ العدادات
  }

  void _incrementCount(int index, int targetCount) {
    setState(() {
      _counts[index] = (_counts[index] ?? 0) + 1;
    });
    _saveCounts();
    _checkAllCompleted();
  }

  void _resetCount(int index) {
    setState(() {
      _counts[index] = 0;
    });
    _saveCounts();
    setState(() {
      _allCompleted = false;
    });
  }

  void _resetAllCounts() {
    setState(() {
      _counts.clear();
      _allCompleted = false;
    });
    _saveCounts();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إعادة تعيين جميع الأذكار',
          style: GoogleFonts.amiri(fontSize: 16),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _checkAllCompleted() {
    final azkar = widget.category.azkar;
    bool allDone = true;
    
    for (int i = 0; i < azkar.length; i++) {
      final targetCount = azkar[i]['count'] as int;
      final currentCount = _counts[i] ?? 0;
      if (currentCount < targetCount) {
        allDone = false;
        break;
      }
    }
    
    if (allDone && !_allCompleted) {
      setState(() {
        _allCompleted = true;
      });
      
      // إظهار رسالة إكمال
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCompletionDialog();
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFB8922A), size: 30),
            const SizedBox(width: 10),
            Text(
              'ما شاء الله!',
              style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'لقد أكملت ${widget.category.name}\nبارك الله فيك',
          style: GoogleFonts.amiri(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAllCounts();
              widget.onAllCompleted(widget.category.azkar.length);
            },
            child: Text(
              'إعادة تعيين والبدء من جديد',
              style: GoogleFonts.amiri(color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final azkar = widget.category.azkar;

    return Column(
      children: [
        // زر إعادة تعيين الكل
        if (azkar.any((zikr) {
          final index = azkar.indexOf(zikr);
          final targetCount = zikr['count'] as int;
          final currentCount = _counts[index] ?? 0;
          return currentCount > 0;
        }))
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetAllCounts,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'إعادة تعيين جميع الأذكار',
                      style: GoogleFonts.amiri(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isCompleted ? null : () => _incrementCount(index, targetCount),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCompleted ? Colors.green : const Color(0xFF1565A8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isCompleted ? '✓ تم الإكمال' : 'اضغط للذكر',
                                style: GoogleFonts.amiri(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          if (currentCount > 0) ...[
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _resetCount(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
