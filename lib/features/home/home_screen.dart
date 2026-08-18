import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
            // Top Banner
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
                  icon: Icons.menu_book,
                  title: 'القرآن',
                  subtitle: 'Quran',
                  onTap: () => context.push('/quran'),
                  delay: 0,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.explore,
                  title: 'القبلة',
                  subtitle: 'Qibla',
                  onTap: () => context.push('/qibla'),
                  delay: 100,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.access_time,
                  title: 'أوقات الصلاة',
                  subtitle: 'Prayer Times',
                  onTap: () => context.push('/prayer'),
                  delay: 200,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'محاسبة النفس',
                  subtitle: 'Muhasaba',
                  onTap: () => context.push('/muhasaba'),
                  delay: 300,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.counter_1,
                  title: 'المسبحة',
                  subtitle: 'Tasbih',
                  onTap: () => context.push('/tasbih'),
                  delay: 400,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.alarm,
                  title: 'أذكار اليوم',
                  subtitle: 'Daily Azkar',
                  onTap: () => context.push('/azkar'),
                  delay: 500,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.shield,
                  title: 'حصون المسلم',
                  subtitle: 'Hisn Al-Muslim',
                  onTap: () => context.push('/azkar'), // Same screen, different filter
                  delay: 600,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.book,
                  title: 'الأحاديث',
                  subtitle: 'Hadith',
                  onTap: () => context.push('/hadith'),
                  delay: 700,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.podcasts,
                  title: 'البودكاست',
                  subtitle: 'Podcast',
                  onTap: () => context.push('/podcast'),
                  delay: 800,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.video_library,
                  title: 'المحاضرات',
                  subtitle: 'Lectures',
                  onTap: () => context.push('/lectures'),
                  delay: 900,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.library_books,
                  title: 'الكتب',
                  subtitle: 'Books',
                  onTap: () => context.push('/books'),
                  delay: 1000,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.radio,
                  title: 'الإذاعة',
                  subtitle: 'Radio',
                  onTap: () => context.push('/radio'),
                  delay: 1100,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.contact_mail,
                  title: 'تواصل معنا',
                  subtitle: 'Contact',
                  onTap: () => context.push('/contact'),
                  delay: 1200,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.emoji_events,
                  title: 'إنجاز اليوم',
                  subtitle: 'Today\'s Achievement',
                  onTap: () => context.push('/muhasaba'),
                  delay: 1300,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الصلاة التالية',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'الظهر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '01:23:45',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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
                // Toggle language
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}