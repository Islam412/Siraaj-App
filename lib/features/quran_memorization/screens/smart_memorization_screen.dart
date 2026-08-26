import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';

class SmartMemorizationScreen extends StatefulWidget {
  const SmartMemorizationScreen({super.key});

  @override
  State<SmartMemorizationScreen> createState() => _SmartMemorizationScreenState();
}

class _SmartMemorizationScreenState extends State<SmartMemorizationScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<dynamic> _surahs = [];
  List<dynamic> _ayahs = [];
  List<dynamic> _recitationData = [];
  
  int _selectedSurah = 1;
  int _startAyah = 1;
  int _endAyah = 7;
  String _selectedRange = 'full';
  int _selectedHizb = 0; // 0 = لا شيء
  
  int _currentAyahIndex = 0;
  bool _isLoading = true;
  bool _isListening = false;
  String _capturedText = '';
  bool _speechAvailable = false;
  
  List<Map<String, dynamic>> _results = [];
  bool _showFinalEvaluation = false;
  double _totalScore = 0;
  
  String _selectedReciter = 'مشاري راشد العفاسي';
  final List<Map<String, String>> _reciters = [
    {'name': 'مشاري راشد العفاسي', 'identifier': 'ar.alafasy'},
    {'name': 'عبد الرحمن السديس', 'identifier': 'ar.sudais'},
    {'name': 'سعود الشريم', 'identifier': 'ar.shuraim'},
    {'name': 'ماهر المعيقلي', 'identifier': 'ar.muaiqly'},
  ];

  // خريطة الأحزاب لكل سورة (بداية ونهاية كل حزب)
  // كل حزب = حوالي 5 صفحات من المصحف
  final Map<int, List<Map<String, int>>> _hizbMap = {
    1: [ // الفاتحة - حزب واحد فقط
      {'start': 1, 'end': 7},
    ],
    2: [ // البقرة - 19 حزب
      {'start': 1, 'end': 14}, {'start': 15, 'end': 25}, {'start': 26, 'end': 37},
      {'start': 38, 'end': 52}, {'start': 53, 'end': 71}, {'start': 72, 'end': 82},
      {'start': 83, 'end': 91}, {'start': 92, 'end': 103}, {'start': 104, 'end': 113},
      {'start': 114, 'end': 123}, {'start': 124, 'end': 133}, {'start': 134, 'end': 141},
      {'start': 142, 'end': 152}, {'start': 153, 'end': 162}, {'start': 163, 'end': 172},
      {'start': 173, 'end': 183}, {'start': 184, 'end': 196}, {'start': 197, 'end': 202},
      {'start': 203, 'end': 286},
    ],
    3: [ // آل عمران - 8 أحزاب
      {'start': 1, 'end': 25}, {'start': 26, 'end': 41}, {'start': 42, 'end': 57},
      {'start': 58, 'end': 73}, {'start': 74, 'end': 92}, {'start': 93, 'end': 110},
      {'start': 111, 'end': 130}, {'start': 131, 'end': 200},
    ],
    // ... يمكن إضافة باقي السور هنا
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadSurahs();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          print('Speech error: ${error.errorMsg}');
          if (error.errorMsg.contains('MissingPluginException') || error.permanent) {
            setState(() => _speechAvailable = false);
          }
        },
        onStatus: (status) {
          if (status == 'listening') {
            setState(() => _isListening = true);
          } else {
            setState(() => _isListening = false);
            if (_capturedText.isNotEmpty) {
              _evaluateCurrentAyah();
            }
          }
        },
      );
      setState(() {});
    } catch (e) {
      print('Error initializing speech: $e');
      setState(() => _speechAvailable = false);
    }
  }

  Future<void> _loadSurahs() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      if (response.statusCode == 200) {
        setState(() { 
          _surahs = json.decode(response.body)['data']; 
          _isLoading = false; 
        });
        _loadAyahs(1);
      }
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  Future<void> _loadAyahs(int surahNumber) async {
    setState(() { 
      _selectedSurah = surahNumber; 
      _isLoading = true;
      _results.clear();
      _showFinalEvaluation = false;
      _currentAyahIndex = 0;
      _selectedHizb = 0;
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
          _endAyah = _ayahs.length;
          _isLoading = false; 
        });
      }
    } catch (e) { 
      setState(() => _isLoading = false); 
    }
  }

  void _selectHizb(int hizbNumber) {
    if (_hizbMap.containsKey(_selectedSurah)) {
      final hizbs = _hizbMap[_selectedSurah]!;
      if (hizbNumber > 0 && hizbNumber <= hizbs.length) {
        final hizb = hizbs[hizbNumber - 1];
        setState(() {
          _selectedHizb = hizbNumber;
          _startAyah = hizb['start']!;
          _endAyah = hizb['end']!;
          _selectedRange = 'hizb';
          _currentAyahIndex = 0;
          _results.clear();
        });
      }
    }
  }

  void _selectRange(String range) {
    setState(() {
      _selectedRange = range;
      _selectedHizb = 0;
      _applyRange(range);
    });
  }

  void _applyRange(String range) {
    final totalAyahs = _ayahs.length;
    switch (range) {
      case 'full': _startAyah = 1; _endAyah = totalAyahs; break;
      case 'half_first': _startAyah = 1; _endAyah = (totalAyahs / 2).ceil(); break;
      case 'half_second': _startAyah = (totalAyahs / 2).ceil() + 1; _endAyah = totalAyahs; break;
    }
    _currentAyahIndex = 0;
    _results.clear();
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    setState(() { _capturedText = ''; _isListening = true; });
    try {
      await _speech.listen(
        onResult: (val) => setState(() => _capturedText = val.recognizedWords),
        localeId: 'ar_SA',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
      );
    } catch (e) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _evaluateCurrentAyah() {
    if (_capturedText.isEmpty) return;
    final currentAyahNum = _startAyah + _currentAyahIndex;
    if (currentAyahNum > _endAyah) return;
    
    final correctText = _ayahs[currentAyahNum - 1]['text'];
    final cleanCorrect = _removeTashkeel(correctText);
    final cleanSpoken = _removeTashkeel(_capturedText);
    final similarity = _calculateSimilarity(cleanSpoken, cleanCorrect);
    
    setState(() {
      _results.add({
        'ayahNumber': currentAyahNum,
        'text': correctText,
        'spoken': _capturedText,
        'similarity': similarity,
        'isCorrect': similarity >= 0.7,
      });
      _currentAyahIndex++;
      _capturedText = '';
      if (_startAyah + _currentAyahIndex > _endAyah) {
        _showFinalEvaluation = true;
        _calculateTotalScore();
      }
    });
  }

  void _calculateTotalScore() {
    if (_results.isEmpty) return;
    final correctCount = _results.where((r) => r['isCorrect'] == true).length;
    _totalScore = (correctCount / _results.length) * 100;
  }

  String _removeTashkeel(String text) => text.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640\u0651]'), '').replaceAll(' ', '');

  double _calculateSimilarity(String spoken, String correct) {
    if (spoken.isEmpty || correct.isEmpty) return 0.0;
    int matches = 0;
    int minLength = spoken.length < correct.length ? spoken.length : correct.length;
    for (int i = 0; i < minLength; i++) {
      if (spoken[i] == correct[i]) matches++;
    }
    return matches / correct.length;
  }

  @override
  void dispose() { 
    _audioPlayer.dispose();
    _speech.stop();
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
          const Icon(Icons.auto_awesome, color: Color(0xFFB8922A)),
          const SizedBox(width: 10),
          Text('التسميع الذكي', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : _showFinalEvaluation ? _buildFinalEvaluation() : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSurahSelector(),
          const SizedBox(height: 16),
          _buildHizbSelector(),
          const SizedBox(height: 16),
          _buildAyahGrid(),
          const SizedBox(height: 20),
          _buildCurrentAyahSection(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSurahSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF132033), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.menu_book, color: Color(0xFFB8922A)), const SizedBox(width: 8), Text('اختر السورة', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)))]),
          const SizedBox(height: 12),
          DropdownButton<int>(
            value: _selectedSurah,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E3A5F),
            style: GoogleFonts.amiri(fontSize: 16, color: Colors.white),
            underline: const SizedBox(),
            items: _surahs.map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(value: s['number'] as int, child: Text('${s['name']} (${s['numberOfAyahs']} آية)'))).toList(),
            onChanged: (v) { if (v != null) _loadAyahs(v); },
          ),
        ],
      ),
    );
  }

  Widget _buildHizbSelector() {
    final hizbCount = _hizbMap[_selectedSurah]?.length ?? 0;
    if (hizbCount == 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF132033), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.view_week, color: Color(0xFFB8922A)), const SizedBox(width: 8), Text('الأحزاب ($hizbCount)', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)))]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(hizbCount, (index) {
              final hizbNum = index + 1;
              final isSelected = _selectedHizb == hizbNum;
              return GestureDetector(
                onTap: () => _selectHizb(hizbNum),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFB8922A) : const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    'الحزب $hizbNum',
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahGrid() {
    final totalAyahs = _endAyah - _startAyah + 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF132033), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.grid_view, color: Color(0xFFB8922A)), const SizedBox(width: 8), Expanded(child: Text('آيات التسميع: $_startAyah إلى $_endAyah ($totalAyahs آية)', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))))]),
          const SizedBox(height: 12),
          if (totalAyahs <= 50)
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, childAspectRatio: 1.2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: totalAyahs,
              itemBuilder: (context, index) {
                final ayahNum = _startAyah + index;
                final isCompleted = _results.any((r) => r['ayahNumber'] == ayahNum);
                final isCurrent = index == _currentAyahIndex;
                return Container(
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFFB8922A) : (isCompleted ? Colors.green.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCurrent ? const Color(0xFFB8922A) : (isCompleted ? Colors.green : Colors.white.withOpacity(0.2)), width: 2),
                  ),
                  child: Center(child: Text('$ayahNum', style: GoogleFonts.amiri(fontSize: 12, fontWeight: FontWeight.bold, color: isCurrent || isCompleted ? Colors.white : Colors.white70))),
                );
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Column(children: [Text('عدد الآيات كبير', style: GoogleFonts.amiri(fontSize: 16, color: Colors.white70)), const SizedBox(height: 8), Text('الآيات من $_startAyah إلى $_endAyah', style: GoogleFonts.amiri(fontSize: 14, color: const Color(0xFFB8922A)))]),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentAyahSection() {
    if (_currentAyahIndex >= (_endAyah - _startAyah + 1)) return const SizedBox.shrink();
    final currentAyahNum = _startAyah + _currentAyahIndex;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _isListening ? [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)] : [const Color(0xFFB8922A).withOpacity(0.2), const Color(0xFFB8922A).withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isListening ? Colors.red : const Color(0xFFB8922A), width: 2),
      ),
      child: Column(
        children: [
          Text('الآية $currentAyahNum', style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: _isListening ? Colors.red : const Color(0xFFB8922A))),
          const SizedBox(height: 8),
          Text('اضغط الميكروفون وابدأ القراءة', style: GoogleFonts.amiri(fontSize: 14, color: Colors.white54)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: _isListening ? Colors.red : const Color(0xFFB8922A), shape: BoxShape.circle, boxShadow: _isListening ? [BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 30, spreadRadius: 10)] : []),
              child: Icon(_isListening ? Icons.stop : Icons.mic, size: 50, color: Colors.white),
            ),
          ),
          if (_isListening) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 8),
            Text('جاري الاستماع...', style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70)),
          ],
          if (_capturedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text('ما تم التقاطه:', style: GoogleFonts.amiri(fontSize: 14, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Text(_capturedText, style: GoogleFonts.amiri(fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: ElevatedButton.icon(onPressed: _results.isNotEmpty ? () { setState(() { _showFinalEvaluation = true; _calculateTotalScore(); }); } : null, icon: const Icon(Icons.assessment), label: Text('عرض التقييم', style: GoogleFonts.amiri(fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8922A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(onPressed: () { setState(() { _results.clear(); _currentAyahIndex = 0; _capturedText = ''; }); }, icon: const Icon(Icons.refresh), label: Text('إعادة التسميع', style: GoogleFonts.amiri(fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
      ],
    );
  }

  Widget _buildFinalEvaluation() {
    final correctCount = _results.where((r) => r['isCorrect'] == true).length;
    final incorrectCount = _results.length - correctCount;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: LinearGradient(colors: _totalScore >= 70 ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)] : [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.1)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: _totalScore >= 70 ? Colors.green : Colors.orange, width: 2)),
            child: Column(children: [Icon(_totalScore >= 70 ? Icons.emoji_events : Icons.trending_up, size: 60, color: _totalScore >= 70 ? Colors.green : Colors.orange), const SizedBox(height: 12), Text('نتيجة التسميع', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), const SizedBox(height: 8), Text('${_totalScore.toStringAsFixed(0)}%', style: GoogleFonts.amiri(fontSize: 48, fontWeight: FontWeight.bold, color: _totalScore >= 70 ? Colors.green : Colors.orange)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildMiniStat('صحيحة', correctCount.toString(), Icons.check_circle, Colors.green), _buildMiniStat('خاطئة', incorrectCount.toString(), Icons.cancel, Colors.red), _buildMiniStat('الإجمالي', _results.length.toString(), Icons.format_list_numbered, const Color(0xFFB8922A))])]),
          ),
          const SizedBox(height: 20),
          Text('تفاصيل التسميع', style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
          const SizedBox(height: 12),
          ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _results.length, itemBuilder: (context, index) => _buildAyahResultCard(_results[index])),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () { setState(() { _showFinalEvaluation = false; _results.clear(); _currentAyahIndex = 0; _capturedText = ''; }); }, icon: const Icon(Icons.refresh), label: Text('تسميع جديد', style: GoogleFonts.amiri(fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8922A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () { if (_selectedSurah < 114) _loadAyahs(_selectedSurah + 1); }, icon: const Icon(Icons.arrow_forward), label: Text('السورة التالية', style: GoogleFonts.amiri(fontSize: 14)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 4), Text(value, style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), Text(label, style: GoogleFonts.amiri(fontSize: 11, color: Colors.white54))]);
  }

  Widget _buildAyahResultCard(Map<String, dynamic> result) {
    final isCorrect = result['isCorrect'] as bool;
    final similarity = result['similarity'] as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: isCorrect ? Colors.green : Colors.red, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isCorrect ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(8)), child: Text('${result['ayahNumber']}', style: GoogleFonts.amiri(fontWeight: FontWeight.bold, color: Colors.white))), const Spacer(), Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 28)]),
          const SizedBox(height: 12),
          Text('النص الصحيح:', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Text(result['text'], style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, height: 2.0, color: Colors.white), textAlign: TextAlign.right),
          const SizedBox(height: 12),
          Text('تلاوتك:', style: GoogleFonts.amiri(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 4),
          Text(result['spoken'], style: GoogleFonts.amiri(fontSize: 16, height: 1.8, color: Colors.white70), textAlign: TextAlign.right),
          const SizedBox(height: 8),
          Text('نسبة التطابق: ${(similarity * 100).toStringAsFixed(0)}%', style: GoogleFonts.amiri(fontSize: 14, color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
