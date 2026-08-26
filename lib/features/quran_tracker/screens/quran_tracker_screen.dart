import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/quran_tracker_data.dart';

class QuranTrackerScreen extends StatefulWidget {
  const QuranTrackerScreen({super.key});

  @override
  State<QuranTrackerScreen> createState() => _QuranTrackerScreenState();
}

class _QuranTrackerScreenState extends State<QuranTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // متغيرات الحالة
  int _khatamCount = 0;
  int _dailyGoal = 0;
  int _dailyRead = 0;
  String _todayKey = '';
  
  // تتبع الحفظ: { "surah_1": {"memorized": true, "tested": false} }
  Map<String, Map<String, bool>> _hifzProgress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _todayKey = DateTime.now().toIso8601String().split('T')[0];
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _khatamCount = prefs.getInt('quran_khatam_count') ?? 0;
      _dailyGoal = prefs.getInt('quran_daily_goal') ?? 0;
      _dailyRead = prefs.getInt('quran_daily_read_$_todayKey') ?? 0;
      
      final hifzData = prefs.getString('quran_hifz_progress');
      if (hifzData != null) {
        _hifzProgress = Map<String, Map<String, bool>>.from(
          jsonDecode(hifzData).map((key, value) => MapEntry(key, Map<String, bool>.from(value)))
        );
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_khatam_count', _khatamCount);
    await prefs.setInt('quran_daily_goal', _dailyGoal);
    await prefs.setInt('quran_daily_read_$_todayKey', _dailyRead);
    await prefs.setString('quran_hifz_progress', jsonEncode(_hifzProgress));
  }

  void _incrementRead() {
    setState(() {
      _dailyRead++;
      if (_dailyGoal > 0 && _dailyRead >= _dailyGoal) {
        _showKhatamCompletionDialog();
      }
    });
    _saveData();
  }

  void _decrementRead() {
    if (_dailyRead > 0) {
      setState(() => _dailyRead--);
      _saveData();
    }
  }

  void _showKhatamCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF132033),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text('ما شاء الله!', style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'لقد أتممت ورد اليوم بنجاح! هل ترغب في تسجيل ختمة جديدة؟',
          style: GoogleFonts.amiri(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('لا، شكراً', style: GoogleFonts.amiri(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _khatamCount++;
                _dailyRead = 0; // إعادة تعيين لليوم التالي أو يمكن إبقاؤها
              });
              _saveData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تسجيل الختمة رقم $_khatamCount! بارك الله فيك', style: GoogleFonts.amiri()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8922A)),
            child: Text('نعم، تسجيل ختمة', style: GoogleFonts.amiri(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleHifzStatus(String surahKey, String status) {
    setState(() {
      if (_hifzProgress[surahKey] == null) {
        _hifzProgress[surahKey] = {'memorized': false, 'tested': false};
      }
      _hifzProgress[surahKey]![status] = !(_hifzProgress[surahKey]![status] ?? false);
      
      // إذا تم إلغاء الحفظ، إلغاء التسميع تلقائياً
      if (status == 'memorized' && !_hifzProgress[surahKey]!['memorized']!) {
        _hifzProgress[surahKey]!['tested'] = false;
      }
    });
    _saveData();
  }

  void _setPlan(KhatamPlan plan) {
    setState(() {
      _dailyGoal = plan.pagesPerDay;
      _dailyRead = 0;
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل خطة: ${plan.name}', style: GoogleFonts.amiri()),
        backgroundColor: const Color(0xFFB8922A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text('متابعة القرآن', style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFB8922A),
          labelColor: const Color(0xFFB8922A),
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'الورد اليومي'),
            Tab(text: 'الحفظ والتسميع'),
            Tab(text: 'خطط الختم'),
          ],
        ),
      ),
      body: Column(
        children: [
          // بطاقة إحصائيات علوية
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF132033),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('عدد الختمات', _khatamCount.toString(), Icons.emoji_events, const Color(0xFFB8922A)),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                _buildStatCard('الهدف اليومي', '$_dailyGoal صفحة', Icons.flag, Colors.green),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                _buildStatCard('تم اليوم', '$_dailyRead صفحة', Icons.check_circle, Colors.blue),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWirdTab(),
                _buildHifzTab(),
                _buildPlansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: GoogleFonts.amiri(fontSize: 12, color: Colors.white54)),
      ],
    );
  }

  Widget _buildWirdTab() {
    double progress = _dailyGoal > 0 ? (_dailyRead / _dailyGoal).clamp(0.0, 1.0) : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1565A8), Color(0xFF2180CC)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF1565A8).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB8922A)),
                      ),
                    ),
                    Column(
                      children: [
                        Text('$_dailyRead / $_dailyGoal', style: GoogleFonts.amiri(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('صفحة', style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.white, size: 40),
                      onPressed: _decrementRead,
                    ),
                    const SizedBox(width: 30),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFFB8922A), size: 50),
                      onPressed: _incrementRead,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF132033),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFB8922A)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اضغط على (+) بعد الانتهاء من قراءة كل صفحة. عند الوصول للهدف، سيظهر لك خيار تسجيل ختمة جديدة.',
                    style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHifzTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: QuranTrackerData.surahs.length,
      itemBuilder: (context, index) {
        final surah = QuranTrackerData.surahs[index];
        final key = 'surah_${surah.number}';
        final progress = _hifzProgress[key] ?? {'memorized': false, 'tested': false};
        final isMemorized = progress['memorized'] ?? false;
        final isTested = progress['tested'] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF132033),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTested ? Colors.green.withOpacity(0.5) : (isMemorized ? const Color(0xFFB8922A).withOpacity(0.5) : Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8922A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(surah.number.toString(), style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surah.name, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${surah.ayahCount} آية', style: GoogleFonts.amiri(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildHifzButton('حفظت', isMemorized, Colors.blue, () => _toggleHifzStatus(key, 'memorized')),
                  const SizedBox(height: 8),
                  _buildHifzButton('سُمّعت', isTested, Colors.green, () => _toggleHifzStatus(key, 'tested')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHifzButton(String text, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) const Icon(Icons.check, size: 14, color: Colors.white),
            if (isActive) const SizedBox(width: 4),
            Text(text, style: GoogleFonts.amiri(fontSize: 12, color: isActive ? Colors.white : color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlansTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: QuranTrackerData.plans.length,
      itemBuilder: (context, index) {
        final plan = QuranTrackerData.plans[index];
        final isSelected = _dailyGoal == plan.pagesPerDay;

        return GestureDetector(
          onTap: () => _setPlan(plan),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected ? [const Color(0xFFB8922A), const Color(0xFF8B6914)] : [const Color(0xFF132033), const Color(0xFF1E3A5F)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.1), width: 2),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFB8922A).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, color: isSelected ? Colors.white : const Color(0xFFB8922A), size: 32),
                const SizedBox(height: 12),
                Text(plan.name, style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('${plan.pagesPerDay} صفحات / يوم', style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                Text(plan.description, style: GoogleFonts.amiri(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center, maxLines: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
