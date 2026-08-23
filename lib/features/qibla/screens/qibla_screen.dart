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
      duration: const Duration(milliseconds: 1000),
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

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8F)],
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
                const Text('المسافة إلى الكعبة', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 10),
                Text(
                  _distanceToKaaba > 0 ? '\${_distanceToKaaba.toStringAsFixed(1)} كم' : '0.0 كم (مكة المكرمة)',
                  style: GoogleFonts.amiri(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber.shade300),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text('اتجاه القبلة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 25),

          _build3DCompass(isAligned, normalizedAngle),
          const SizedBox(height: 25),

          _buildDeviationIndicator(normalizedAngle, isAligned),
          const SizedBox(height: 20),

          _buildInstructions(isAligned, _hasCompass),
        ],
      ),
    );
  }

  Widget _build3DCompass(bool isAligned, double normalizedAngle) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A3A4A), Color(0xFF1A2A3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFB8922A), width: 4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, 15)),
          BoxShadow(color: const Color(0xFFB8922A).withOpacity(0.4), blurRadius: 40, spreadRadius: 3),
        ],
      ),
      child: Column(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(0.3),
            child: SizedBox(
              height: 350,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 330,
                    height: 330,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFF2A3A4A), Color(0xFF1A2A3A)],
                      ),
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0xFFB8922A), width: 5),
                      ),
                    ),
                  ),
                  ...[
                    {'label': 'N', 'angle': 0.0, 'color': Colors.red},
                    {'label': 'E', 'angle': 90.0, 'color': Colors.white},
                    {'label': 'S', 'angle': 180.0, 'color': Colors.white},
                    {'label': 'W', 'angle': 270.0, 'color': Colors.white},
                  ].map((dir) {
                    final angle = (dir['angle'] as double) * math.pi / 180;
                    final radius = 140.0;
                    final x = radius * math.sin(angle);
                    final y = -radius * math.cos(angle);
                    return Positioned(
                      left: 165 + x - 25,
                      top: 165 + y - 25,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [dir['color'] as Color, (dir['color'] as Color).withOpacity(0.6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            dir['label'] as String,
                            style: GoogleFonts.amiri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Transform.rotate(
                    angle: _qiblaDirection * math.pi / 180,
                    child: Positioned(
                      top: 30,
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFB8922A), width: 3),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 5)),
                                BoxShadow(color: const Color(0xFFB8922A).withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2A2A2A),
                                          shape: BoxShape.circle,
                                          border: Border.fromBorderSide(
                                            BorderSide(color: Color(0xFFB8922A), width: 2),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: 30,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB8922A),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  child: Container(
                                    width: 60,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A0A0A),
                                      border: Border.all(color: const Color(0xFFB8922A), width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'الله',
                                        style: GoogleFonts.amiri(color: const Color(0xFFB8922A), fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          CustomPaint(
                            size: const Size(40, 50),
                            painter: ArrowPainter(color: const Color(0xFF1565A8)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565A8),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: const Text(
                              'القبلة',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    child: SizedBox(
                      width: 5,
                      height: 25,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFFB8922A), Color(0xFF8B6914)]),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              color: isAligned ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isAligned ? Colors.green : Colors.amber, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isAligned ? Icons.check_circle : Icons.navigation, color: isAligned ? Colors.green : Colors.amber, size: 28),
                const SizedBox(width: 12),
                Text(
                  _hasCompass ? 'الانحراف: \${normalizedAngle.toStringAsFixed(1)}°' : 'استخدم الموبايل للبوصلة',
                  style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.bold, color: isAligned ? Colors.green : Colors.amber),
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
          colors: isAligned ? [Colors.green.shade800, Colors.green.shade600] : [Colors.amber.shade900, Colors.amber.shade700],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: (isAligned ? Colors.green : Colors.amber).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(isAligned ? Icons.check_circle_outline : Icons.warning_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            isAligned ? 'أحسنت! أنت في اتجاه القبلة' : 'وجّه هاتفك نحو القبلة',
            style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            isAligned ? 'بارك الله فيك، اتجاهك صحيح' : 'حرك هاتفك حتى يصبح الانحراف 0°',
            style: GoogleFonts.amiri(fontSize: 14, color: Colors.white70),
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
              Text('كيفية الاستخدام', style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade200)),
            ],
          ),
          const SizedBox(height: 10),
          if (hasCompass) ...[
            Text('1. امسك هاتفك بشكل مستوٍ', style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 5),
            Text('2. حرك هاتفك ببطء حتى يتطابق سهم القبلة مع الشمال (N)', style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 5),
            Text('3. عندما يصبح الانحراف 0°، أنت في اتجاه القبلة', style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70)),
          ] else ...[
            Text('لتجربة البوصلة التفاعلية الكاملة:', style: GoogleFonts.amiri(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 5),
            Text('• استخدم التطبيق على جهاز موبايل (Android/iOS)', style: GoogleFonts.amiri(fontSize: 13, color: Colors.white60)),
          ],
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  
  ArrowPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.lineTo(0, size.height * 0.7);
    path.close();
    
    canvas.drawPath(path, paint);
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    final shadowPath = Path()
      ..addPath(path, const Offset(2, 3));
    
    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
