import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
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
  
  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }
  
  Future<void> _loadSurahs() async {
    try {
      final data = await _apiService.getSurah(1); // Just to test connection
      // Load full list
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );
      final jsonData = json.decode(response.body);
      
      setState(() {
        _surahs = jsonData['data'];
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
        title: const Text('القرآن الكريم'),
        actions: [
          DropdownButton<String>(
            value: _selectedReciterId,
            dropdownColor: Theme.of(context).colorScheme.surface,
            items: _apiService.getReciters().map((reciter) {
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
                      child: Text('${surah['number']}'),
                    ),
                    title: Text(surah['name']),
                    subtitle: Text(
                      '${surah['numberOfAyahs']} آية - ${surah['revelationType']}',
                    ),
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
        ),
      ),
    );
  }
}

// شاشة تفاصيل السورة
class SurahDetailScreen extends StatefulWidget {
  final dynamic surah;
  final String reciterId;
  
  const SurahDetailScreen({
    super.key,
    required this.surah,
    required this.reciterId,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranApiService _apiService = QuranApiService();
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
    
    try {
      if (_playingAyahIndex == index) {
        await _audioPlayer.stop();
        setState(() => _playingAyahIndex = null);
      } else {
        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        setState(() => _playingAyahIndex = index);
        
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _playingAyahIndex = null);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تشغيل الصوت: $e')),
      );
    }
  }
  
  void _showTafsir(int index) async {
    final ayah = _ayahs[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفسير الآية ${ayah['numberInSurah']}'),
        content: FutureBuilder<String>(
          future: _apiService.getTafsir(
            widget.surah['number'],
            ayah['numberInSurah'],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Text('حدث خطأ في تحميل التفسير');
            } else {
              return SingleChildScrollView(
                child: Text(
                  snapshot.data ?? 'لا يوجد تفسير متاح',
                  style: const TextStyle(fontSize: 16, height: 1.8),
                ),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
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
      appBar: AppBar(
        title: Text(widget.surah['name']),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _ayahs.length,
              itemBuilder: (context, index) {
                final ayah = _ayahs[index];
                final isPlaying = _playingAyahIndex == index;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ayah['text'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'Amiri',
                            height: 2.2,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                                  onPressed: () => _playAyah(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.menu_book),
                                  onPressed: () => _showTafsir(index),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text('آية ${ayah['numberInSurah']}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}