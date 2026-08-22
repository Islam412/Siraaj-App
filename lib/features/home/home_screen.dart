import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سراج'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F6F8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTopBanner(context),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/quran.png',
                    title: 'القرآن',
                    subtitle: 'Quran',
                    onTap: () => context.push('/quran'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/qibla.png',
                    title: 'القبلة',
                    subtitle: 'Qibla',
                    onTap: () => context.push('/qibla'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/prayer.png',
                    title: 'أوقات الصلاة',
                    subtitle: 'Prayer Times',
                    onTap: () => context.push('/prayer'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/tasbih.png',
                    title: 'المسبحة',
                    subtitle: 'Tasbih',
                    onTap: () => context.push('/tasbih'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/azkar.png',
                    title: 'أذكار اليوم',
                    subtitle: 'Daily Azkar',
                    onTap: () => context.push('/azkar'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/hadith.png',
                    title: 'الأحاديث',
                    subtitle: 'Hadith',
                    onTap: () => context.push('/hadith'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/radio.png',
                    title: 'الإذاعة',
                    subtitle: 'Radio',
                    onTap: () => context.push('/radio'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/podcast.png',
                    title: 'البودكاست',
                    subtitle: 'Podcast',
                    onTap: () => context.push('/podcast'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/lectures.png',
                    title: 'المحاضرات',
                    subtitle: 'Lectures',
                    onTap: () => context.push('/lectures'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/books.png',
                    title: 'الكتب',
                    subtitle: 'Books',
                    onTap: () => context.push('/books'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/asma_allah.png',
                    title: 'أسماء الله',
                    subtitle: '99 Names',
                    onTap: () => context.push('/asma-allah'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/zakat.png',
                    title: 'الزكاة',
                    subtitle: 'Zakat',
                    onTap: () => context.push('/zakat'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/calendar.png',
                    title: 'التقويم الهجري',
                    subtitle: 'Hijri Calendar',
                    onTap: () => context.push('/calendar'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/stories.png',
                    title: 'قصص الأنبياء',
                    subtitle: 'Stories',
                    onTap: () => context.push('/stories'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/duas.png',
                    title: 'أدعية مختارة',
                    subtitle: 'Duas',
                    onTap: () => context.push('/duas'),
                  ),
                  _buildFeatureCard(
                    context,
                    iconPath: 'assets/icons/muhasaba.png',
                    title: 'محاسبة النفس',
                    subtitle: 'Muhasaba',
                    onTap: () => context.push('/muhasaba'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'الظهر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'الصلاة التالية',
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
    required VoidCallback onTap,
  }) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565A8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentTheme = ref.watch(themeModeProvider);
          return Container(
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
                  value: currentTheme == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).state =
                        value ? ThemeMode.dark : ThemeMode.light;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}