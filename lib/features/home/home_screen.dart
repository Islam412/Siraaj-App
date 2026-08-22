import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers/settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;
  String _nextPrayerName = 'الظهر';
  String _nextPrayerTime = '12:30';
  String _hijriDate = '';

  @override
  void initState() {
    super.initState();
    _updateHijriDate();
    _startCountdown();
  }

  void _updateHijriDate() {
    final now = DateTime.now();
    _hijriDate = DateFormat('dd MMMM yyyy', 'ar').format(now);
  }

  void _startCountdown() {
    final now = DateTime.now();
    final nextPrayer = DateTime(now.year, now.month, now.day, 12, 30);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      final remaining = nextPrayer.difference(currentTime);
      
      if (mounted) {
        setState(() {
          _timeRemaining = remaining > Duration.zero ? remaining : Duration.zero;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // حساب حجم الأيقونة بناءً على عرض الشاشة
  double _getIconSize(double screenWidth) {
    if (screenWidth < 400) return 64;      // شاشات صغيرة جداً
    if (screenWidth < 600) return 72;      // موبايل
    if (screenWidth < 900) return 120;      // تابلت صغير
    if (screenWidth < 1200) return 96;     // تابلت كبير
    return 120;                              // ديسكتوب
  }

  // حساب عدد الأعمدة بناءً على عرض الشاشة
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 400) return 2;       // موبايل صغير
    if (screenWidth < 600) return 2;       // موبايل
    if (screenWidth < 900) return 3;       // تابلت
    if (screenWidth < 1200) return 4;      // تابلت كبير
    return 5;                               // ديسكتوب
  }

  // حساب نسبة البطاقة
  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 0.85;     // موبايل
    if (screenWidth < 900) return 0.95;     // تابلت
    return 1.0;                             // ديسكتوب
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siraaj',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0B1623) : const Color(0xFFF5F6F8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = _getIconSize(constraints.maxWidth);
            final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
            final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPrayerBanner(context, isDark),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/quran.png',
                        title: 'القرآن',
                        subtitle: 'Quran',
                        iconSize: iconSize,
                        onTap: () => context.push('/quran'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/qibla.png',
                        title: 'القبلة',
                        subtitle: 'Qibla',
                        iconSize: iconSize,
                        onTap: () => context.push('/qibla'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/prayer.png',
                        title: 'أوقات الصلاة',
                        subtitle: 'Prayer Times',
                        iconSize: iconSize,
                        onTap: () => context.push('/prayer'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/tasbih.png',
                        title: 'المسبحة',
                        subtitle: 'Tasbih',
                        iconSize: iconSize,
                        onTap: () => context.push('/tasbih'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/azkar.png',
                        title: 'أذكار اليوم',
                        subtitle: 'Daily Azkar',
                        iconSize: iconSize,
                        onTap: () => context.push('/azkar'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/hadith.png',
                        title: 'الأحاديث',
                        subtitle: 'Hadith',
                        iconSize: iconSize,
                        onTap: () => context.push('/hadith'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/radio.png',
                        title: 'الإذاعة',
                        subtitle: 'Radio',
                        iconSize: iconSize,
                        onTap: () => context.push('/radio'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/podcast.png',
                        title: 'البودكاست',
                        subtitle: 'Podcast',
                        iconSize: iconSize,
                        onTap: () => context.push('/podcast'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/lectures.png',
                        title: 'المحاضرات',
                        subtitle: 'Lectures',
                        iconSize: iconSize,
                        onTap: () => context.push('/lectures'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/books.png',
                        title: 'الكتب',
                        subtitle: 'Books',
                        iconSize: iconSize,
                        onTap: () => context.push('/books'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/asma_allah.png',
                        title: 'أسماء الله',
                        subtitle: '99 Names',
                        iconSize: iconSize,
                        onTap: () => context.push('/asma-allah'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/zakat.png',
                        title: 'الزكاة',
                        subtitle: 'Zakat',
                        iconSize: iconSize,
                        onTap: () => context.push('/zakat'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/calendar.png',
                        title: 'التقويم الهجري',
                        subtitle: 'Hijri Calendar',
                        iconSize: iconSize,
                        onTap: () => context.push('/calendar'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/stories.png',
                        title: 'قصص الأنبياء',
                        subtitle: 'Stories',
                        iconSize: iconSize,
                        onTap: () => context.push('/stories'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/duas.png',
                        title: 'أدعية مختارة',
                        subtitle: 'Duas',
                        iconSize: iconSize,
                        onTap: () => context.push('/duas'),
                      ),
                      _buildFeatureCard(
                        context,
                        iconPath: 'assets/icons/muhasaba.png',
                        title: 'محاسبة النفس',
                        subtitle: 'Muhasaba',
                        iconSize: iconSize,
                        onTap: () => context.push('/muhasaba'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1565A8),
            Color(0xFF2180CC),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565A8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.8), size: 16),
              const SizedBox(width: 8),
              Text(
                _hijriDate,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'الصلاة التالية',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_timeRemaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الساعة $_nextPrayerTime',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String iconPath,
    required String title,
    required String subtitle,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132033) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade100,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: iconSize,
                  height: iconSize,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      size: iconSize,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF2180CC) : const Color(0xFF1565A8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('الوضع الليلي'),
              subtitle: const Text('تفعيل الوضع الداكن'),
              value: isDark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
