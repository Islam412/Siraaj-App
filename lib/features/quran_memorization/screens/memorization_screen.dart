import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});
  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  int _currentSurah = 1;
  int _currentAyah = 1;
  List<dynamic> _surahs = [];
  List<dynamic> _ayahs = [];
  bool _isLoading = true;
  TextEditingController _userInputController = TextEditingController();
  bool _showCorrectAnswer = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  int _totalAttempts = 0;

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
    setState(() { _currentSurah = surahNumber; _currentAyah = 1; _isLoading = true; _userInputController.clear(); _showCorrectAnswer = false; });
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani'));
      if (response.statusCode == 200) {
        setState(() { _ayahs = json.decode(response.body)['data']['ayahs']; _isLoading = false; });
      }
    } catch (e) { setState(() => _isLoading = false); }
  }

  String _removeTashkeel(String text) => text.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');

  void _checkMemorization() {
    if (_userInputController.text.trim().isEmpty) return;
    final correctText = _ayahs[_currentAyah - 1]['text'];
    final userInput = _userInputController.text.trim();
    final correctClean = _removeTashkeel(correctText);
    final userClean = _removeTashkeel(userInput);
    
    setState(() {
      _showCorrectAnswer = true;
      _totalAttempts++;
      int matches = 0;
      int length = userClean.length > correctClean.length ? correctClean.length : userClean.length;
      for (int i = 0; i < length; i++) { if (userClean[i] == correctClean[i]) matches++; }
      _isCorrect = length > 0 ? (matches / length) >= 0.7 : false;
      if (_isCorrect) _correctCount++;
    });
  }

  void _nextAyah() {
    if (_currentAyah < _ayahs.length) {
      setState(() { _currentAyah++; _userInputController.clear(); _showCorrectAnswer = false; _isCorrect = false; });
    } else if (_currentSurah < 114) {
      _loadAyahs(_currentSurah + 1);
    }
  }

  @override
  void dispose() { _userInputController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.psychology, color: Color(0xFFB8922A)),
          const SizedBox(width: 10),
          Text('اختبار الحفظ', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF132033),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _buildStatItem('صحيحة', _correctCount.toString(), Icons.check_circle, Colors.green),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                    _buildStatItem('المحاولات', _totalAttempts.toString(), Icons.help_outline, Colors.orange),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                    _buildStatItem('النسبة', _totalAttempts > 0 ? '${((_correctCount / _totalAttempts) * 100).toStringAsFixed(0)}%' : '0%', Icons.show_chart, const Color(0xFFB8922A)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFF1E3A5F),
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
                Expanded(child: _buildTestArea()),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: GoogleFonts.amiri(fontSize: 11, color: Colors.white54)),
    ]);
  }

  Widget _buildTestArea() {
    final currentAyahData = _ayahs[_currentAyah - 1];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFB8922A).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text('الآية ${currentAyahData['numberInSurah']} من سورة ${_surahs.firstWhere((s) => s['number'] == _currentSurah)['name']}', style: GoogleFonts.amiri(fontSize: 18, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3))),
            child: Column(
              children: [
                Text('اكتب ما تحفظه من الآية:', style: GoogleFonts.amiri(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    controller: _userInputController,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.amiri(fontSize: 24, color: Colors.white, height: 2.5),
                    decoration: const InputDecoration(hintText: 'اكتب هنا...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_showCorrectAnswer)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkMemorization,
                icon: const Icon(Icons.check, size: 24),
                label: Text('تحقق من الحفظ', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8922A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          if (_showCorrectAnswer) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: _isCorrect ? Colors.green : Colors.red)),
              child: Row(children: [
                Icon(_isCorrect ? Icons.check_circle : Icons.error, color: _isCorrect ? Colors.green : Colors.red, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Text(_isCorrect ? 'أحسنت! إجابة صحيحة 🎉' : 'حاول مرة أخرى، هناك بعض الأخطاء', style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: _isCorrect ? Colors.green : Colors.red))),
              ]),
            ),
            const SizedBox(height: 16),
            if (!_isCorrect)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFB8922A))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('الإجابة الصحيحة:', style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(currentAyahData['text'], style: const TextStyle(fontFamily: 'Amiri', fontSize: 26, height: 2.2, color: Colors.white), textAlign: TextAlign.right),
                ]),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() { _userInputController.clear(); _showCorrectAnswer = false; }),
                    icon: const Icon(Icons.replay),
                    label: Text('إعادة المحاولة', style: GoogleFonts.amiri(fontSize: 14)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextAyah,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('الآية التالية', style: GoogleFonts.amiri(fontSize: 14)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
