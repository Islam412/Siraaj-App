import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaDirection = 0.0;
  double _deviceDirection = 0.0;
  double _distanceToKaaba = 0.0;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _magnetometerSubscription;

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          setState(() { _errorMessage = 'يرجى منح إذن الموقع'; _isLoading = false; });
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _distanceToKaaba = QiblaService.calculateDistance(position.latitude, position.longitude);
        _qiblaDirection = QiblaService.calculateQiblaDirection(position.latitude, position.longitude);
        _isLoading = false;
      });
      _startCompass();
    } catch (e) {
      setState(() { _errorMessage = 'حدث خطأ: \$e'; _isLoading = false; });
    }
  }

  void _startCompass() {
    _magnetometerSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
      setState(() {
        // حساب الاتجاه التقريبي بناءً على مقياس المغناطيسية (بافتراض أن الجهاز مسطح)
        double heading = (math.atan2(event.y, event.x) * 180 / math.pi);
        if (heading < 0) {
          heading += 360;
        }
        _deviceDirection = heading;
      });
    });
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القبلة', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: GoogleFonts.amiri(fontSize: 18), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () { setState(() { _isLoading = true; _errorMessage = null; }); _initializeQibla(); }, 
                    child: const Text('إعادة المحاولة'),
                  ),
                ]))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final angleDifference = (_qiblaDirection - _deviceDirection) % 360;
    final normalizedAngle = angleDifference < 0 ? angleDifference + 360 : angleDifference;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Text('المسافة إلى الكعبة', style: GoogleFonts.amiri(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('\${_distanceToKaaba.toStringAsFixed(1)} كم', style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFB8922A))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(angle: _deviceDirection * math.pi / 180, child: _buildCompassRose()),
                Transform.rotate(
                  angle: _qiblaDirection * math.pi / 180,
                  child: Container(
                    width: 300, height: 300,
                    child: Stack(alignment: Alignment.topCenter, children: [
                      Positioned(top: 20, child: Column(children: [
                        const Icon(Icons.place, size: 40, color: Color(0xFF1565A8)),
                        const SizedBox(height: 4),
                        Text('القبلة', style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1565A8))),
                      ])),
                    ]),
                  ),
                ),
                Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFB8922A))),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('وجّه هاتفك حتى يتطابق سهم القبلة مع الشمال', style: GoogleFonts.amiri(fontSize: 16, color: Colors.grey.shade700), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('الانحراف: \${normalizedAngle.toStringAsFixed(1)}°', style: GoogleFonts.amiri(fontSize: 14, color: normalizedAngle < 5 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompassRose() {
    // تحديد نوع البيانات لمنع أخطاء Object
    final List<Map<String, dynamic>> directions = [
      {'label': 'N', 'angle': 0.0},
      {'label': 'E', 'angle': 90.0},
      {'label': 'S', 'angle': 180.0},
      {'label': 'W', 'angle': 270.0},
    ];

    return SizedBox(
      width: 300, height: 300,
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2))),
        ...directions.map((direction) {
          final double angle = (direction['angle'] as double) * math.pi / 180;
          final double radius = 120.0;
          final double x = radius * math.sin(angle);
          final double y = -radius * math.cos(angle);
          return Positioned(
            left: 140 + x - 15, top: 140 + y - 15,
            child: Container(
              width: 30, height: 30, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1565A8)),
              child: Center(child: Text(direction['label'] as String, style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ),
          );
        }).toList(),
      ]),
    );
  }
}
