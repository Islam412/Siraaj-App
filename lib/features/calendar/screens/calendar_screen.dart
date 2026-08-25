import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  late HijriCalendar _currentHijriDate;

  final List<String> _hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];

  final List<String> _weekDays = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _currentDate = DateTime.now();
    _currentHijriDate = HijriCalendar.now();
  }

  // دالة للحصول على أيام الشهر الحالي مع تواريخها الهجرية والميلادية
  List<Map<String, dynamic>> _getMonthDays() {
    List<Map<String, dynamic>> days = [];
    int year = _currentDate.year;
    int month = _currentDate.month;
    
    // أول يوم في الشهر
    DateTime firstDay = DateTime(year, month, 1);
    // آخر يوم في الشهر
    DateTime lastDay = DateTime(year, month + 1, 0);
    
    // يوم الأسبوع لأول يوم (0 = الاثنين في Dart، نحتاج تعديله ليبدأ من السبت)
    int startWeekday = firstDay.weekday; 
    // تحويل يوم الأسبوع ليبدأ من السبت (6) إلى الجمعة (5)
    int adjustedStart = (startWeekday + 1) % 7; 

    // إضافة أيام فارغة في البداية
    for (int i = 0; i < adjustedStart; i++) {
      days.add({'gregorian': '', 'hijri': '', 'isToday': false, 'isEmpty': true});
    }

    // إضافة أيام الشهر
    for (int i = 1; i <= lastDay.day; i++) {
      DateTime currentDay = DateTime(year, month, i);
      HijriCalendar hDate = HijriCalendar.fromDate(currentDay);
      
      bool isToday = currentDay.day == DateTime.now().day && 
                     currentDay.month == DateTime.now().month && 
                     currentDay.year == DateTime.now().year;

      days.add({
        'gregorian': i.toString(),
        'hijri': hDate.hDay.toString(),
        'hijriMonth': hDate.hMonth,
        'isToday': isToday,
        'isEmpty': false,
      });
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final monthDays = _getMonthDays();
    final gregorianMonthName = DateFormat('MMMM yyyy', 'ar').format(_currentDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'التقويم',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة التاريخ الحالي (مزدوج)
            _buildTodayCard(),
            const SizedBox(height: 24),

            // رأس التقويم (الشهر والسنة)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                      _currentHijriDate = HijriCalendar.fromDate(_currentDate);
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      '${_hijriMonths[_currentHijriDate.hMonth - 1]} ${_currentHijriDate.hYear}هـ',
                      style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A)),
                    ),
                    Text(
                      gregorianMonthName,
                      style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                      _currentHijriDate = HijriCalendar.fromDate(_currentDate);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // أيام الأسبوع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekDays.map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.amiri(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),

            // شبكة الأيام
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: monthDays.length,
              itemBuilder: (context, index) {
                final dayData = monthDays[index];
                return _buildDayCell(dayData);
              },
            ),
            
            const SizedBox(height: 24),
            
            // مناسبات قادمة (ثابتة كمثال)
            _buildUpcomingEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // التاريخ الهجري (كبير)
          Text(
            '${_currentHijriDate.hDay} ${_hijriMonths[_currentHijriDate.hMonth - 1]} ${_currentHijriDate.hYear}هـ',
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          // التاريخ الميلادي (أصغر)
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'ar').format(_currentDate),
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(Map<String, dynamic> dayData) {
    if (dayData['isEmpty']) {
      return const SizedBox.shrink();
    }

    final isToday = dayData['isToday'] as bool;
    final gregorian = dayData['gregorian'] as String;
    final hijri = dayData['hijri'] as String;

    return Container(
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFB8922A) : const Color(0xFF132033),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? const Color(0xFFB8922A) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // اليوم الميلادي (كبير)
          Text(
            gregorian,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // اليوم الهجري (صغير ومميز)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isToday ? Colors.white.withOpacity(0.2) : const Color(0xFFB8922A).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hijri,
              style: GoogleFonts.amiri(
                fontSize: 11,
                color: isToday ? Colors.white : const Color(0xFFB8922A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, color: Color(0xFFB8922A), size: 20),
              const SizedBox(width: 8),
              Text(
                'مناسبات إسلامية قريبة',
                style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEventItem('الإسراء والمعراج', '27 رجب'),
          _buildEventItem('نصف شعبان', '15 شعبان'),
          _buildEventItem('بداية رمضان', '1 رمضان'),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.amiri(fontSize: 15, color: Colors.white)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFB8922A).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              style: GoogleFonts.amiri(fontSize: 13, color: const Color(0xFFB8922A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
