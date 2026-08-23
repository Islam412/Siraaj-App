import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_time_service.dart';
import '../data/cities_data.dart';
import 'package:adhan/adhan.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  Position? _currentPosition;
  Map<String, DateTime> _prayerTimes = {};
  String _selectedCity = '';
  String _selectedCountry = '';
  String _calculationMethod = 'UmmAlQura';
  bool _isLoading = true;
  bool _isManualLocation = false;
  Timer? _timer;
  String _nextPrayer = '';
  Duration _timeRemaining = Duration.zero;
  
  // متغير نظام الوقت (الافتراضي 24 ساعة)
  bool _is24HourFormat = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializePrayerTimes();
    _startTimer();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = prefs.getBool('is24HourFormat') ?? true;
    });
  }

  Future<void> _toggleTimeFormat() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _is24HourFormat = !_is24HourFormat;
    });
    await prefs.setBool('is24HourFormat', _is24HourFormat);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'إعدادات العرض',
          style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: SwitchListTile(
          title: Text(
            'نظام 24 ساعة',
            style: GoogleFonts.amiri(fontSize: 16, color: Colors.white),
          ),
          subtitle: Text(
            _is24HourFormat ? 'مفعل (مثال: 14:30)' : 'معطل (مثال: 2:30 م)',
            style: GoogleFonts.amiri(fontSize: 12, color: Colors.white70),
          ),
          value: _is24HourFormat,
          activeColor: const Color(0xFFB8922A),
          onChanged: (value) {
            Navigator.pop(context);
            _toggleTimeFormat();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.amiri(color: const Color(0xFFB8922A))),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_prayerTimes.isNotEmpty) {
        _updateNextPrayer();
      }
    });
  }

  void _updateNextPrayer() {
    final nextPrayer = PrayerTimeService.getNextPrayerName(_prayerTimes);
    final nextPrayerTime = _prayerTimes[nextPrayer];
    
    if (nextPrayerTime != null) {
      setState(() {
        _nextPrayer = nextPrayer;
        _timeRemaining = PrayerTimeService.getTimeRemaining(nextPrayerTime);
      });
    }
  }

  Future<void> _initializePrayerTimes() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          setState(() {
            _currentPosition = position;
            _isManualLocation = false;
            _selectedCity = '';
            _selectedCountry = '';
          });

          await _calculatePrayerTimes();
        }
      }
    } catch (e) {
      _useDefaultLocation();
    }

    if (_prayerTimes.isEmpty) {
      _useDefaultLocation();
    }

    setState(() => _isLoading = false);
  }

  void _useDefaultLocation() {
    setState(() {
      _currentPosition = Position(
        latitude: 21.3891,
        longitude: 39.8579,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      _isManualLocation = false;
    });
    _calculatePrayerTimes();
  }

  Future<void> _calculatePrayerTimes() async {
    if (_currentPosition == null) return;

    final prayerTimes = PrayerTimeService.getPrayerTimes(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      date: DateTime.now(),
      method: _calculationMethod,
    );

    setState(() {
      _prayerTimes = PrayerTimeService.getPrayerTimesMap(prayerTimes);
    });

    _updateNextPrayer();
  }

  void _selectManualLocation() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CitySelectionDialog(),
    );

    if (result != null) {
      final city = CitiesData.getCityByName(result['name']!, result['country']!);
      if (city != null) {
        setState(() {
          _currentPosition = Position(
            latitude: city.latitude,
            longitude: city.longitude,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
          _selectedCity = city.name;
          _selectedCountry = city.country;
          _isManualLocation = true;
        });
        await _calculatePrayerTimes();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        title: Text('أوقات الصلاة', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'إعدادات الوقت',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: Icon(_isManualLocation ? Icons.location_off : Icons.my_location),
            tooltip: _isManualLocation ? 'استخدام الموقع الحالي' : 'تحديد مدينة يدوياً',
            onPressed: () {
              if (_isManualLocation) {
                setState(() {
                  _isManualLocation = false;
                  _selectedCity = '';
                  _selectedCountry = '';
                });
                _initializePrayerTimes();
              } else {
                _selectManualLocation();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_isManualLocation && _selectedCity.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_city, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedCity, $_selectedCountry',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'موقع يدوي',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_isManualLocation && _selectedCity.isNotEmpty) const SizedBox(height: 16),
          _buildNextPrayerCard(),
          const SizedBox(height: 20),
          _buildPrayerTimesList(),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565A8), Color(0xFF2180CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565A8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          Text(
            'الصلاة التالية',
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PrayerTimeService.getArabicPrayerName(_nextPrayer),
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${_timeRemaining.inHours.toString().padLeft(2, '0')}:${(_timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.amiri(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _prayerTimes[_nextPrayer] != null
                ? PrayerTimeService.formatTime(_prayerTimes[_nextPrayer]!, _is24HourFormat)
                : '',
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    final prayers = [
      {'name': 'الفجر', 'key': 'Fajr', 'icon': Icons.nightlight},
      {'name': 'الشروق', 'key': 'Sunrise', 'icon': Icons.wb_sunny},
      {'name': 'الظهر', 'key': 'Dhuhr', 'icon': Icons.wb_sunny},
      {'name': 'العصر', 'key': 'Asr', 'icon': Icons.looks_one},
      {'name': 'المغرب', 'key': 'Maghrib', 'icon': Icons.nights_stay},
      {'name': 'العشاء', 'key': 'Isha', 'icon': Icons.nightlight_round},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: prayers.map((prayer) {
          final prayerKey = prayer['key'] as String;
          final prayerTime = _prayerTimes[prayerKey];
          final isNext = prayerKey == _nextPrayer;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isNext ? const Color(0xFF1565A8).withOpacity(0.3) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNext ? const Color(0xFF1565A8) : Colors.white.withOpacity(0.1),
                width: isNext ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  prayer['icon'] as IconData,
                  color: isNext ? const Color(0xFFB8922A) : Colors.white70,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    prayer['name'] as String,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isNext)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8922A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'التالية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  prayerTime != null 
                      ? PrayerTimeService.formatTime(prayerTime, _is24HourFormat) 
                      : '--:--',
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isNext ? const Color(0xFFB8922A) : Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CitySelectionDialog extends StatefulWidget {
  const CitySelectionDialog({super.key});

  @override
  State<CitySelectionDialog> createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends State<CitySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<CityData> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = CitiesData.cities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0B1623),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_city, color: Color(0xFFB8922A)),
                const SizedBox(width: 8),
                Text(
                  'اختر المدينة',
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              style: GoogleFonts.amiri(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة...',
                hintStyle: GoogleFonts.amiri(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB8922A)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredCities = CitiesData.searchCities(value);
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCities.length,
                itemBuilder: (context, index) {
                  final city = _filteredCities[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFFB8922A)),
                    title: Text(
                      city.name,
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      city.country,
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, {
                        'name': city.name,
                        'country': city.country,
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
