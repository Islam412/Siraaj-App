import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _selectedReciter = 0;
  int _selectedSurah = 0;
  bool _isPlaying = false;

  final List<Map<String, String>> _reciters = [
    {'name': 'مشاري العفاسي', 'id': 'alafasy'},
    {'name': 'عبد الرحمن السديس', 'id': 'sudais'},
    {'name': 'ماهر المعيقلي', 'id': 'muaiqly'},
    {'name': 'سعد الغامدي', 'id': 'ghamdi'},
    {'name': 'أحمد العجمي', 'id': 'ajamy'},
    {'name': 'ياسر الدوسري', 'id': 'dossari'},
    {'name': 'عبد الباسط عبد الصمد', 'id': 'abdulbasit'},
    {'name': 'محمود خليل الحصري', 'id': 'husary'},
  ];

  final List<Map<String, dynamic>> _surahs = [
    {'number': 1, 'name': 'الفاتحة', 'englishName': 'Al-Fatiha', 'verses': 7, 'type': 'Meccan'},
    {'number': 2, 'name': 'البقرة', 'englishName': 'Al-Baqara', 'verses': 286, 'type': 'Medinan'},
    {'number': 3, 'name': 'آل عمران', 'englishName': 'Ali Imran', 'verses': 200, 'type': 'Medinan'},
    {'number': 4, 'name': 'النساء', 'englishName': 'An-Nisa', 'verses': 176, 'type': 'Medinan'},
    {'number': 5, 'name': 'المائدة', 'englishName': 'Al-Maidah', 'verses': 120, 'type': 'Medinan'},
    {'number': 6, 'name': 'الأنعام', 'englishName': 'Al-Anam', 'verses': 165, 'type': 'Meccan'},
    {'number': 7, 'name': 'الأعراف', 'englishName': 'Al-Araf', 'verses': 206, 'type': 'Meccan'},
    {'number': 8, 'name': 'الأنفال', 'englishName': 'Al-Anfal', 'verses': 75, 'type': 'Medinan'},
    {'number': 9, 'name': 'التوبة', 'englishName': 'At-Tawbah', 'verses': 129, 'type': 'Medinan'},
    {'number': 10, 'name': 'يونس', 'englishName': 'Yunus', 'verses': 109, 'type': 'Meccan'},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarks(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Reciter Selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'اختر القارئ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _reciters.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedReciter == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReciter = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                                  )
                                : null,
                            color: isSelected ? null : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : theme.colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 18,
                                color: isSelected ? Colors.white : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _reciters[index]['name']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Surah List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _surahs.length,
              itemBuilder: (context, index) {
                final surah = _surahs[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${surah['number']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      surah['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${surah['englishName']} • ${surah['verses']} آية • ${surah['type'] == 'Meccan' ? 'مكية' : 'مدنية'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying && _selectedSurah == index
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () => _togglePlay(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_border),
                          onPressed: () => _bookmarkSurah(index),
                        ),
                      ],
                    ),
                    onTap: () => _openSurah(index),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50)).slideX(begin: -0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlay(int index) {
    setState(() {
      if (_isPlaying && _selectedSurah == index) {
        _audioPlayer.pause();
        _isPlaying = false;
      } else {
        _selectedSurah = index;
        _isPlaying = true;
        // Here you would load and play the audio
        // _audioPlayer.setUrl('https://...');
        // _audioPlayer.play();
      }
    });
  }

  void _openSurah(int index) {
    // Navigate to surah reading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahReadingScreen(
          surah: _surahs[index],
          reciter: _reciters[_selectedReciter],
        ),
      ),
    );
  }

  void _bookmarkSurah(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ ${_surahs[index]['name']} في المفضلة'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: SurahSearchDelegate(_surahs));
  }

  void _showBookmarks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'المفضلة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('لا توجد سور محفوظة'),
          ],
        ),
      ),
    );
  }
}

class SurahSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> surahs;

  SurahSearchDelegate(this.surahs);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = surahs.where((surah) {
      return surah['name']!.contains(query) ||
             surah['englishName']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final surah = results[index];
        return ListTile(
          title: Text(surah['name']!),
          subtitle: Text(surah['englishName']!),
          onTap: () => close(context, surah),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = surahs.where((surah) {
      return surah['name']!.contains(query) ||
             surah['englishName']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final surah = suggestions[index];
        return ListTile(
          title: Text(surah['name']!),
          subtitle: Text(surah['englishName']!),
          onTap: () => close(context, surah),
        );
      },
    );
  }
}

class SurahReadingScreen extends StatelessWidget {
  final Map<String, dynamic> surah;
  final Map<String, String> reciter;

  const SurahReadingScreen({
    super.key,
    required this.surah,
    required this.reciter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surah['name']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showReadingSettings(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'سورة ${surah['name']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'القارئ: ${reciter['name']}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'سيتم عرض نص القرآن هنا',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'حجم الخط',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: 20,
              min: 14,
              max: 32,
              divisions: 9,
              label: '20',
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إعدادات القراءة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('التمرير التلقائي'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('وضع القراءة الليلية'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}
