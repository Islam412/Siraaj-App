import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
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

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double _qiblaDirection = 0.0;
  double _deviceDirection = 0.0;
  double _distanceToKaaba = 0.0;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDesktop = false;
  bool _hasCompass = false;
  StreamSubscription? _compassSubscription;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
          _qiblaDirection = 45.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'خدمة الموقع غير متاحة';
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
          _qiblaDirection = 45.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'إذن الموقع مرفوض';
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

        if (!_isDesktop) {
          _startCompass();
        }
      } catch (e) {
        setState(() {
          _qiblaDirection = 45.0;
          _distanceToKaaba = 0.0;
          _isLoading = false;
          _errorMessage = 'تعذر الحصول على الموقع';
        });
      }
    } catch (e) {
      setState(() {
        _qiblaDirection = 45.0;
        _distanceToKaaba = 0.0;
        _isLoading = false;
        _errorMessage = 'حدث خطأ: \$e';
      });
    }
  }

  void _startCompass() {
    try {
      _compassSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
        if (mounted) {
          setState(() {
            double heading = (math.atan2(event.y, event.x) * 180 / math.pi);
            if (heading < 0) heading += 360;
            _deviceDirection = heading;
            _hasCompass = true;
          });
        }
      }, onError: (error) {
        setState(() => _hasCompass = false);
      });
    } catch (e) {
      setState(() => _hasCompass = false);
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        title: Text('القبلة', style: GoogleFonts.amiri(fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB8922A)))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final angleDifference = _hasCompass 
        ? (_qiblaDirection - _deviceDirection) % 360
        : 0.0;
    final normalizedAngle = angleDifference < 0 ? angleDifference + 360 : angleDifference;
    final isAligned = normalizedAngle < 5 || normalizedAngle > 355;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // رسالة التنبيه
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.amiri(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          if (_errorMessage != null) const SizedBox(height: 20),

          // معلومات المسافة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E3A5F).withOpacity(0.8),
                  const Color(0xFF2E5A8F).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB8922A).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.place, color: Colors.amber.shade400, size: 50),
                const SizedBox(height: 10),
                Text(
                  'المسافة إلى الكعبة',
                  style: GoogleFonts.amiri(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Text(
                  _distanceToKaaba > 0
                      ? '\${_distanceToKaaba.toStringAsFixed(1)} كم'
                      : '0.0 كم (مكة المكرمة)',
                  style: GoogleFonts.amiri(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade300,
                  ),
                ),
                if (_currentPosition != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'موقعك: \${_currentPosition!.latitude.toStringAsFixed(2)}, \${_currentPosition!.longitude.toStringAsFixed(2)}',
                    style: GoogleFonts.amiri(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 30),

          // عنوان البوصلة
          Text(
            'اتجاه القبلة',
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),

          // البوصلة الاحترافية
          _buildRealisticCompass(isAligned, normalizedAngle),
          const SizedBox(height: 25),

          // مؤشر الانحراف
          _buildDeviationIndicator(normalizedAngle, isAligned),
          const SizedBox(height: 20),

          // تعليمات
          _buildInstructions(isAligned, _hasCompass),
        ],
      ),
    );
  }

  Widget _buildRealisticCompass(bool isAligned, double normalizedAngle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFB8922A), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFB8922A).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // البوصلة الدوارة
          SizedBox(
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الدائرة الخارجية
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFB8922A),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                // علامات الاتجاهات
                ...[
                  {'label': 'N', 'angle': 0.0, 'color': Colors.red},
                  {'label': 'E', 'angle': 90.0, 'color': Colors.white},
                  {'label': 'S', 'angle': 180.0, 'color': Colors.white},
                  {'label': 'W', 'angle': 270.0, 'color': Colors.white},
                ].map((dir) {
                  final angle = (dir['angle'] as double) * math.pi / 180;
                  final radius = 125.0;
                  final x = radius * math.sin(angle);
                  final y = -radius * math.cos(angle);
                  return Positioned(
                    left: 150 + x - 22,
                    top: 150 + y - 22,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            dir['color'] as Color,
                            (dir['color'] as Color).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          dir['label'] as String,
                          style: GoogleFonts.amiri(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                // سهم القبلة (ثابت)
                Transform.rotate(
                  angle: _qiblaDirection * math.pi / 180,
                  child: Positioned(
                    top: 25,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565A8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565A8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'القبلة',
                            style: GoogleFonts.amiri(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // المؤشر العلوي (شمال)
                Positioned(
                  top: 5,
                  child: Container(
                    width: 4,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
                // المركز
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB8922A), Color(0xFF8B6914)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // مؤشر الانحراف الرقمي
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isAligned ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isAligned ? Colors.green : Colors.amber,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAligned ? Icons.check_circle : Icons.navigation,
                  color: isAligned ? Colors.green : Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  _hasCompass
                      ? 'الانحراف: \${normalizedAngle.toStringAsFixed(1)}°'
                      : 'استخدم الموبايل للبوصلة التفاعلية',
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAligned ? Colors.green : Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviationIndicator(double angle, bool isAligned) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAligned
              ? [Colors.green.shade800, Colors.green.shade600]
              : [Colors.amber.shade900, Colors.amber.shade700],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (isAligned ? Colors.green : Colors.amber).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isAligned ? Icons.check_circle_outline : Icons.warning_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            isAligned ? 'أحسنت! أنت في اتجاه القبلة' : 'وجّه هاتفك نحو القبلة',
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isAligned
                ? 'بارك الله فيك، اتجاهك صحيح'
                : 'حرك هاتفك حتى يصبح الانحراف 0°',
            style: GoogleFonts.amiri(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isAligned, bool hasCompass) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade300),
              const SizedBox(width: 8),
              Text(
                'كيفية الاستخدام',
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasCompass) ...[
            Text(
              '1. امسك هاتفك بشكل مستوٍ',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              '2. حرك هاتفك ببطء حتى يتطابق سهم القبلة مع الشمال (N)',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              '3. عندما يصبح الانحراف 0°، أنت في اتجاه القبلة',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
            ),
          ] else ...[
            Text(
              'لتجربة البوصلة التفاعلية الكاملة:',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 5),
            Text(
              '• استخدم التطبيق على جهاز موبايل (Android/iOS)',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white60),
            ),
            const SizedBox(height: 5),
            Text(
              '• على الكمبيوتر، يتم عرض الاتجاه فقط بدون البوصلة التفاعلية',
              style: GoogleFonts.amiri(fontSize: 13, color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }
}
