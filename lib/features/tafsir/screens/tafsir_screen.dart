import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  int _selectedSurah = 1;
  int _selectedAyah = 1;
  String _selectedTafsir = 'ar.muyassar';
  List<dynamic> _surahs = [];
  List<dynamic> _ayahs = [];
  String _tafsirText = '';
  bool _isLoading = false;

  final List<Map<String, String>> _tafsirs = [
    {'id': 'ar.muyassar', 'name': 'التفسير الميسر', 'author': 'مجمع الملك فهد'},
    {'id': 'ar.jalalayn', 'name': 'تفسير الجلالين', 'author': 'المحلي والسيوطي'},
    {'id': 'ar.saadi', 'name': 'تفسير السعدي', 'author': 'عبد الرحمن السعدي'},
    {'id': 'ar.katheer', 'name': 'تفسير ابن كثير', 'author': 'ابن كثير'},
    {'id': 'ar.qurtubi', 'name': 'تفسير القرطبي', 'author': 'القرطبي'},
    {'id': 'ar.tabari', 'name': 'تفسير الطبري', 'author': 'ابن جرير الطبري'},
    {'id': 'ar.baghawi', 'name': 'تفسير البغوي', 'author': 'البغوي'},
    {'id': 'ar.fath', 'name': 'فتح القدير', 'author': 'الشوكاني'},
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
        setState(() {
          _surahs = json.decode(response.body)['data'];
        });
        _loadAyahs(1);
      }
    } catch (e) {
      print('Error loading surahs: $e');
    }
  }

  Future<void> _loadAyahs(int surahNumber) async {
    setState(() {
      _selectedSurah = surahNumber;
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _ayahs = data['data']['ayahs'];
          _isLoading = false;
        });
        _loadTafsir();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTafsir() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/ayah/$_selectedSurah:$_selectedAyah/editions/$_selectedTafsir'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data['data'].isNotEmpty && data['data'][0]['tafsir'] != null) {
            _tafsirText = data['data'][0]['tafsir']['text'];
          } else {
            _tafsirText = 'التفسير غير متوفر لهذه الآية';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _tafsirText = 'حدث خطأ في تحميل التفسير';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.menu_book, color: Color(0xFFB8922A)),
          const SizedBox(width: 10),
          Text('التفسير', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(child: _buildTafsirContent()),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF132033),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedSurah,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E3A5F),
                  style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A)),
                  underline: const SizedBox(),
                  items: _surahs.map<DropdownMenuItem<int>>((s) {
                    return DropdownMenuItem<int>(value: s['number'] as int, child: Text(s['name']));
                  }).toList(),
                  onChanged: (v) { if (v != null) _loadAyahs(v); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedAyah,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E3A5F),
                  style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A)),
                  underline: const SizedBox(),
                  items: List.generate(_ayahs.length, (i) => i + 1)
                      .map<DropdownMenuItem<int>>((n) => DropdownMenuItem<int>(value: n, child: Text('آية $n')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedAyah = v);
                      _loadTafsir();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _selectedTafsir,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E3A5F),
            style: GoogleFonts.amiri(fontSize: 14, color: Colors.white),
            underline: const SizedBox(),
            items: _tafsirs.map<DropdownMenuItem<String>>((t) {
              return DropdownMenuItem<String>(
                value: t['id'],
                child: Text('${t['name']} - ${t['author']}', style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedTafsir = v);
                _loadTafsir();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB8922A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'الآية ${_ayahs.isNotEmpty ? _ayahs[_selectedAyah - 1]['text'] : ''}',
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 28, height: 2.2, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _tafsirs.firstWhere((t) => t['id'] == _selectedTafsir)['name'] ?? '',
            style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              _tafsirText,
              style: GoogleFonts.amiri(fontSize: 18, height: 2.0, color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
