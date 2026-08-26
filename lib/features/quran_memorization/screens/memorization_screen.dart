import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:io';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  int _currentSurah = 1;
  int _currentAyah = 1;
  List<dynamic> _surahs = [];
  List<dynamic> _ayahs = [];
  List<dynamic> _recitationData = [];
  bool _isLoading = true;
  bool _showCorrectAnswer = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _totalAttempts = 0;
  String _selectedReciter = 'مشاري راشد العفاسي';
  bool _isPlayingReference = false; // تشغيل الآية الأصلية
  bool _isRecording = false; // تسجيل صوت المستخدم
  bool _isPlayingRecording = false; // تشغيل تسجيل المستخدم
  String? _recordedFilePath;
  bool _hasRecording = false;
  
  final List<Map<String, String>> _reciters = [
    {'name': 'مشاري راشد العفاسي', 'identifier': 'ar.alafasy'},
    {'name': 'عبد الرحمن السديس', 'identifier': 'ar.sudais'},
    {'name': 'سعود الشريم', 'identifier': 'ar.shuraim'},
    {'name': 'ماهر المعيقلي', 'identifier': 'ar.muaiqly'},
    {'name': 'محمود خليل الحصري', 'identifier': 'ar.husary'},
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
        setState(() { _surahs = json.decode(response.body)['data']; _isLoading = false; });
        _loadAyahs(1);
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  Future<void> _loadAyahs(int surahNumber) async {
    setState(() { 
      _currentSurah = surahNumber; 
      _currentAyah = 1; 
      _isLoading = true; 
      _showCorrectAnswer = false;
      _isPlayingReference = false;
      _isRecording = false;
      _isPlayingRecording = false;
      _hasRecording = false;
      _recordedFilePath = null;
    });
    
    try {
      final reciterId = _reciters.firstWhere((r) => r['name'] == _selectedReciter)['identifier'];
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,$reciterId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() { 
          _ayahs = data['data'][0]['ayahs']; 
          _recitationData = data['data'][1]['ayahs'];
          _isLoading = false; 
        });
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  Future<void> _playReferenceAyah() async {
    try {
      final audioUrl = _recitationData[_currentAyah - 1]['audio'];
      if (audioUrl == null || audioUrl.isEmpty) return;
      
      if (_isPlayingReference) {
        await _audioPlayer.pause();
        setState(() => _isPlayingReference = false);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        setState(() => _isPlayingReference = true);
        
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlayingReference = false);
        });
      }
    } catch (e) {
      print('Error playing reference: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final path = '/tmp/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _hasRecording = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى منح إذن الميكروفون', style: GoogleFonts.amiri())),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordedFilePath = path;
          _hasRecording = true;
        });
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;
    
    try {
      if (_isPlayingRecording) {
        await _audioPlayer.stop();
        setState(() => _isPlayingRecording = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
        setState(() => _isPlayingRecording = true);
        
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlayingRecording = false);
        });
      }
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  void _nextAyah() {
    if (_currentAyah < _ayahs.length) {
      setState(() { 
        _currentAyah++; 
        _showCorrectAnswer = false; 
        _isPlayingReference = false;
        _isRecording = false;
        _isPlayingRecording = false;
        _hasRecording = false;
        _recordedFilePath = null;
      });
    } else if (_currentSurah < 114) {
      _loadAyahs(_currentSurah + 1);
    }
  }

  @override
  void dispose() { 
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.mic, color: Color(0xFFB8922A)),
          const SizedBox(width: 10),
          Text('التسميع الصوتي', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : Column(
              children: [
                _buildStatsBar(),
                _buildControls(),
                Expanded(child: _buildTestArea()),
              ],
            ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF132033),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الآية', '$_currentAyah/${_ayahs.length}', Icons.book, const Color(0xFFB8922A)),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
          _buildStatItem('السورة', _surahs.isNotEmpty ? _surahs.firstWhere((s) => s['number'] == _currentSurah)['name'] : '', Icons.menu_book, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: GoogleFonts.amiri(fontSize: 11, color: Colors.white54)),
    ]);
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1E3A5F),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: _currentSurah,
              isExpanded: true,
              dropdownColor: const Color(0xFF132033),
              style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
              underline: const SizedBox(),
              items: _surahs.map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(value: s['number'] as int, child: Text(s['name']))).toList(),
              onChanged: (v) { if (v != null) _loadAyahs(v); },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedReciter,
              isExpanded: true,
              dropdownColor: const Color(0xFF132033),
              style: GoogleFonts.amiri(fontSize: 14, color: Colors.white),
              underline: const SizedBox(),
              items: _reciters.map<DropdownMenuItem<String>>((r) => DropdownMenuItem<String>(value: r['name'], child: Text(r['name']!, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _selectedReciter = v); _loadAyahs(_currentSurah); } },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // عرض الآية
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB8922A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'الآية ${_ayahs[_currentAyah - 1]['numberInSurah']} من سورة ${_surahs.firstWhere((s) => s['number'] == _currentSurah)['name']}',
                  style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _ayahs[_currentAyah - 1]['text'],
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 28, height: 2.2, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 1. الاستماع للآية الأصلية
          _buildSectionTitle('1. استمع للتلاوة الصحيحة'),
          const SizedBox(height: 12),
          _buildAudioButton(
            'استمع للآية',
            _isPlayingReference,
            Icons.play_circle,
            Icons.pause_circle,
            _playReferenceAyah,
            Colors.blue,
          ),
          const SizedBox(height: 24),
          
          // 2. تسجيل صوتك
          _buildSectionTitle('2. سجل تلاوتك'),
          const SizedBox(height: 12),
          if (!_hasRecording)
            _buildRecordButton()
          else
            _buildRecordedActions(),
          const SizedBox(height: 24),
          
          // 3. التحقق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextAyah,
              icon: const Icon(Icons.arrow_forward, size: 24),
              label: Text('الآية التالية', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFB8922A).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioButton(String label, bool isPlaying, IconData playIcon, IconData pauseIcon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isPlaying ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPlaying ? pauseIcon : playIcon,
              color: isPlaying ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.amiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPlaying ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : const Color(0xFFB8922A),
              shape: BoxShape.circle,
              boxShadow: [
                if (_isRecording)
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isRecording ? 'جاري التسجيل... اضغط للإيقاف' : 'اضغط للتسجيل',
          style: GoogleFonts.amiri(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildRecordedActions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAudioButton(
              'استمع لتسجيلك',
              _isPlayingRecording,
              Icons.play_circle,
              Icons.pause_circle,
              _playRecording,
              Colors.green,
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _hasRecording = false;
                  _recordedFilePath = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'يمكنك الاستماع لتسجيلك أو حذفه وتسجيل مرة أخرى',
          style: GoogleFonts.amiri(fontSize: 13, color: Colors.white54),
        ),
      ],
    );
  }
}
