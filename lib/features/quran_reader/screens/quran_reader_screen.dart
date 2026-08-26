import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentSurah = 1;
  bool _isPlaying = false;
  String _selectedReciter = 'مشاري راشد العفاسي';
  List<dynamic> _surahs = [];
  List<dynamic> _ayahs = [];
  List<dynamic> _tafsirs = [];
  List<dynamic> _recitationData = []; // لتخزين روابط الصوت
  bool _isLoading = true;
  String _selectedTafsir = 'ar.muyassar';
  int _currentPlayingAyah = -1;
  double _fontSize = 36.0; // حجم الخط الافتراضي
  
  final List<Map<String, String>> _reciters = [
    {'name': 'مشاري راشد العفاسي', 'identifier': 'ar.alafasy'},
    {'name': 'عبد الرحمن السديس', 'identifier': 'ar.sudais'},
    {'name': 'سعود الشريم', 'identifier': 'ar.shuraim'},
    {'name': 'ماهر المعيقلي', 'identifier': 'ar.muaiqly'},
    {'name': 'محمود خليل الحصري', 'identifier': 'ar.husary'},
    {'name': 'محمد صديق المنشاوي', 'identifier': 'ar.minshawi'},
    {'name': 'عبد الباسط (مرتل)', 'identifier': 'ar.abdulbasitmurattal'},
    {'name': 'أحمد بن علي العجمي', 'identifier': 'ar.ajamy'},
    {'name': 'أبو بكر الشاطري', 'identifier': 'ar.shatri'},
    {'name': 'ياسر الدوسري', 'identifier': 'ar.dosari'},
    {'name': 'سعد الغامدي', 'identifier': 'ar.ghamadi'},
  ];

  final List<Map<String, String>> _availableTafsirs = [
    {'name': 'التفسير الميسر', 'id': 'ar.muyassar'},
    {'name': 'تفسير الجلالين', 'id': 'ar.jalalayn'},
    {'name': 'تفسير السعدي', 'id': 'ar.saadi'},
    {'name': 'تفسير ابن كثير', 'id': 'ar.katheer'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _surahs = data['data'];
          _isLoading = false;
        });
        _loadAyahsAndTafsir(1);
      }
    } catch (e) {
      print('Error loading surahs: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAyahsAndTafsir(int surahNumber) async {
    setState(() {
      _currentSurah = surahNumber;
      _isLoading = true;
      _isPlaying = false;
      _currentPlayingAyah = -1;
    });
    
    try {
      final reciterId = _reciters.firstWhere((r) => r['name'] == _selectedReciter)['identifier'];
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,$reciterId,$_selectedTafsir'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _ayahs = data['data'][0]['ayahs'];
          _recitationData = data['data'][1]['ayahs']; // بيانات التلاوة
          _tafsirs = data['data'][2]['ayahs'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading ayahs: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAyah(int ayahIndex) async {
    try {
      final audioUrl = _recitationData[ayahIndex]['audio'];
      
      if (audioUrl == null || audioUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('التلاوة غير متاحة', style: GoogleFonts.amiri()), backgroundColor: Colors.orange),
        );
        return;
      }
      
      print('Playing: $audioUrl');
      
      if (_isPlaying && _currentPlayingAyah == ayahIndex) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() {
          _isPlaying = true;
          _currentPlayingAyah = ayahIndex;
        });
        
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _currentPlayingAyah = -1;
            });
          }
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في التشغيل', style: GoogleFonts.amiri()), backgroundColor: Colors.red),
      );
    }
  }

  void _showTafsirDialog(int ayahIndex) {
    if (_tafsirs.isEmpty || ayahIndex >= _tafsirs.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('التفسير غير متوفر', style: GoogleFonts.amiri())),
      );
      return;
    }
    
    final tafsir = _tafsirs[ayahIndex]['text'];
    final ayahNumber = _ayahs[ayahIndex]['numberInSurah'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF132033),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFB8922A).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('$ayahNumber', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
                ),
                const Spacer(),
                Text('التفسير', style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
              ),
              child: Text(
                tafsir,
                style: GoogleFonts.amiri(fontSize: 16, color: Colors.white, height: 2),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSurahSelector() {
    if (_surahs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('جاري تحميل السور...', style: GoogleFonts.amiri())),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF132033),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('اختر السورة', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _surahs.length,
                itemBuilder: (context, index) {
                  final surah = _surahs[index];
                  final isSelected = surah['number'] == _currentSurah;
                  final ayahsCount = surah['ayahs'] != null ? surah['ayahs'].length : 0;
                  final revelationType = surah['revelationType'] ?? '';
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFB8922A) : const Color(0xFFB8922A).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${surah['number']}',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFFB8922A),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      surah['name'] ?? '',
                      style: GoogleFonts.amiri(fontSize: 18, color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: Text(
                      '$ayahsCount آية - ${revelationType == 'Meccan' ? 'مكية' : 'مدنية'}',
                      style: GoogleFonts.amiri(fontSize: 12, color: Colors.white54),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFB8922A)) : null,
                    onTap: () {
                      _loadAyahsAndTafsir(surah['number']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF132033),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('اختر القارئ', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _reciters.length,
                itemBuilder: (context, index) {
                  final reciter = _reciters[index];
                  final isSelected = reciter['name'] == _selectedReciter;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? const Color(0xFFB8922A) : const Color(0xFFB8922A).withOpacity(0.2),
                      child: Icon(Icons.record_voice_over, color: isSelected ? Colors.white : const Color(0xFFB8922A)),
                    ),
                    title: Text(
                      reciter['name']!,
                      style: GoogleFonts.amiri(fontSize: 16, color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFB8922A)) : null,
                    onTap: () {
                      setState(() {
                        _selectedReciter = reciter['name']!;
                        _isPlaying = false;
                        _currentPlayingAyah = -1;
                      });
                      _loadAyahsAndTafsir(_currentSurah);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.menu_book, color: Color(0xFFB8922A)),
          const SizedBox(width: 10),
          Text('قراءة القرآن', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            icon: Icon(_fontSize > 28 ? Icons.zoom_out : Icons.zoom_in, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_fontSize > 20) {
                  _fontSize -= 4;
                } else {
                  _fontSize = 48;
                }
              });
            },
            tooltip: _fontSize > 28 ? 'تصغير الخط' : 'تكبير الخط',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.book, color: Colors.white),
            color: const Color(0xFF132033),
            onSelected: (value) {
              setState(() => _selectedTafsir = value);
              _loadAyahsAndTafsir(_currentSurah);
            },
            itemBuilder: (context) => _availableTafsirs.map((tafsir) {
              return PopupMenuItem(
                value: tafsir['id'],
                child: Row(
                  children: [
                    if (_selectedTafsir == tafsir['id']) const Icon(Icons.check, color: Color(0xFFB8922A)),
                    const SizedBox(width: 8),
                    Text(tafsir['name']!, style: GoogleFonts.amiri(color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : Column(
              children: [
                _buildTopControls(),
                Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _ayahs.length, itemBuilder: (context, index) => _buildAyahCard(_ayahs[index], index))),
              ],
            ),
    );
  }

  Widget _buildTopControls() {
    dynamic currentSurahData;
    if (_surahs.isNotEmpty) {
      currentSurahData = _surahs.firstWhere(
        (s) => s['number'] == _currentSurah,
        orElse: () => {'name': '', 'ayahs': []},
      );
    } else {
      currentSurahData = {'name': '', 'ayahs': []};
    }
    
    final ayahsCount = currentSurahData['ayahs'] != null ? currentSurahData['ayahs'].length : 0;
    final surahName = currentSurahData['name'] ?? '';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A5F), Color(0xFF1565A8)],
        ),
      ),
      child: Column(
        children: [
          Text(
            'سورة $surahName',
            style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            '$ayahsCount آية',
            style: GoogleFonts.amiri(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showSurahSelector,
                  icon: const Icon(Icons.menu_book, size: 20),
                  label: Text('فهرس السور', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8922A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showReciterSelector,
                  icon: const Icon(Icons.record_voice_over, size: 20),
                  label: Text('القراء', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(dynamic ayah, int index) {
    final isPlaying = _isPlaying && _currentPlayingAyah == index;
    final ayahText = ayah['text'] ?? '';
    
    return GestureDetector(
      onTap: () => _showTafsirDialog(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPlaying ? const Color(0xFFB8922A) : const Color(0xFFB8922A).withOpacity(0.3), width: isPlaying ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPlaying ? const Color(0xFFB8922A) : const Color(0xFFB8922A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ayah['numberInSurah']}',
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? Colors.white : const Color(0xFFB8922A),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: isPlaying ? const Color(0xFFB8922A) : const Color(0xFFB8922A),
                    size: 36,
                  ),
                  onPressed: () => _playAyah(index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              ayahText,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: _fontSize,
                height: 2.3,
                color: const Color(0xFF1E3A5F),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.auto_stories, color: const Color(0xFFB8922A).withOpacity(0.7), size: 16),
                const SizedBox(width: 6),
                Text(
                  'اضغط لعرض التفسير',
                  style: GoogleFonts.amiri(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
