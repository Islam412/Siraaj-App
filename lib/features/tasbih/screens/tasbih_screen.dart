import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _totalCount = 0;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _customAzkar = [];
  
  final List<Map<String, dynamic>> _defaultAzkar = [
    {
      'text': 'سُبْحَانَ اللَّهِ',
      'translation': 'SubhanAllah',
      'virtue': 'من قالها مائة مرة حين يأوي إلى فراشه، غُفرت له ذنوبه وإن كانت مثل زبد البحر',
      'target': 33,
    },
    {
      'text': 'الْحَمْدُ لِلَّهِ',
      'translation': 'Alhamdulillah',
      'virtue': 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان',
      'target': 33,
    },
    {
      'text': 'اللَّهُ أَكْبَرُ',
      'translation': 'Allahu Akbar',
      'virtue': 'كلمة يحبها الله تعالى',
      'target': 34,
    },
    {
      'text': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'translation': 'La ilaha illallah',
      'virtue': 'من قالها مخلصاً من قلبه دخل الجنة',
      'target': 100,
    },
    {
      'text': 'أَسْتَغْفِرُ اللَّهَ',
      'translation': 'Astaghfirullah',
      'virtue': 'من لزم الاستغفار جعل الله له من كل هم فرجا',
      'target': 100,
    },
    {
      'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'translation': 'Salawat',
      'virtue': 'من صلى عليّ صلاة صلى الله عليه بها عشرا',
      'target': 100,
    },
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'translation': 'SubhanAllahi wa bihamdihi',
      'virtue': 'من قالها في يوم مائة مرة حُطت خطاياه وإن كانت مثل زبد البحر',
      'target': 100,
    },
    {
      'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation': 'La hawla wa la quwwata illa billah',
      'virtue': 'كنز من كنوز الجنة',
      'target': 100,
    },
    {
      'text': 'سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ',
      'translation': 'SubhanAllah al-Azeem wa bihamdihi',
      'virtue': 'غرست له نخلة في الجنة',
      'target': 100,
    },
  ];

  List<Map<String, dynamic>> get _allAzkar => [..._defaultAzkar, ..._customAzkar];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final customAzkarJson = prefs.getStringList('custom_azkar') ?? [];
    setState(() {
      _customAzkar = customAzkarJson.map((json) {
        return jsonDecode(json) as Map<String, dynamic>;
      }).toList();
    });

    final savedIndex = prefs.getInt('tasbih_selected_index') ?? 0;
    final savedCount = prefs.getInt('tasbih_count') ?? 0;
    final savedTotal = prefs.getInt('tasbih_total_count') ?? 0;

    setState(() {
      _selectedIndex = savedIndex;
      _count = savedCount;
      _totalCount = savedTotal;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final customAzkarJson = _customAzkar.map((zikr) {
      return jsonEncode(zikr);
    }).toList();
    await prefs.setStringList('custom_azkar', customAzkarJson);
    
    await prefs.setInt('tasbih_selected_index', _selectedIndex);
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_total_count', _totalCount);
  }

  void _incrementCount() {
    setState(() {
      _count++;
      _totalCount++;
    });
    _saveData();
    HapticFeedback.lightImpact();

    final target = _allAzkar[_selectedIndex]['target'] as int;
    if (_count >= target) {
      HapticFeedback.heavyImpact();
      _showCompletionDialogAndMoveNext();
    }
  }

  void _showCompletionDialogAndMoveNext() {
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
          'لقد أكملت الذكر\nبارك الله فيك',
          style: GoogleFonts.amiri(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToNextZikr();
            },
            child: Text('التالي', style: GoogleFonts.amiri(color: const Color(0xFFB8922A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _moveToNextZikr() {
    // الانتقال للذكر التالي
    int nextIndex = _selectedIndex + 1;
    
    // إذا وصلنا لآخر ذكر، نعود للأول
    if (nextIndex >= _allAzkar.length) {
      nextIndex = 0;
    }
    
    setState(() {
      _selectedIndex = nextIndex;
      _count = 0;
    });
    
    _saveData();
    
    // عرض رسالة الانتقال
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'الانتقال إلى: \${_allAzkar[_selectedIndex]["text"]}',
          style: GoogleFonts.amiri(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF1565A8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetCount() {
    setState(() {
      _count = 0;
    });
    _saveData();
  }

  void _selectZikr(int index) {
    setState(() {
      _selectedIndex = index;
      _count = 0;
    });
    _saveData();
  }

  void _showAddZikrDialog() {
    final textController = TextEditingController();
    final virtueController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'إضافة ذكر جديد',
          style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                style: GoogleFonts.amiri(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'نص الذكر',
                  labelStyle: GoogleFonts.amiri(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: virtueController,
                style: GoogleFonts.amiri(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'فضل الذكر (اختياري)',
                  labelStyle: GoogleFonts.amiri(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                style: GoogleFonts.amiri(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'العدد المستهدف',
                  labelStyle: GoogleFonts.amiri(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.amiri(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final newZikr = {
                  'text': textController.text,
                  'translation': '',
                  'virtue': virtueController.text,
                  'target': int.tryParse(targetController.text) ?? 33,
                };
                
                setState(() {
                  _customAzkar.add(newZikr);
                  _selectedIndex = _allAzkar.length - 1;
                  _count = 0;
                });
                
                _saveData();
                Navigator.pop(context);
              }
            },
            child: Text('إضافة', style: GoogleFonts.amiri(color: const Color(0xFFB8922A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentZikr = _allAzkar[_selectedIndex];
    final target = currentZikr['target'] as int;
    final progress = _count / target;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: Text('المسبحة', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFB8922A)),
            tooltip: 'إضافة ذكر',
            onPressed: _showAddZikrDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            color: const Color(0xFF132033),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: _allAzkar.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                final zikr = _allAzkar[index];
                return GestureDetector(
                  onTap: () => _selectZikr(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1565A8) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        zikr['text'] as String,
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'المسبحة الإلكترونية',
                    style: GoogleFonts.amiri(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB8922A),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CircularProgressIndicator(
                          value: progress > 1 ? 1 : progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8922A)),
                        ),
                      ),
                      GestureDetector(
                        onTap: _incrementCount,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565A8).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_count',
                                style: GoogleFonts.amiri(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'اضغط',
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentZikr['text'] as String,
                          style: GoogleFonts.amiri(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (currentZikr['virtue'] != null && (currentZikr['virtue'] as String).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB8922A).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFFB8922A)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'فضل الذكر:',
                                        style: GoogleFonts.amiri(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFB8922A),
                                        ),
                                      ),
                                      Text(
                                        currentZikr['virtue'] as String,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$target / $_count',
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          color: const Color(0xFFB8922A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _resetCount,
                    icon: const Icon(Icons.refresh),
                    label: Text('إعادة', style: GoogleFonts.amiri(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
