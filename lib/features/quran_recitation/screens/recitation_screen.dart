import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentSurah = 1;
  int _currentAyah = 1;
  bool _isPlaying = false;
  String _selectedReciter = 'مشاري العفاسي';
  
  final List<String> _reciters = [
    'مشاري العفاسي',
    'عبد الرحمن السديس',
    'سعد الغامدي',
    'أحمد العجمي',
    'ماهر المعيقلي',
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAyah() async {
    try {
      // رابط تلاوة الآية (يمكنك استخدام API حقيقي)
      final url = 'https://server8.mp3quran.net/afs/001.mp3';
      
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(UrlSource(url));
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في التشغيل', style: GoogleFonts.amiri()),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            const Icon(Icons.record_voice_over, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'استماع وتسميع القرآن',
              style: GoogleFonts.amiri(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // اختيار القارئ
          _buildReciterSelector(),
          
          // عرض السورة والآية
          _buildSurahAyahDisplay(),
          
          // أزرار التحكم
          _buildControlButtons(),
          
          // قائمة السور
          Expanded(child: _buildSurahList()),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF132033),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر القارئ:',
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB8922A),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _selectedReciter,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E3A5F),
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.white,
            ),
            underline: Container(
              height: 2,
              color: const Color(0xFFB8922A),
            ),
            items: _reciters.map((String reciter) {
              return DropdownMenuItem<String>(
                value: reciter,
                child: Text(reciter),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedReciter = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSurahAyahDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'سورة الفاتحة',
            style: GoogleFonts.amiri(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton('السورة السابقة', Icons.skip_previous, () {}),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الآية $_currentAyah',
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildNavButton('الآية التالية', Icons.skip_next, () {
                setState(() => _currentAyah++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.amiri(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            'إعادة',
            Icons.replay,
            () {
              _audioPlayer.seek(Duration.zero);
            },
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: _playAyah,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
            label: Text(
              _isPlaying ? 'إيقاف' : 'تشغيل',
              style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8922A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            'تكرار',
            Icons.repeat,
            () {
              _audioPlayer.setReleaseMode(ReleaseMode.loop);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF132033),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB8922A)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFB8922A), size: 24),
            const SizedBox(height: 4),
            Text(
              text,
              style: GoogleFonts.amiri(
                fontSize: 12,
                color: const Color(0xFFB8922A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final surahs = [
      {'name': 'الفاتحة', 'ayahs': 7},
      {'name': 'البقرة', 'ayahs': 286},
      {'name': 'آل عمران', 'ayahs': 200},
      {'name': 'النساء', 'ayahs': 176},
      {'name': 'المائدة', 'ayahs': 120},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF132033),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سور القرآن:',
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB8922A),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                final surah = surahs[index];
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8922A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB8922A),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    surah['name'] as String,
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${surah['ayahs']} آية',
                    style: GoogleFonts.amiri(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle, color: Color(0xFFB8922A)),
                    onPressed: () {
                      setState(() {
                        _currentSurah = index + 1;
                        _currentAyah = 1;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _currentSurah = index + 1;
                      _currentAyah = 1;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
