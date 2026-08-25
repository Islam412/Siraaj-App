import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/muhasaba_data.dart';

class MuhasabaScreen extends StatefulWidget {
  const MuhasabaScreen({super.key});

  @override
  State<MuhasabaScreen> createState() => _MuhasabaScreenState();
}

class _MuhasabaScreenState extends State<MuhasabaScreen> {
  String _selectedCategory = 'الكل';
  Map<String, String> _answers = {};
  String _todayKey = '';
  int _goodDeeds = 0;
  int _badDeeds = 0;
  int _totalDays = 0;

  @override
  void initState() {
    super.initState();
    _todayKey = DateTime.now().toIso8601String().split('T')[0];
    _loadTodayData();
    _loadStats();
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('muhasaba_$_todayKey');
    
    if (savedData != null) {
      setState(() {
        _answers = Map<String, String>.from(jsonDecode(savedData));
        _calculateStats();
      });
    }
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalDays = prefs.getInt('muhasaba_total_days') ?? 0;
    });
  }

  Future<void> _saveAnswer(String questionId, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _answers[questionId] = answer;
      _calculateStats();
    });

    await prefs.setString('muhasaba_$_todayKey', jsonEncode(_answers));
    
    // تحديث الإحصائيات
    if (_answers.length == MuhasabaData.questions.length) {
      final totalDays = (prefs.getInt('muhasaba_total_days') ?? 0) + 1;
      await prefs.setInt('muhasaba_total_days', totalDays);
      setState(() {
        _totalDays = totalDays;
      });
    }
  }

  void _calculateStats() {
    int good = 0;
    int bad = 0;
    
    _answers.forEach((key, value) {
      if (value == 'good') good++;
      if (value == 'bad') bad++;
    });
    
    setState(() {
      _goodDeeds = good;
      _badDeeds = bad;
    });
  }

  List<MuhasabaQuestion> _getFilteredQuestions() {
    return MuhasabaData.getQuestionsByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final categories = MuhasabaData.getCategories();
    final questions = _getFilteredQuestions();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'محاسبة النفس',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // بطاقة الإحصائيات
          _buildStatsCard(),
          
          // فلتر التصنيفات
          Container(
            height: 60,
            color: const Color(0xFF132033),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFB8922A) : const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        category,
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // قائمة الأسئلة
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return _buildQuestionCard(question);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565A8).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الحسنات', _goodDeeds.toString(), Icons.check_circle, Colors.green),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem('السيئات', _badDeeds.toString(), Icons.cancel, Colors.red),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatItem('أيام المحاسبة', _totalDays.toString(), Icons.calendar_today, const Color(0xFFB8922A)),
            ],
          ),
          const SizedBox(height: 16),
          // شريط التقدم
          if (_goodDeeds + _badDeeds > 0)
            Column(
              children: [
                LinearProgressIndicator(
                  value: _goodDeeds / (_goodDeeds + _badDeeds),
                  backgroundColor: Colors.red.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'نسبة الحسنات: ${((_goodDeeds / (_goodDeeds + _badDeeds)) * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.amiri(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(MuhasabaQuestion question) {
    final answer = _answers[question.id];
    final color = Color(int.parse(question.color));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    question.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          question.category,
                          style: GoogleFonts.amiri(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnswerButton(
                    'نعم',
                    answer == 'good',
                    Colors.green,
                    () => _saveAnswer(question.id, 'good'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnswerButton(
                    'لا',
                    answer == 'bad',
                    Colors.red,
                    () => _saveAnswer(question.id, 'bad'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String text, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.amiri(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
