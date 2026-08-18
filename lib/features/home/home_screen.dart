import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  final void Function(Locale)? onLocaleChanged;
  final void Function(ThemeMode)? onThemeChanged;

  const HomeScreen({
    super.key,
    this.onLocaleChanged,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('سراج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner - Next Prayer
            _buildTopBanner(context),
            const SizedBox(height: 24),
            
            // Main Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/quran.svg',
                  title: 'القرآن',
                  subtitle: 'Quran',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                  ),
                  onTap: () => context.push('/quran'),
                  delay: 0,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/qibla.svg',
                  title: 'القبلة',
                  subtitle: 'Qibla',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565A8)],
                  ),
                  onTap: () => context.push('/qibla'),
                  delay: 100,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/prayer.svg',
                  title: 'أوقات الصلاة',
                  subtitle: 'Prayer Times',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB8922A), Color(0xFFD4AC4E)],
                  ),
                  onTap: () => context.push('/prayer'),
                  delay: 200,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/muhasaba.svg',
                  title: 'محاسبة النفس',
                  subtitle: 'Muhasaba',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  onTap: () => context.push('/muhasaba'),
                  delay: 300,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/tasbih.svg',
                  title: 'المسبحة',
                  subtitle: 'Tasbih',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                  onTap: () => context.push('/tasbih'),
                  delay: 400,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/azkar.svg',
                  title: 'أذكار اليوم',
                  subtitle: 'Daily Azkar',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                  onTap: () => context.push('/azkar'),
                  delay: 500,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/hadith.svg',
                  title: 'الأحاديث',
                  subtitle: 'Hadith',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                  ),
                  onTap: () => context.push('/hadith'),
                  delay: 600,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/radio.svg',
                  title: 'الإذاعة',
                  subtitle: 'Radio',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
                  ),
                  onTap: () => context.push('/radio'),
                  delay: 700,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/podcast.svg',
                  title: 'البودكاست',
                  subtitle: 'Podcast',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  onTap: () => context.push('/podcast'),
                  delay: 800,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/lectures.svg',
                  title: 'المحاضرات',
                  subtitle: 'Lectures',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)],
                  ),
                  onTap: () => context.push('/lectures'),
                  delay: 900,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/books.svg',
                  title: 'الكتب',
                  subtitle: 'Books',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B6914), Color(0xFFB8922A)],
                  ),
                  onTap: () => context.push('/books'),
                  delay: 1000,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/asma_allah.svg',
                  title: 'أسماء الله',
                  subtitle: '99 Names',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  ),
                  onTap: () => context.push('/asma-allah'),
                  delay: 1100,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/zakat.svg',
                  title: 'حاسبة الزكاة',
                  subtitle: 'Zakat',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  onTap: () => context.push('/zakat'),
                  delay: 1200,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/calendar.svg',
                  title: 'التقويم الهجري',
                  subtitle: 'Hijri Calendar',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF97316), Color(0xFFFB923C)],
                  ),
                  onTap: () => context.push('/calendar'),
                  delay: 1300,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/stories.svg',
                  title: 'قصص الأنبياء',
                  subtitle: 'Stories',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                  onTap: () => context.push('/stories'),
                  delay: 1400,
                ),
                _buildFeatureCard(
                  context,
                  iconPath: 'assets/icons/duas.svg',
                  title: 'أدعية مختارة',
                  subtitle: 'Duas',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  onTap: () => context.push('/duas'),
                  delay: 1500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565A8).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'الصلاة التالية',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'الظهر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '01:23:45',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String iconPath,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: gradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay)).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'سراج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رفيقك الإسلامي اليومي',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              _showSettings(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('عن التطبيق'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('الوضع الليلي'),
              subtitle: const Text('تفعيل الوضع الداكن'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                onThemeChanged?.call(value ? ThemeMode.dark : ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('اللغة'),
              subtitle: const Text('العربية / English'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
