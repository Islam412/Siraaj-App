import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedReciter = 0;
  int _selectedSurah = 0;
  bool _isPlaying = false;
  int _selectedQiraat = 0; // 0: حفص, 1: ورش, 2: قالون
  int _fontSize = 24;
  bool _showTafsir = false;
  int _selectedTafsir = 0;
  
  // Khatma tracking
  Map<int, bool> _completedAyahs = {};
  DateTime? _khatmaStartDate;
  int _selectedKhatmaPlan = 0; // 0: شهري, 1: أسبوعي, 2: 10 أيام, 3: 15 يوم

  final List<Map<String, String>> _reciters = [
    {'name': 'مشاري راشد العفاسي', 'id': 'ar.alafasy'},
    {'name': 'عبد الرحمن السديس', 'id': 'ar.abdurrahmaansudais'},
    {'name': 'سعود الشريم', 'id': 'ar.saoodshuraym'},
    {'name': 'ماهر المعيقلي', 'id': 'ar.mahermuaiqly'},
    {'name': 'عبدالله بصفر', 'id': 'ar.abdullahbasfar'},
    {'name': 'محمود خليل الحصري', 'id': 'ar.husary'},
    {'name': 'محمد صديق المنشاوي', 'id': 'ar.minshawi'},
    {'name': 'عبد الباسط عبد الصمد', 'id': 'ar.abdulbasitmurattal'},
    {'name': 'أحمد الأعجمي', 'id': 'ar.ahmadajamy'},
    {'name': 'ياسر الدوسري', 'id': 'ar.yasserdossari'},
  ];

  final List<String> _qiraatNames = [
    'حفص عن عاصم',
    'ورش عن نافع',
    'قالون عن نافع',
  ];

  final List<String> _tafsirNames = [
    'التفسير الميسر',
    'تفسير الجلالين',
    'تفسير السعدي',
    'تفسير ابن كثير',
    'تفسير القرطبي',
  ];

  final List<Map<String, dynamic>> _khatmaPlans = [
    {'name': 'ختمة شهرية', 'partsPerDay': 1, 'days': 30},
    {'name': 'ختمة أسبوعية', 'partsPerDay': 4, 'days': 7},
    {'name': 'ختمة 10 أيام', 'partsPerDay': 3, 'days': 10},
    {'name': 'ختمة 15 يوم', 'partsPerDay': 2, 'days': 15},
  ];

  final List<Map<String, dynamic>> _surahs = [
    {'number': 1, 'name': 'الفاتحة', 'englishName': 'Al-Fatiha', 'verses': 7, 'type': 'Meccan'},
    {'number': 2, 'name': 'البقرة', 'englishName': 'Al-Baqara', 'verses': 286, 'type': 'Medinan'},
    {'number': 3, 'name': 'آل عمران', 'englishName': 'Ali Imran', 'verses': 200, 'type': 'Medinan'},
    // ... بقية السور
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _showBookmarks(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showQuranSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Khatma Progress Bar
          _buildKhatmaProgress(),
          
          // Reciter & Qiraat Selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedReciter,
                        decoration: const InputDecoration(
                          labelText: 'القارئ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _reciters.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReciter = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedQiraat,
                        decoration: const InputDecoration(
                          labelText: 'القراءة',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.menu_book),
                        ),
                        items: _qiraatNames.asMap().entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedQiraat = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Khatma Plan Selector
                _buildKhatmaSelector(),
              ],
            ),
          ),
          
          const Divider(),
          
          // Surah List
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _surahs.length,
              itemBuilder: (context, index) {
                final surah = _surahs[index];
                return _buildSurahCard(surah, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKhatmaProgress() {
    if (_khatmaStartDate == null) return const SizedBox.shrink();
    
    final totalAyahs = 6236; // إجمالي آيات القرآن
    final completed = _completedAyahs.values.where((v) => v).length;
    final progress = completed / totalAyahs;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, size: 18),
              const SizedBox(width: 8),
              Text(
                _khatmaPlans[_selectedKhatmaPlan]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('${(progress * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تم: $completed آية',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'المتبقي: ${totalAyahs - completed} آية',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildKhatmaSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 18),
              SizedBox(width: 8),
              Text(
                'خطة الختم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _khatmaPlans.asMap().entries.map((entry) {
              final index = entry.key;
              final plan = entry.value;
              final isSelected = _selectedKhatmaPlan == index;
              
              return ChoiceChip(
                label: Text('${plan['name']} (${plan['partsPerDay']} أجزاء/يوم)'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedKhatmaPlan = index;
                    if (selected) {
                      _khatmaStartDate = DateTime.now();
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah, int index) {
    final isCompleted = _isSurahCompleted(surah['number']);
    
    return Card(
      child: InkWell(
        onTap: () => _openSurah(surah),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Theme.of(context).colorScheme.primary, 
                     Theme.of(context).colorScheme.primary.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Surah Number Badge
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${surah['number']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${surah['verses']} آية - ${surah['type'] == 'Meccan' ? 'مكية' : 'مدنية'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  bool _isSurahCompleted(int surahNumber) {
    // منطق بسيط للتحقق من إتمام السورة
    // يمكن تطويره لاحقاً
    return false;
  }

  void _openSurah(Map<String, dynamic> surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahReadingScreen(
          surah: surah,
          reciter: _reciters[_selectedReciter],
          qiraat: _selectedQiraat,
          fontSize: _fontSize,
          onTafsirToggle: () => setState(() => _showTafsir = !_showTafsir),
          showTafsir: _showTafsir,
          selectedTafsir: _selectedTafsir,
          completedAyahs: _completedAyahs,
          onAyahComplete: (ayahNumber) {
            setState(() {
              _completedAyahs[ayahNumber] = true;
            });
          },
        ),
      ),
    );
  }

  void _showQuranSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات القراءة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('حجم الخط: '),
                Expanded(
                  child: Slider(
                    value: _fontSize.toDouble(),
                    min: 16,
                    max: 32,
                    divisions: 8,
                    label: '$_fontSize',
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_fontSize'),
              ],
            ),
            SwitchListTile(
              title: const Text('إظهار التفسير'),
              value: _showTafsir,
              onChanged: (value) {
                setState(() {
                  _showTafsir = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'المفضلة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('لا توجد سور محفوظة'),
          ],
        ),
      ),
    );
  }
}

// شاشة قراءة السورة
class SurahReadingScreen extends StatefulWidget {
  final Map<String, dynamic> surah;
  final Map<String, String> reciter;
  final int qiraat;
  final int fontSize;
  final bool showTafsir;
  final int selectedTafsir;
  final Function onTafsirToggle;
  final Map<int, bool> completedAyahs;
  final Function(int) onAyahComplete;

  const SurahReadingScreen({
    super.key,
    required this.surah,
    required this.reciter,
    required this.qiraat,
    required this.fontSize,
    required this.showTafsir,
    required this.selectedTafsir,
    required this.onTafsirToggle,
    required this.completedAyahs,
    required this.onAyahComplete,
  });

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int? _currentAyah;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah['name']),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAudio,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _bookmarkAyah(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Audio Controls
          if (_isPlaying)
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.queue_music),
                  const SizedBox(width: 8),
                  Text('يُتلى الآن: ${widget.reciter['name']}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _toggleAudio,
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: Row(
              children: [
                // Quran Text - Two Pages Layout
                Expanded(
                  flex: 2,
                  child: _buildMushafPages(),
                ),
                
                // Tafsir Panel (if enabled)
                if (widget.showTafsir)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildTafsirPanel(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onTafsirToggle,
        child: Icon(widget.showTafsir ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }

  Widget _buildMushafPages() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Basmala
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(
                fontSize: widget.fontSize.toDouble() + 8,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Ayahs
          ...List.generate(widget.surah['verses'], (index) {
            final ayahNumber = index + 1;
            final isCompleted = widget.completedAyahs[ayahNumber] ?? false;
            
            return _buildAyahCard(ayahNumber, isCompleted);
          }),
        ],
      ),
    );
  }

  Widget _buildAyahCard(int ayahNumber, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isCompleted 
          ? Colors.green.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: () => _handleAyahTap(ayahNumber),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ayah Text (Placeholder - should fetch from API)
              Text(
                'نص الآية $ayahNumber من سورة ${widget.surah['name']}',
                style: TextStyle(
                  fontSize: widget.fontSize.toDouble(),
                  fontFamily: 'Amiri',
                  height: 2.5,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              // Ayah Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Center(
                      child: Text(
                        '$ayahNumber',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'تم الحفظ',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTafsirPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.selectedTafsir == 0 
                    ? 'التفسير الميسر'
                    : widget.selectedTafsir == 1
                        ? 'تفسير الجلالين'
                        : 'تفسير السعدي',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onTafsirToggle,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                'هنا سيتم عرض التفسير للآية المحددة. هذا النص توضيحي فقط.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAyahTap(int ayahNumber) {
    widget.onAyahComplete(ayahNumber);
    // Play audio if enabled
    if (_isPlaying) {
      _playAyah(ayahNumber);
    }
  }

  void _toggleAudio() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Implement audio playback logic here
  }

  void _playAyah(int ayahNumber) {
    // Implement audio playback for specific ayah
  }

  void _bookmarkAyah() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة الآية للمفضلة')),
    );
  }
}
