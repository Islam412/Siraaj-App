import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/radio_data.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;
  bool _isLoading = false;
  String _selectedCountry = 'الكل';
  Map<String, bool> _stationAvailability = {};

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
          if (_currentStation != null) {
            _stationAvailability[_currentStation!.id] = true;
          }
        });
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playStation(RadioStation station) async {
    try {
      if (_currentStation?.id == station.id && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        setState(() {
          _currentStation = station;
          _isLoading = true;
          _isPlaying = false;
        });
        
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(station.streamUrl));
        
        // محاولة تشغيل الرابط البديل إذا فشل الأول
        if (station.alternativeUrl != null && !_isPlaying) {
          await Future.delayed(const Duration(seconds: 5));
          if (!_isPlaying) {
            await _audioPlayer.play(UrlSource(station.alternativeUrl!));
          }
        }
      }
    } catch (e) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
        if (_currentStation != null) {
          _stationAvailability[_currentStation!.id] = false;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، البث غير متاح حالياً لهذه المحطة'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<RadioStation> _getFilteredStations() {
    if (_selectedCountry == 'الكل') {
      return RadioData.stations;
    }
    return RadioData.getStationsByCountry(_selectedCountry);
  }

  Color _getStatusColor(String stationId) {
    final status = _stationAvailability[stationId];
    if (status == true) return Colors.green;
    if (status == false) return Colors.red;
    return Colors.orange;
  }

  String _getStatusText(String stationId) {
    final status = _stationAvailability[stationId];
    if (status == true) return 'متاح';
    if (status == false) return 'غير متاح';
    return 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    final countries = ['الكل', ...RadioData.getCountries()];
    final filteredStations = _getFilteredStations();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radio, color: Color(0xFFB8922A)),
            const SizedBox(width: 10),
            Text(
              'إذاعة القرآن الكريم',
              style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث الحالة',
            onPressed: () {
              setState(() {
                _stationAvailability.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر الدول
          Container(
            height: 60,
            color: const Color(0xFF132033),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final isSelected = country == _selectedCountry;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(
                      country,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCountry = country;
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

          // مؤشر الحالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFF132033),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('متاح', style: GoogleFonts.amiri(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 15),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('غير متاح', style: GoogleFonts.amiri(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 15),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('غير معروف', style: GoogleFonts.amiri(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),

          // قائمة المحطات
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: filteredStations.length,
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                final isCurrentStation = _currentStation?.id == station.id;
                
                return _buildStationCard(station, isCurrentStation);
              },
            ),
          ),

          // مشغل الصوت السفلي
          if (_currentStation != null)
            _buildPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildStationCard(RadioStation station, bool isCurrentStation) {
    final isPlaying = isCurrentStation && _isPlaying;
    final isLoading = isCurrentStation && _isLoading;
    final statusColor = _getStatusColor(station.id);
    final statusText = _getStatusText(station.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF132033),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentStation
              ? const Color(0xFFB8922A)
              : Colors.white.withOpacity(0.1),
          width: isCurrentStation ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentStation
                ? const Color(0xFFB8922A).withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: isCurrentStation ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصورة
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1E3A5F), Color(0xFF0B1623)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radio,
                          size: 60,
                          color: isCurrentStation
                              ? const Color(0xFFB8922A)
                              : Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          station.flagEmoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ),
                // LIVE indicator
                if (station.isLive)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Playing/Loading indicator
                if (isPlaying || isLoading)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8922A),
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                // Status indicator
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // المعلومات
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  station.name,
                  style: GoogleFonts.amiri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCurrentStation
                        ? const Color(0xFFB8922A)
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  station.mosque,
                  style: GoogleFonts.amiri(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _playStation(station),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying
                          ? Colors.green
                          : (statusColor == Colors.red 
                              ? Colors.grey 
                              : const Color(0xFF1565A8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 5),
                        Text(
                          isLoading 
                              ? 'جاري...' 
                              : (isPlaying ? 'إيقاف' : 'استمع'),
                          style: GoogleFonts.amiri(
                            fontSize: 13,
                            color: Colors.white,
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
      child: Row(
        children: [
          Icon(
            Icons.radio,
            color: const Color(0xFFB8922A),
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentStation!.name,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currentStation!.mosque,
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
              onPressed: () => _playStation(_currentStation!),
            ),
        ],
      ),
    );
  }
}
