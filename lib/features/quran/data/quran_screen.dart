import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import '../quran/services/quran_api_service.dart';
import '../quran/data/reciters_data.dart';
import '../quran/data/qiraat_data.dart';
import '../quran/data/tafsir_data.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final QuranApiService _apiService = QuranApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _selectedReciter = 0;
  int _selectedQiraat = 0;
  int _selectedTafsir = 0;
  int _fontSize = 24;
  bool _showTafsir = false;
  bool _isPlaying = false;
  bool _twoPageView = true;
  
  List<dynamic> _surahs = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }
  
  Future<void> _loadSurahs() async {
    try {
      final data = await _apiService.getSurahList();
      setState(() {
        _surahs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحميل القرآن: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _showBookmarks(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط اختيار القارئ والقراءة
                _buildReciterBar(),
                const Divider(),
                // قائمة السور
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _surahs.length,
                    itemBuilder: (context, index) {
                      final surah = _surahs[index];
                      return _buildSurahCard(surah, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReciterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedReciter,
                  decoration: const InputDecoration(
                    labelText: 'القارئ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: RecitersData.reciters.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReciter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedQiraat,
                  decoration: const InputDecoration(
                    labelText: 'القراءة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                  items: QiraatData.qiraat.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedQiraat = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(dynamic surah, int index) {
    return Card(
      child: InkWell(
        onTap: () => _openSurah(surah),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${surah['number']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${surah['numberOfAyahs']} آية - ${surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
  }

  void _openSurah(dynamic surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MushafScreen(
          surah: surah,
          reciter: RecitersData.reciters[_selectedReciter],
          qiraat: QiraatData.qiraat[_selectedQiraat],
          tafsir: TafsirData.books[_selectedTafsir],
          fontSize: _fontSize,
        ),
      ),
    );
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('لا توجد سور محفوظة'),
          ],
        ),
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
              'إعدادات القراءة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('حجم الخط: '),
                Expanded(
                  child: Slider(
                    value: _fontSize.toDouble(),
                    min: 16,
                    max: 32,
                    divisions: 8,
                    label: '$_fontSize',
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value.toInt();
                      });
                    },
                  ),
                ),
                Text('$_fontSize'),
              ],
            ),
            SwitchListTile(
              title: const Text('عرض صفحتين'),
              value: _twoPageView,
              onChanged: (value) {
                setState(() {
                  _twoPageView = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// شاشة المصحف
class MushafScreen extends StatefulWidget {
  final dynamic surah;
  final Reciter reciter;
  final Qiraah qiraat;
  final TafsirBook tafsir;
  final int fontSize;

  const MushafScreen({
    super.key,
    required this.surah,
    required this.reciter,
    required this.qiraat,
    required this.tafsir,
    required this.fontSize,
  });

  @override
  State<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends State<MushafScreen> {
  final QuranApiService _apiService = QuranApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<dynamic> _ayahs = [];
  bool _isLoading = true;
  int? _currentPlayingAyah;
  bool _isPlaying = false;
  bool _showTafsirPanel = false;
  dynamic _selectedTafsirAyah;

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    try {
      final data = await _apiService.getSurah(widget.surah['number']);
      setState(() {
        _ayahs = data['ayahs'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah['name']),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAudio,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _bookmarkSurah(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط المعلومات
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'القارئ: ${widget.reciter.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isPlaying)
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _stopAudio,
                        ),
                    ],
                  ),
                ),
                // المصحف
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildMushafPages(),
                      ),
                      if (_showTafsirPanel)
                        Expanded(
                          child: _buildTafsirPanel(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showTafsirPanel = !_showTafsirPanel;
          });
        },
        child: Icon(_showTafsirPanel ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }

  Widget _buildMushafPages() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // رأس السورة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ),
              child: Column(
                children: [
                  Text(
                    'سورة ${widget.surah['name']}',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.surah['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'} • ${widget.surah['numberOfAyahs']} آية',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Amiri',
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // البسملة (إلا في سورة التوبة)
            if (widget.surah['number'] != 9)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: widget.fontSize.toDouble() + 4,
                    fontFamily: 'Amiri',
                    color: Theme.of(context).colorScheme.primary,
                    height: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            // الآيات
            ..._ayahs.map((ayah) => _buildAyahCard(ayah)),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(dynamic ayah) {
    final isPlaying = _currentPlayingAyah == ayah['number'];
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isPlaying 
          ? Colors.green.withOpacity(0.1)
          : null,
      child: InkWell(
        onTap: () => _playAyah(ayah),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // نص الآية
              Text(
                ayah['text'],
                style: TextStyle(
                  fontSize: widget.fontSize.toDouble(),
                  fontFamily: 'Amiri',
                  height: 2.8,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              // رقم الآية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary),
                    ),
                    child: Center(
                      child: Text(
                        '${ayah['numberInSurah']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_circle_outline),
                        onPressed: () => _playAyah(ayah),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showTafsirForAyah(ayah),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTafsirPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.tafsir.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showTafsirPanel = false;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedTafsirAyah != null
                ? FutureBuilder(
                    future: _getTafsirForAyah(_selectedTafsirAyah),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('فشل في تحميل التفسير'));
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          snapshot.data ?? 'لا يوجد تفسير متاح',
                          style: TextStyle(
                            fontSize: 18,
                            height: 2.0,
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  )
                : const Center(child: Text('اضغط على آية لعرض تفسيرها')),
          ),
        ],
      ),
    );
  }

  Future<String> _getTafsirForAyah(dynamic ayah) async {
    // هنا نستخدم API للتفسير
    // للتبسيط، سنرجع نص توضيحي
    return 'تفسير الآية ${ayah['numberInSurah']} من سورة ${widget.surah['name']}\n\nهذا نص توضيحي للتفسير. في التطبيق الكامل، سيتم جلب التفسير من API.';
  }

  Future<void> _playAyah(dynamic ayah) async {
    try {
      // بناء رابط الصوت
      final audioUrl = 'https://cdn.islamic.network/quran/audio/128/${widget.reciter.id}/${ayah['number']}.mp3';
      
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      
      setState(() {
        _currentPlayingAyah = ayah['number'];
        _isPlaying = true;
      });
      
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تشغيل الآية: $e')),
      );
    }
  }

  void _toggleAudio() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else if (_ayahs.isNotEmpty) {
      _playAyah(_ayahs.first);
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentPlayingAyah = null;
    });
  }

  void _showTafsirForAyah(dynamic ayah) {
    setState(() {
      _selectedTafsirAyah = ayah;
      _showTafsirPanel = true;
    });
  }

  void _bookmarkSurah() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة السورة للمفضلة')),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}