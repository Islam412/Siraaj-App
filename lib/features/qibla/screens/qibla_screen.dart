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
        _errorMessage = 'حدث خطأ: $e';
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

  String _getDisplayAngle() {
    final angleDifference = _hasCompass 
        ? (_qiblaDirection - _deviceDirection) % 360
        : 0.0;
    final normalizedAngle = angleDifference < 0 ? angleDifference + 360 : angleDifference;
    final displayAngle = normalizedAngle > 180 ? normalizedAngle - 360 : normalizedAngle;
    return displayAngle.toStringAsFixed(0);
  }

  bool _getIsAligned() {
    final angleDifference = _hasCompass 
        ? (_qiblaDirection - _deviceDirection) % 360
        : 0.0;
    final normalizedAngle = angleDifference < 0 ? angleDifference + 360 : angleDifference;
    return normalizedAngle < 5 || normalizedAngle > 355;
  }

  @override
  Widget build(BuildContext context) {
    final displayAngle = _getDisplayAngle();
    final isAligned = _getIsAligned();

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
                          '$displayAngle°',
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

                  _buildCompass(isAligned),
                  const SizedBox(height: 25),

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
                            const Icon(Icons.place, color: Color(0xFF1976D2), size: 30),
                            const SizedBox(height: 8),
                            const Text(
                              'المسافة',
                              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _distanceToKaaba > 0
                                  ? '${_distanceToKaaba.toStringAsFixed(1)} كم'
                                  : '0.0 كم',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
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
                            const Icon(Icons.my_location, color: Color(0xFF388E3C), size: 30),
                            const SizedBox(height: 8),
                            const Text(
                              'موقعك',
                              style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _currentPosition != null
                                  ? '${_currentPosition!.latitude.toStringAsFixed(2)}, ${_currentPosition!.longitude.toStringAsFixed(2)}'
                                  : 'غير متوفر',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF388E3C),
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
        color: Colors.grey[600],
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
          
          Builder(
            builder: (context) {
              final qiblaAngleRad = _qiblaDirection * math.pi / 180;
              final qiblaRadius = 110.0;
              final qiblaX = 160.0 + qiblaRadius * math.sin(qiblaAngleRad);
              final qiblaY = 160.0 - qiblaRadius * math.cos(qiblaAngleRad);
              
              return Positioned(
                left: qiblaX - 20,
                top: qiblaY - 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // علامة الموقع الحمراء الاحترافية
                    CustomPaint(
                      size: const Size(40, 50),
                      painter: LocationPinPainter(),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Text(
                        'القبلة',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

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

// رسم علامة الموقع الحمراء الاحترافية
class LocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final radius = size.width * 0.35;

    // الظل السفلي
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.5,
        height: 6,
      ),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // جسم العلامة (الشكل الدمعي)
    final pinPath = Path();
    pinPath.moveTo(size.width / 2, size.height * 0.95);
    pinPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.6,
      size.width * 0.15, size.height * 0.35,
    );
    pinPath.arcToPoint(
      Offset(size.width * 0.85, size.height * 0.35),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    pinPath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.6,
      size.width / 2, size.height * 0.95,
    );
    pinPath.close();

    // تدرج لوني للعلامة
    final pinPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, 0.3),
        colors: [const Color(0xFFFF4444), const Color(0xFFCC0000)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.95));

    canvas.drawPath(pinPath, pinPaint);

    // حدود خفيفة
    canvas.drawPath(
      pinPath,
      Paint()
        ..color = const Color(0xFF990000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // الدائرة البيضاء في المنتصف
    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()..color = Colors.white,
    );

    // ظل داخلي للدائرة البيضاء
    canvas.drawCircle(
      Offset(center.dx - 2, center.dy - 2),
      radius * 0.4,
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    // لمعة على العلامة
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.25),
      radius * 0.2,
      highlightPaint,
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
