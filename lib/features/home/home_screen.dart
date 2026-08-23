import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
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
  Position? _currentPosition;
  Map<String, DateTime>? _prayerTimes;

  @override
  void initState() {
    super.initState();
    _updateHijriDate();
    _initializePrayerTimes();
    _startCountdown();
  }

  void _updateHijriDate() {
    final now = DateTime.now();
    _hijriDate = DateFormat('dd MMMM yyyy', 'ar').format(now);
  }

  Future<void> _initializePrayerTimes() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          setState(() {
            _currentPosition = position;
          });

          await _calculatePrayerTimes();
        }
      }
    } catch (e) {
      // Use default location (Makkah)
      setState(() {
        _currentPosition = Position(
          latitude: 21.3891,
          longitude: 39.8579,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      });
      await _calculatePrayerTimes();
    }
  }

  Future<void> _calculatePrayerTimes() async {
    if (_currentPosition == null) return;

    try {
      final coordinates = Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final params = CalculationMethod.umm_al_qura.getParameters();
      final dateComponents = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

      setState(() {
        _prayerTimes = {
          'Fajr': prayerTimes.fajr,
          'Sunrise': prayerTimes.sunrise,
          'Dhuhr': prayerTimes.dhuhr,
          'Asr': prayerTimes.asr,
          'Maghrib': prayerTimes.maghrib,
          'Isha': prayerTimes.isha,
        };
        _updateNextPrayer();
      });
    } catch (e) {
      // Default times
      setState(() {
        _prayerTimes = {
          'Fajr': DateTime.now().copyWith(hour: 5, minute: 0),
          'Dhuhr': DateTime.now().copyWith(hour: 12, minute: 30),
          'Asr': DateTime.now().copyWith(hour: 15, minute: 45),
          'Maghrib': DateTime.now().copyWith(hour: 18, minute: 15),
          'Isha': DateTime.now().copyWith(hour: 19, minute: 45),
        };
        _updateNextPrayer();
      });
    }
  }

  void _updateNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final prayers = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final arabicNames = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    String nextPrayer = 'Fajr';
    for (var prayer in prayers) {
      if (_prayerTimes![prayer]!.isAfter(now)) {
        nextPrayer = prayer;
        break;
      }
    }

    final nextPrayerTime = _prayerTimes![nextPrayer]!;
    final remaining = nextPrayerTime.difference(now);

    setState(() {
      _nextPrayerName = arabicNames[nextPrayer]!;
      _nextPrayerTime = DateFormat('HH:mm').format(nextPrayerTime);
      _timeRemaining = remaining > Duration.zero ? remaining : Duration.zero;
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes != null) {
        _updateNextPrayer();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سراج',
          style: GoogleFonts.amiri(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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

  double _getIconSize(double screenWidth) {
    if (screenWidth < 400) return 64;
    if (screenWidth < 600) return 72;
    if (screenWidth < 900) return 80;
    if (screenWidth < 1200) return 96;
    return 120;
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 400) return 2;
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1200) return 4;
    return 5;
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 0.85;
    if (screenWidth < 900) return 0.95;
    return 1.0;
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
                style: GoogleFonts.amiri(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'الصلاة التالية',
            style: GoogleFonts.amiri(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayerName,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 40,
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
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'الساعة $_nextPrayerTime',
            style: GoogleFonts.amiri(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
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
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF2180CC) : const Color(0xFF1565A8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 12,
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
            Text(
              'الإعدادات',
              style: GoogleFonts.amiri(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                'الوضع الليلي',
                style: GoogleFonts.amiri(fontSize: 16),
              ),
              subtitle: Text(
                'تفعيل الوضع الداكن',
                style: GoogleFonts.amiri(fontSize: 14),
              ),
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
