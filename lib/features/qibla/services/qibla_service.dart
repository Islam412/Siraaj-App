import 'dart:math';

class QiblaService {
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  static double calculateQiblaDirection(double userLatitude, double userLongitude) {
    final lat1 = _toRadians(kaabaLatitude);
    final lon1 = _toRadians(kaabaLongitude);
    final lat2 = _toRadians(userLatitude);
    final lon2 = _toRadians(userLongitude);
    final deltaLon = lon2 - lon1;
    final y = sin(deltaLon) * cos(lat1);
    final x = cos(lat2) * sin(lat1) - sin(lat2) * cos(lat1) * cos(deltaLon);
    final bearing = atan2(y, x);
    final degrees = _toDegrees(bearing);
    return (degrees + 360) % 360;
  }

  static double calculateDistance(double userLatitude, double userLongitude) {
    const earthRadius = 6371.0;
    final lat1 = _toRadians(kaabaLatitude);
    final lon1 = _toRadians(kaabaLongitude);
    final lat2 = _toRadians(userLatitude);
    final lon2 = _toRadians(userLongitude);
    final deltaLat = lat2 - lat1;
    final deltaLon = lon2 - lon1;
    final a = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180.0;
  static double _toDegrees(double radians) => radians * 180.0 / pi;
}
