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

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaDirection = 0.0;
  double _deviceDirection = 0.0;
  double _distanceToKaaba = 0.0;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDesktop = false;
  bool _hasCompass = false;
  StreamSubscription? _compassSubscription;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angleDifference = _hasCompass 
        ? (_qiblaDirection - _deviceDirection) % 360
        : 0.0;
    final normalizedAngle = angleDifference < 0 ? angleDifference + 360 : angleDifference;
    final displayAngle = normalizedAngle > 180 ? normalizedAngle - 360 : normalizedAngle;
    final isAligned = normalizedAngle < 5 || normalizedAngle > 355;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('البوصلة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565A8)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'البوصلة',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'معرفة القبلة من خلال البوصلة',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // عرض درجة الانحراف
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: isAligned ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (isAligned ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 30),
                        const SizedBox(height: 5),
                        const Text(
                          'القبلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${displayAngle.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'درجة',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // البوصلة مع الكعبة
                  _buildCompass(isAligned),
                  const SizedBox(height: 25),

                  // معلومات المسافة والموقع
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.place, color: const Color(0xFF1976D2), size: 30),
                            const SizedBox(height: 8),
                            Text(
                              'المسافة',
                              style: TextStyle(fontSize: 14, color: const Color(0xFF757575)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _distanceToKaaba > 0
                                  ? '${_distanceToKaaba.toStringAsFixed(1)} كم'
                                  : '0.0 كم',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: const Color(0xFFE0E0E0),
                        ),
                        Column(
                          children: [
                            Icon(Icons.my_location, color: const Color(0xFF388E3C), size: 30),
                            const SizedBox(height: 8),
                            const Text(
                              'موقعك',
                              style: TextStyle(fontSize: 14, color: const Color(0xFF757575)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _currentPosition != null
                                  ? '${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}'
                                  : 'غير متوفر',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF388E3C),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

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
                              style: const TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCompass(bool isAligned) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF757575),
        border: Border.all(color: Colors.grey[700]!, width: 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(320, 320),
            painter: CompassPainter(deviceDirection: _deviceDirection),
          ),
          
          // حساب موقع الكعبة هندسياً
          Builder(
            builder: (context) {
              final qiblaAngleRad = _qiblaDirection * math.pi / 180;
              final qiblaRadius = 110.0;
              final qiblaX = 160.0 + qiblaRadius * math.sin(qiblaAngleRad);
              final qiblaY = 160.0 - qiblaRadius * math.cos(qiblaAngleRad);
              
              return Positioned(
                left: qiblaX - 30,
                top: qiblaY - 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // رسم الكعبة
                    KaabaWidget(size: 40),
                    SizedBox(height: 4),
                    Text(
                      'القبلة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // الإبرة المتحركة مع الجهاز
          Transform.rotate(
            angle: _deviceDirection * math.pi / 180,
            child: const CustomPaint(
              size: Size(120, 120),
              painter: CompassNeedlePainter(),
            ),
          ),
          
          Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// رسم الكعبة بشكل احترافي
class KaabaWidget extends StatelessWidget {
  final double size;
  
  const KaabaWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: KaabaPainter(),
    );
  }
}

class KaabaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;

    // جسم الكعبة (مكعب)
    final kaabaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.8),
      const Radius.circular(2),
    );
    canvas.drawRRect(kaabaRect, paint);

    // الكسوة السوداء العلوية
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.15),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // كتابة "الله" على الكسوة
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'الله',
        style: TextStyle(
          color: Color(0xFFB8922A),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height * 0.25,
      ),
    );

    // الحجر الأسود (دائرة صغيرة)
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.5),
      3,
      Paint()..color = const Color(0xFF2A2A2A),
    );

    // الميزاب (خط ذهبي)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.18, size.width * 0.4, 3),
      Paint()..color = const Color(0xFFB8922A),
    );

    // حدود ذهبية
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.2, size.width, 2),
      Paint()..color = const Color(0xFFB8922A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompassPainter extends CustomPainter {
  final double deviceDirection;

  CompassPainter({required this.deviceDirection});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    for (int i = 0; i < 360; i += 6) {
      final angle = (i - deviceDirection) * math.pi / 180;
      final isMain = i % 30 == 0;
      final length = isMain ? 12.0 : 6.0;
      final width = isMain ? 2.0 : 1.0;

      final startX = center.dx + (radius - length) * math.sin(angle);
      final startY = center.dy - (radius - length) * math.cos(angle);
      final endX = center.dx + radius * math.sin(angle);
      final endY = center.dy - radius * math.cos(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = isMain ? Colors.white : Colors.white54
          ..strokeWidth = width
          ..style = PaintingStyle.stroke,
      );
    }

    final directions = [
      {'label': 'N', 'angle': 0.0, 'color': Colors.white},
      {'label': 'NE', 'angle': 45.0, 'color': Colors.red},
      {'label': 'E', 'angle': 90.0, 'color': Colors.white},
      {'label': 'SE', 'angle': 135.0, 'color': Colors.red},
      {'label': 'S', 'angle': 180.0, 'color': Colors.white},
      {'label': 'SW', 'angle': 225.0, 'color': Colors.red},
      {'label': 'W', 'angle': 270.0, 'color': Colors.white},
      {'label': 'NW', 'angle': 315.0, 'color': Colors.red},
    ];

    for (var dir in directions) {
      final angleVal = dir['angle'] as double;
      final angle = (angleVal - deviceDirection) * math.pi / 180;
      final labelRadius = radius - 35;
      final x = center.dx + labelRadius * math.sin(angle);
      final y = center.dy - labelRadius * math.cos(angle);

      final double fontSize = (angleVal % 90 == 0) ? 20 : 14;

      final textPainter = TextPainter(
        text: TextSpan(
          text: dir['label'] as String,
          style: TextStyle(
            color: dir['color'] as Color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.deviceDirection != deviceDirection;
  }
}

class CompassNeedlePainter extends CustomPainter {
  const CompassNeedlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // الإبرة الحمراء (الشمال)
    final redPath = Path();
    redPath.moveTo(center.dx, center.dy - size.height / 2 + 10);
    redPath.lineTo(center.dx - 15, center.dy);
    redPath.lineTo(center.dx, center.dy + 10);
    redPath.lineTo(center.dx + 15, center.dy);
    redPath.close();

    canvas.drawPath(
      redPath,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );

    // الإبرة البيضاء (الجنوب)
    final whitePath = Path();
    whitePath.moveTo(center.dx, center.dy + size.height / 2 - 10);
    whitePath.lineTo(center.dx - 15, center.dy);
    whitePath.lineTo(center.dx, center.dy - 10);
    whitePath.lineTo(center.dx + 15, center.dy);
    whitePath.close();

    canvas.drawPath(
      whitePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      8,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
