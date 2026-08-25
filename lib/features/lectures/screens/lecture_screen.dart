import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        setState(() { _isPlaying = true; _isLoading = false; });
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        setState(() { _isPlaying = false; _isLoading = false; });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() { _isPlaying = false; _position = Duration.zero; });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMedia(Lecture lecture) async {
    switch (lecture.type) {
      case MediaType.audio:
        await _playAudio(lecture);
        break;
      case MediaType.video:
      case MediaType.link:
        await _openLink(lecture.mediaUrl);
        break;
    }
  }

  Future<void> _playAudio(Lecture lecture) async {
    try {
      if (_currentLecture?.id == lecture.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        setState(() {
          _currentLecture = lecture;
          _isLoading = true;
          _isPlaying = false;
        });
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(lecture.mediaUrl));
      }
    } catch (e) {
      setState(() { _isPlaying = false; _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('عذراً، الصوت غير متاح حالياً'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح هذا الرابط'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '\${twoDigits(duration.inHours)}:\${twoDigits(duration.inMinutes.remainder(60))}:\${twoDigits(duration.inSeconds.remainder(60))}';
    }
    return '\${twoDigits(duration.inMinutes)}:\${twoDigits(duration.inSeconds.remainder(60))}';
  }

  List<Lecture> _getFilteredLectures() {
    return LectureData.getLecturesByCategory(_selectedCategory);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'تزكية': return const Color(0xFF4CAF50);
      case 'توحيد': return const Color(0xFF2196F3);
      case 'صلاة': return const Color(0xFF9C27B0);
      case 'عقيدة': return const Color(0xFFFF9800);
      case 'حديث': return const Color(0xFF795548);
      case 'قرآن': return const Color(0xFF009688);
      case 'تفسير': return const Color(0xFF3F51B5);
      case 'فقه': return const Color(0xFF607D8B);
      case 'تلاوات': return const Color(0xFFB8922A);
      default: return const Color(0xFFB8922A);
    }
  }

  IconData _getTypeIcon(MediaType type) {
    switch (type) {
      case MediaType.audio: return Icons.audiotrack;
      case MediaType.video: return Icons.videocam;
      case MediaType.link: return Icons.link;
    }
  }

  String _getTypeText(MediaType type) {
    switch (type) {
      case MediaType.audio: return 'صوت';
      case MediaType.video: return 'فيديو';
      case MediaType.link: return 'رابط';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...LectureData.getCategories()];
    final lectures = _getFilteredLectures();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A5F),
        elevation: 1,
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
          // فلتر التصنيفات - محسّن
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFB8922A) : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFB8922A) : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFB8922A).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.amiri(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // قائمة المحاضرات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: lectures.length,
                itemBuilder: (context, index) {
                  final lecture = lectures[index];
                  return _buildLectureCard(lecture);
                },
              ),
            ),
          ),
          if (_currentLecture != null && _currentLecture!.type == MediaType.audio) _buildPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildLectureCard(Lecture lecture) {
    final categoryColor = _getCategoryColor(lecture.category);
    final isCurrent = _currentLecture?.id == lecture.id;
    final isPlaying = isCurrent && _isPlaying;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFFB8922A) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: lecture.imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: Icon(_getTypeIcon(lecture.type), size: 50, color: Colors.grey),
                  ),
                ),
                // شارة النوع
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getTypeIcon(lecture.type), size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeText(lecture.type),
                          style: GoogleFonts.amiri(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                // زر التشغيل
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.green : const Color(0xFFB8922A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lecture.title,
                  style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFB8922A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lecture.speaker,
                        style: GoogleFonts.amiri(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _playMedia(lecture),
                    icon: Icon(_getTypeIcon(lecture.type), size: 18),
                    label: Text(
                      isPlaying ? 'إيقاف' : (lecture.type == MediaType.audio ? 'استماع' : 'فتح'),
                      style: GoogleFonts.amiri(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lecture.type == MediaType.audio
                          ? (isPlaying ? Colors.green : const Color(0xFF1565A8))
                          : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1565A8), Color(0xFF2180CC)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_isPlaying ? Icons.volume_up : Icons.audiotrack, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_currentLecture!.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Amiri'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(_currentLecture!.speaker, style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Amiri')),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Color(0xFFB8922A), strokeWidth: 3))
              else
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 50, color: _isPlaying ? Colors.green : const Color(0xFFB8922A)),
                  onPressed: () => _playMedia(_currentLecture!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(_formatDuration(_position), style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Amiri')),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                  activeColor: const Color(0xFFB8922A),
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
                ),
              ),
              Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Amiri')),
            ],
          ),
        ],
      ),
    );
  }
}
