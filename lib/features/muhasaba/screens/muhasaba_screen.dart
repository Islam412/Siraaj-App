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

  // متحكمات النصوص للحقول الإضافية
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _todayKey = DateTime.now().toIso8601String().split('T')[0];
    _loadTodayData();
    _loadStats();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _gratitudeController.dispose();
    _goalController.dispose();
    super.dispose();
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

    // تحميل النصوص المحفوظة
    _notesController.text = prefs.getString('muhasaba_notes_$_todayKey') ?? '';
    _gratitudeController.text = prefs.getString('muhasaba_gratitude_$_todayKey') ?? '';
    _goalController.text = prefs.getString('muhasaba_goal_$_todayKey') ?? '';
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalDays = prefs.getInt('muhasaba_total_days') ?? 0;
    });
  }

  Future<void> _saveAnswer(String questionId, String answer) async {
    setState(() {
      _answers[questionId] = answer;
      _calculateStats();
    });
    await _saveAllData();
  }

  Future<void> _saveAllData() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('muhasaba_$_todayKey', jsonEncode(_answers));
    await prefs.setString('muhasaba_notes_$_todayKey', _notesController.text);
    await prefs.setString('muhasaba_gratitude_$_todayKey', _gratitudeController.text);
    await prefs.setString('muhasaba_goal_$_todayKey', _goalController.text);
    
    // تحديث عدد الأيام المكتملة
    if (_answers.length == MuhasabaData.questions.length) {
      final totalDays = (prefs.getInt('muhasaba_total_days') ?? 0) + 1;
      await prefs.setInt('muhasaba_total_days', totalDays);
      setState(() => _totalDays = totalDays);
    }

    setState(() => _isSaving = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ محاسبة اليوم بنجاح', style: GoogleFonts.amiri()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
          _buildStatsCard(),
          
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

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // قائمة الأسئلة
                ...questions.map((q) => _buildQuestionCard(q)).toList(),
                
                const SizedBox(height: 20),
                
                // الحقول الإضافية
                _buildExtraFieldsCard(),
                
                const SizedBox(height: 20),
                
                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAllData,
                    icon: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save, size: 24),
                    label: Text(
                      _isSaving ? 'جاري الحفظ...' : 'حفظ محاسبة اليوم',
                      style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8922A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الحسنات', _goodDeeds.toString(), Icons.check_circle, Colors.green),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('السيئات', _badDeeds.toString(), Icons.cancel, Colors.red),
          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
          _buildStatItem('أيام المحاسبة', _totalDays.toString(), Icons.calendar_today, const Color(0xFFB8922A)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.amiri(fontSize: 12, color: Colors.white.withOpacity(0.8))),
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
                  child: Text(question.icon, style: const TextStyle(fontSize: 24)),
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
                          style: GoogleFonts.amiri(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.question,
                        style: GoogleFonts.amiri(fontSize: 16, color: Colors.white, height: 1.5),
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
                  child: _buildAnswerButton('نعم', answer == 'good', Colors.green, () => _saveAnswer(question.id, 'good')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnswerButton('لا', answer == 'bad', Colors.red, () => _saveAnswer(question.id, 'bad')),
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

  Widget _buildExtraFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFFB8922A), size: 24),
              const SizedBox(width: 10),
              Text(
                'تأملات وخواطر اليوم',
                style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            controller: _gratitudeController,
            label: '🌟 ماذا أشكر الله عليه اليوم؟',
            hint: 'اكتب 3 نعم تشعر بالامتنان لها...',
          ),
          const SizedBox(height: 12),
          
          _buildTextField(
            controller: _notesController,
            label: '📝 ملاحظات أو ذنوب أستغفر الله منها',
            hint: 'اكتب هنا لتفرغ قلبك وتتاب...',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          
          _buildTextField(
            controller: _goalController,
            label: '🎯 هدفي وغداً',
            hint: 'ما هو العمل الصالح الذي ألتزم به غداً؟',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.amiri(fontSize: 14, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.amiri(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.amiri(fontSize: 13, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0B1623),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFB8922A), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) {
            // حفظ تلقائي عند الكتابة (اختياري)
          },
        ),
      ],
    );
  }
}
