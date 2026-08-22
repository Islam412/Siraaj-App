import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaDirection = 0.0;
  double _distanceToKaaba = 0.0;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDesktop = false;

  @override
  void initState() {
    super.initState();
    _isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
    _loadQibla();
  }

  Future<void> _loadQibla() async {
    try {
      bool serviceEnabled = false;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (_) {}

      if (!serviceEnabled) {
        setState(() {
          _qiblaDirection = 0.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'خدمة الموقع غير متاحة. يتم عرض اتجاه القبلة الافتراضي.';
        });
        return;
      }

      var permission = LocationPermission.denied;
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      } catch (_) {}

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _qiblaDirection = 0.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'إذن الموقع مرفوض. يتم عرض اتجاه القبلة الافتراضي.';
        });
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );

        setState(() {
          _currentPosition = position;
          _distanceToKaaba = QiblaService.calculateDistance(position.latitude, position.longitude);
          _qiblaDirection = QiblaService.calculateQiblaDirection(position.latitude, position.longitude);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _qiblaDirection = 0.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'تعذر الحصول على الموقع. يتم عرض اتجاه القبلة الافتراضي.';
        });
      }
    } catch (e) {
      setState(() {
        _qiblaDirection = 0.0;
        _distanceToKaaba = 0.0;
        _isLoading = false;
        _errorMessage = 'حدث خطأ: \$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القبلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8F)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.place, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                const Text('المسافة إلى الكعبة', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 10),
                Text(
                  _distanceToKaaba > 0 ? '\${_distanceToKaaba.toStringAsFixed(1)} كم' : '0.0 كم (مكة المكرمة)',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFB8922A)),
                ),
                if (_currentPosition != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'موقعك: \${_currentPosition!.latitude.toStringAsFixed(3)}, \${_currentPosition!.longitude.toStringAsFixed(3)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('اتجاه القبلة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 3),
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      ...[
                        {'label': 'N', 'angle': 0.0},
                        {'label': 'E', 'angle': 90.0},
                        {'label': 'S', 'angle': 180.0},
                        {'label': 'W', 'angle': 270.0},
                      ].map((dir) {
                        final angle = (dir['angle'] as double) * math.pi / 180;
                        final radius = 120.0;
                        final x = radius * math.sin(angle);
                        final y = -radius * math.cos(angle);
                        return Positioned(
                          left: 140 + x - 20,
                          top: 140 + y - 20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1565A8)),
                            child: Center(
                              child: Text(
                                dir['label'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      Transform.rotate(
                        angle: _qiblaDirection * math.pi / 180,
                        child: const Positioned(
                          top: 20,
                          child: Column(
                            children: [
                              Icon(Icons.place, size: 45, color: Color(0xFF1565A8)),
                              SizedBox(height: 4),
                              Text('القبلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565A8))),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFB8922A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        'اتجاه القبلة: \${_qiblaDirection.toStringAsFixed(1)}°',
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (_isDesktop) ...[
                        const SizedBox(height: 5),
                        const Text(
                          'لتجربة البوصلة التفاعلية، استخدم التطبيق على الموبايل',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
