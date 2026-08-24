import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import '../data/podcast_data.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PodcastEpisode? _currentEpisode;
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

  Future<void> _playEpisode(PodcastEpisode episode) async {
    try {
      if (_currentEpisode?.id == episode.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _currentEpisode = episode;
          _isLoading = true;
          _isPlaying = false;
        });

        await _audioPlayer.stop();
        // ملاحظة: الروابط هنا تجريبية، يجب استبدالها بروابط حقيقية
        await _audioPlayer.play(UrlSource(episode.audioUrl));
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
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  List<PodcastEpisode> _getFilteredEpisodes() {
    return PodcastData.getEpisodesByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...PodcastData.getCategories()];
    final episodes = _getFilteredEpisodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.podcasts, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'البودكاست',
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

          // قائمة الحلقات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final isCurrentEpisode = _currentEpisode?.id == episode.id;

                return _buildEpisodeCard(episode, isCurrentEpisode);
              },
            ),
          ),

          // مشغل الصوت السفلي
          if (_currentEpisode != null)
            _buildPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(PodcastEpisode episode, bool isCurrentEpisode) {
    final isPlaying = isCurrentEpisode && _isPlaying;
    final isLoading = isCurrentEpisode && _isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentEpisode
              ? const Color(0xFFB8922A)
              : Colors.white.withOpacity(0.1),
          width: isCurrentEpisode ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentEpisode
                ? const Color(0xFFB8922A).withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isCurrentEpisode ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة والمعلومات
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
                      isPlaying ? Icons.volume_up : Icons.podcasts,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      episode.category,
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
                      episode.title,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCurrentEpisode
                            ? const Color(0xFFB8922A)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          episode.speaker,
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
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          episode.duration,
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('yyyy/MM/dd').format(episode.date),
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
          // الوصف
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.description,
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
                    onPressed: isLoading ? null : () => _playEpisode(episode),
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
                  _isPlaying ? Icons.volume_up : Icons.podcasts,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentEpisode!.title,
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentEpisode!.speaker,
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
                  onPressed: () => _playEpisode(_currentEpisode!),
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
