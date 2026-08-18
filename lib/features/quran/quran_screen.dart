import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> _surahs = [];
  bool _isLoading = true;
  String _selectedReciterId = 'ar.alafasy';

  final List<Map<String, String>> _reciters = [
    {'id': 'ar.alafasy', 'name': 'مشاري العفاسي'},
    {'id': 'ar.abdurrahmaansudais', 'name': 'عبد الرحمن السديس'},
    {'id': 'ar.husary', 'name': 'محمود خليل الحصري'},
    {'id': 'ar.minshawi', 'name': 'محمد صديق المنشاوي'},
    {'id': 'ar.abdulbasitmurattal', 'name': 'عبد الباسط عبد الصمد'},
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
      }
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
        title: const Text('القرآن الكريم'),
        actions: [
          DropdownButton<String>(
            value: _selectedReciterId,
            dropdownColor: Theme.of(context).colorScheme.surface,
            items: _reciters.map((reciter) {
              return DropdownMenuItem(
                value: reciter['id'],
                child: Text(reciter['name']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedReciterId = value!);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _surahs.length,
              itemBuilder: (context, index) {
                final surah = _surahs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text('${surah['number']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(surah['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri', fontSize: 18)),
                    subtitle: Text('${surah['numberOfAyahs']} آية - ${surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'}'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => _openSurah(surah),
                  ),
                );
              },
            ),
    );
  }

  void _openSurah(dynamic surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surah: surah,
          reciterId: _selectedReciterId,
          reciterName: _reciters.firstWhere((r) => r['id'] == _selectedReciterId)['name']!,
        ),
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final dynamic surah;
  final String reciterId;
  final String reciterName;

  const SurahDetailScreen({super.key, required this.surah, required this.reciterId, required this.reciterName});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> _ayahs = [];
  bool _isLoading = true;
  int? _playingAyahIndex;

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surah['number']}/quran-uthmani'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _ayahs = data['data']['ayahs'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playAyah(int index) async {
    final ayah = _ayahs[index];
    final url = 'https://cdn.islamic.network/quran/audio/128/${widget.reciterId}/${ayah['number']}.mp3';
    
    try {
      if (_playingAyahIndex == index) {
        await _audioPlayer.pause();
        setState(() => _playingAyahIndex = null);
      } else {
        setState(() => _playingAyahIndex = index);
        await _audioPlayer.play(UrlSource(url));
        
        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) setState(() => _playingAyahIndex = null);
        });
      }
    } catch (e) {
      setState(() => _playingAyahIndex = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تشغيل الصوت، تحقق من الإنترنت')),
        );
      }
    }
  }

  Future<void> _showTafsir(int index) async {
    final ayah = _ayahs[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفسير الآية ${ayah['numberInSurah']}'),
        content: FutureBuilder<String>(
          future: _fetchTafsir(widget.surah['number'], ayah['numberInSurah']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return const Text('حدث خطأ في تحميل التفسير');
            } else {
              return SingleChildScrollView(
                child: Text(snapshot.data ?? 'لا يوجد تفسير متاح', style: const TextStyle(fontSize: 16, height: 1.8, fontFamily: 'Amiri')),
              );
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Future<String> _fetchTafsir(int surahNum, int ayahNum) async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/ayah/$surahNum:$ayahNum/ar.muyassar'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'] ?? 'لا يوجد تفسير متاح';
      }
    } catch (e) {
      return 'تعذر تحميل التفسير';
    }
    return 'لا يوجد تفسير متاح';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah['name'])),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      const Icon(Icons.headphones, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('القارئ: ${widget.reciterName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      if (_playingAyahIndex != null)
                        IconButton(icon: const Icon(Icons.stop), onPressed: () { _audioPlayer.pause(); setState(() => _playingAyahIndex = null); }),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = _ayahs[index];
                      final isPlaying = _playingAyahIndex == index;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isPlaying ? Colors.blue.shade50 : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(ayah['text'], style: const TextStyle(fontSize: 22, fontFamily: 'Amiri', height: 2.2), textAlign: TextAlign.right),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(20)),
                                    child: Text('آية ${ayah['numberInSurah']}', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.blue),
                                        onPressed: () => _playAyah(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.menu_book_outlined, color: Colors.green),
                                        onPressed: () => _showTafsir(index),
                                      ),
                                    ],
                                  ),
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
            ),
    );
  }
}
