import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/quran_api_service.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final QuranApiService _apiService = QuranApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<dynamic> _surahs = [];
  bool _isLoading = true;
  String _selectedReciterId = 'ar.alafasy';
  String _selectedReciterName = 'مشاري راشد العفاسي';
  int _selectedAyahIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final data = await _apiService.getSurahList();
      setState(() {
        _surahs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تأكد من اتصال الإنترنت: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القرآن الكريم', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.headphones, color: Colors.white),
            tooltip: 'اختر القارئ',
            onSelected: (String value) {
              final reciter = _apiService.getReciters()
                  .firstWhere((r) => r['id'] == value);
              setState(() {
                _selectedReciterId = value;
                _selectedReciterName = reciter['name']!;
              });
            },
            itemBuilder: (context) => _apiService.getReciters().map((reciter) {
              final isSelected = reciter['id'] == _selectedReciterId;
              return PopupMenuItem(
                value: reciter['id'],
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.blue, size: 18),
                    if (!isSelected) const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(reciter['name']!, style: GoogleFonts.amiri(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'القارئ: $_selectedReciterName',
                          style: GoogleFonts.amiri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_selectedAyahIndex >= 0)
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () {
                            _audioPlayer.stop();
                            setState(() => _selectedAyahIndex = -1);
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _surahs.length,
                    itemBuilder: (context, index) {
                      final surah = _surahs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text(
                              '${surah['number']}',
                              style: GoogleFonts.amiri(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            surah['name'],
                            style: GoogleFonts.amiri(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            '${surah['numberOfAyahs']} آية - ${surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'}',
                            style: GoogleFonts.amiri(fontSize: 13),
                          ),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () => _openSurah(surah),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _openSurah(dynamic surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MushafScreen(
          surah: surah,
          reciterId: _selectedReciterId,
          reciterName: _selectedReciterName,
          onAyahSelected: (int index) {
            setState(() => _selectedAyahIndex = index);
          },
        ),
      ),
    ).then((_) {
      setState(() => _selectedAyahIndex = -1);
    });
  }
}

// ==========================================
// شاشة المصحف - عرض الآيات
// ==========================================
class MushafScreen extends StatefulWidget {
  final dynamic surah;
  final String reciterId;
  final String reciterName;
  final Function(int) onAyahSelected;

  const MushafScreen({
    super.key,
    required this.surah,
    required this.reciterId,
    required this.reciterName,
    required this.onAyahSelected,
  });

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  final QuranApiService _apiService = QuranApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<dynamic> _ayahs = [];
  bool _isLoading = true;
  int _playingAyahIndex = -1;
  bool _showTafsir = false;
  String _tafsirText = '';
  int _selectedTafsirAyah = 0;
  String _selectedTafsirBook = 'ar.muyassar';

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    try {
      final data = await _apiService.getSurah(widget.surah['number']);
      setState(() {
        _ayahs = data['ayahs'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAyah(int index) async {
    final ayah = _ayahs[index];
    final url = _apiService.getAudioUrl(
      widget.reciterId,
      ayah['number'],
    );

    if (_playingAyahIndex == index) {
      await _audioPlayer.stop();
      setState(() => _playingAyahIndex = -1);
      return;
    }

    setState(() => _playingAyahIndex = index);
    widget.onAyahSelected(index);

    try {
      await _audioPlayer.play(UrlSource(url));

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() => _playingAyahIndex = -1);
        }
      });
    } catch (e) {
      setState(() => _playingAyahIndex = -1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تشغيل الصوت، تحقق من الإنترنت')),
        );
      }
    }
  }

  Future<void> _showTafsirDialog(int index) async {
    final ayah = _ayahs[index];
    setState(() {
      _selectedTafsirAyah = ayah['numberInSurah'];
      _showTafsir = true;
      _tafsirText = 'جاري تحميل التفسير...';
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تفسير الآية ${ayah['numberInSurah']}',
                  style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedTafsirBook,
                  decoration: const InputDecoration(
                    labelText: 'اختر التفسير',
                    border: OutlineInputBorder(),
                  ),
                  items: _apiService.getTafsirBooks().map((tafsir) {
                    return DropdownMenuItem(
                      value: tafsir['id'],
                      child: Text(tafsir['name']!, style: GoogleFonts.amiri()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        _selectedTafsirBook = value;
                      });
                      _loadTafsir(ayah['numberInSurah'], value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _tafsirText,
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _showTafsir = false);
              },
              child: Text('إغلاق', style: GoogleFonts.amiri(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    _loadTafsir(ayah['numberInSurah'], _selectedTafsirBook);
  }

  Future<void> _loadTafsir(int ayahNum, String tafsirType) async {
    final tafsir = await _apiService.getTafsir(
      widget.surah['number'],
      ayahNum,
      tafsirType: tafsirType,
    );
    
    if (mounted) {
      setState(() {
        _tafsirText = tafsir;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah['name'], style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showTafsir ? Icons.visibility_off : Icons.visibility),
            tooltip: _showTafsir ? 'إخفاء التفسير' : 'عرض التفسير',
            onPressed: _showTafsir
                ? () => setState(() => _showTafsir = false)
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'القارئ: ${widget.reciterName}',
                          style: GoogleFonts.amiri(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_playingAyahIndex >= 0)
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () {
                            _audioPlayer.stop();
                            setState(() => _playingAyahIndex = -1);
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFFFFBF0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFB8922A), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'سورة ${widget.surah['name']}',
                                  style: GoogleFonts.amiriQuran(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF8B6914),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'} • ${widget.surah['numberOfAyahs']} آية',
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (widget.surah['number'] != 9)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                style: GoogleFonts.amiriQuran(
                                  fontSize: 28,
                                  color: const Color(0xFF8B6914),
                                  height: 2,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          const Divider(color: Color(0xFFB8922A)),
                          const SizedBox(height: 20),
                          ..._ayahs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final ayah = entry.value;
                            final isPlaying = _playingAyahIndex == index;

                            return GestureDetector(
                              onTap: () => _playAyah(index),
                              onLongPress: () => _showTafsirDialog(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? const Color(0xFFB8922A).withOpacity(0.2)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isPlaying
                                        ? const Color(0xFFB8922A)
                                        : Colors.grey.shade300,
                                    width: isPlaying ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      ayah['text'],
                                      style: GoogleFonts.amiriQuran(
                                        fontSize: 26,
                                        height: 2.8,
                                        color: isPlaying
                                            ? const Color(0xFF8B6914)
                                            : const Color(0xFF1A1A1A),
                                      ),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB8922A),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'آية ${_toArabicNumerals(ayah['numberInSurah'])}',
                                            style: GoogleFonts.amiri(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isPlaying ? Icons.pause : Icons.play_arrow,
                                                color: isPlaying ? const Color(0xFFB8922A) : Colors.blue,
                                              ),
                                              onPressed: () => _playAyah(index),
                                              tooltip: isPlaying ? 'إيقاف' : 'استماع',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.menu_book_outlined, color: Colors.green),
                                              onPressed: () => _showTafsirDialog(index),
                                              tooltip: 'التفسير',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNumbers = ['', '١', '', '٣', '٤', '', '٦', '٧', '', '٩'];
    return number.toString().split('').map((e) => arabicNumbers[int.parse(e)]).join('');
  }
}
