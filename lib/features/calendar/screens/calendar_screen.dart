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

  // المناسبات الإسلامية
  final Map<String, Map<String, dynamic>> _islamicEvents = {
    '1-1': {'name': 'رأس السنة الهجرية', 'icon': Icons.celebration},
    '10-1': {'name': 'يوم عاشوراء', 'icon': Icons.water_drop},
    '12-3': {'name': 'المولد النبوي', 'icon': Icons.star},
    '27-7': {'name': 'الإسراء والمعراج', 'icon': Icons.nights_stay},
    '15-8': {'name': 'نصف شعبان', 'icon': Icons.brightness_3},
    '1-9': {'name': 'بداية رمضان', 'icon': Icons.bedtime},
    '27-9': {'name': 'ليلة القدر', 'icon': Icons.auto_awesome},
    '1-10': {'name': 'عيد الفطر المبارك', 'icon': Icons.card_giftcard},
    '2-10': {'name': 'ثاني أيام العيد', 'icon': Icons.card_giftcard},
    '3-10': {'name': 'ثالث أيام العيد', 'icon': Icons.card_giftcard},
    '9-12': {'name': 'يوم عرفة', 'icon': Icons.terrain},
    '10-12': {'name': 'عيد الأضحى المبارك', 'icon': Icons.local_dining},
    '11-12': {'name': 'ثاني أيام الأضحى', 'icon': Icons.local_dining},
    '12-12': {'name': 'ثالث أيام الأضحى', 'icon': Icons.local_dining},
    '13-12': {'name': 'رابع أيام الأضحى', 'icon': Icons.local_dining},
  };

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    _currentDate = DateTime.now();
    _currentHijriDate = HijriCalendar.now();
  }

  List<Map<String, dynamic>> _getMonthDays() {
    List<Map<String, dynamic>> days = [];
    int year = _currentDate.year;
    int month = _currentDate.month;
    
    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month + 1, 0);
    
    int startWeekday = firstDay.weekday;
    int adjustedStart = (startWeekday + 1) % 7;

    for (int i = 0; i < adjustedStart; i++) {
      days.add({'gregorian': '', 'hijri': '', 'isToday': false, 'isEmpty': true, 'event': null});
    }

    for (int i = 1; i <= lastDay.day; i++) {
      DateTime currentDay = DateTime(year, month, i);
      HijriCalendar hDate = HijriCalendar.fromDate(currentDay);
      
      bool isToday = currentDay.day == DateTime.now().day && 
                     currentDay.month == DateTime.now().month && 
                     currentDay.year == DateTime.now().year;

      // التحقق من وجود مناسبة
      String eventKey = '${hDate.hDay}-${hDate.hMonth}';
      var eventData = _islamicEvents[eventKey];

      days.add({
        'gregorian': i.toString(),
        'hijri': hDate.hDay.toString(),
        'hijriMonth': hDate.hMonth,
        'hijriDay': hDate.hDay,
        'isToday': isToday,
        'isEmpty': false,
        'event': eventData,
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
            _buildTodayCard(),
            const SizedBox(height: 24),

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
            
            _buildUpcomingEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    // التحقق من مناسبة اليوم
    String todayKey = '${_currentHijriDate.hDay}-${_currentHijriDate.hMonth}';
    var todayEvent = _islamicEvents[todayKey];

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
          if (todayEvent != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(todayEvent['icon'] as IconData, color: const Color(0xFFB8922A), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    todayEvent['name'] as String,
                    style: GoogleFonts.amiri(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
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
    final event = dayData['event'] as Map<String, dynamic>?;

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
          // المناسبة (إن وجدت) - أيقونة صغيرة
          if (event != null)
            Icon(
              event['icon'] as IconData,
              color: isToday ? Colors.white : const Color(0xFFE91E63),
              size: 14,
            )
          else
            const SizedBox(height: 14),
          
          const SizedBox(height: 2),
          
          // اليوم الميلادي
          Text(
            gregorian,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.white,
            ),
          ),
          
          const SizedBox(height: 2),
          
          // اليوم الهجري
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
    // حساب المناسبات القادمة في الشهر الحالي
    List<Map<String, dynamic>> upcomingEvents = [];
    final monthDays = _getMonthDays();
    
    for (var day in monthDays) {
      if (day['event'] != null) {
        upcomingEvents.add({
          'name': day['event']['name'],
          'date': '${day['hijri']} ${_hijriMonths[_currentHijriDate.hMonth - 1]}',
          'icon': day['event']['icon'],
        });
      }
    }

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
                'مناسبات هذا الشهر',
                style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (upcomingEvents.isEmpty)
            Text(
              'لا توجد مناسبات هذا الشهر',
              style: GoogleFonts.amiri(fontSize: 14, color: Colors.white54),
            )
          else
            ...upcomingEvents.map((event) => _buildEventItem(event['name'], event['date'], event['icon'])),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB8922A), size: 18),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.amiri(fontSize: 15, color: Colors.white)),
            ],
          ),
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
