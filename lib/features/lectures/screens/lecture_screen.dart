import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../data/lecture_data.dart';

class LectureScreen extends StatefulWidget {
  const LectureScreen({super.key});

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Lecture? _currentLecture;
  bool _isPlaying = false;
  bool _isLoading = false;
  String _selectedCategory = 'الكل';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playLecture(Lecture lecture) async {
    try {
      if (_currentLecture?.id == lecture.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _currentLecture = lecture;
          _isLoading = true;
          _isPlaying = false;
        });

        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(lecture.audioUrl));
      }
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، الصوت غير متاح حالياً'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '\$hours:\$minutes:\$seconds';
    }
    return '\$minutes:\$seconds';
  }

  List<Lecture> _getFilteredLectures() {
    return LectureData.getLecturesByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...LectureData.getCategories()];
    final lectures = _getFilteredLectures();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'المحاضرات',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // فلتر التصنيفات
          Container(
            height: 60,
            color: const Color(0xFF132033),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: const Color(0xFF1E3A5F),
                    selectedColor: const Color(0xFFB8922A).withOpacity(0.3),
                    checkmarkColor: const Color(0xFFB8922A),
                    labelStyle: GoogleFonts.amiri(
                      color: isSelected ? const Color(0xFFB8922A) : Colors.white70,
                    ),
                  ),
                );
              },
            ),
          ),

          // قائمة المحاضرات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final isCurrentLecture = _currentLecture?.id == lecture.id;

                return _buildLectureCard(lecture, isCurrentLecture);
              },
            ),
          ),

          // مشغل الصوت السفلي
          if (_currentLecture != null)
            _buildPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildLectureCard(Lecture lecture, bool isCurrentLecture) {
    final isPlaying = isCurrentLecture && _isPlaying;
    final isLoading = isCurrentLecture && _isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentLecture
              ? const Color(0xFFB8922A)
              : Colors.white.withOpacity(0.1),
          width: isCurrentLecture ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentLecture
                ? const Color(0xFFB8922A).withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isCurrentLecture ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // الصورة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.volume_up : Icons.school,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lecture.category,
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.title,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCurrentLecture
                            ? const Color(0xFFB8922A)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.white54),
                        const SizedBox(width: 5),
                        Text(
                          lecture.speaker,
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.white54),
                        const SizedBox(width: 5),
                        Text(
                          lecture.duration,
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('yyyy/MM/dd').format(lecture.date),
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // الوصف وزر التشغيل
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.description,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _playLecture(lecture),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying
                          ? Colors.green
                          : const Color(0xFF1565A8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 24,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          isLoading
                              ? 'جاري التحميل...'
                              : (isPlaying ? 'إيقاف' : 'استماع'),
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isPlaying ? Icons.volume_up : Icons.school,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentLecture!.title,
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentLecture!.speaker,
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFFB8922A),
                    strokeWidth: 3,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 50,
                    color: _isPlaying ? Colors.green : const Color(0xFFB8922A),
                  ),
                  onPressed: () => _playLecture(_currentLecture!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // شريط التقدم
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.amiri(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  activeColor: const Color(0xFFB8922A),
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.amiri(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
