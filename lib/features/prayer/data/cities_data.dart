class CityData {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityData({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class CitiesData {
  static const List<CityData> cities = [
    CityData(name: 'مكة المكرمة', country: 'السعودية', latitude: 21.3891, longitude: 39.8579),
    CityData(name: 'المدينة المنورة', country: 'السعودية', latitude: 24.5247, longitude: 39.5692),
    CityData(name: 'الرياض', country: 'السعودية', latitude: 24.7136, longitude: 46.6753),
    CityData(name: 'جدة', country: 'السعودية', latitude: 21.5433, longitude: 39.1728),
    CityData(name: 'الدمام', country: 'السعودية', latitude: 26.4207, longitude: 50.0888),
    CityData(name: 'القاهرة', country: 'مصر', latitude: 30.0444, longitude: 31.2357),
    CityData(name: 'الإسكندرية', country: 'مصر', latitude: 31.2001, longitude: 29.9187),
    CityData(name: 'دبي', country: 'الإمارات', latitude: 25.2048, longitude: 55.2708),
    CityData(name: 'أبوظبي', country: 'الإمارات', latitude: 24.4539, longitude: 54.3773),
    CityData(name: 'الكويت', country: 'الكويت', latitude: 29.3759, longitude: 47.9774),
    CityData(name: 'الدوحة', country: 'قطر', latitude: 25.2854, longitude: 51.5310),
    CityData(name: 'المنامة', country: 'البحرين', latitude: 26.2285, longitude: 50.5860),
    CityData(name: 'مسقط', country: 'عمان', latitude: 23.5880, longitude: 58.3829),
    CityData(name: 'عمان', country: 'الأردن', latitude: 31.9454, longitude: 35.9284),
    CityData(name: 'الرباط', country: 'المغرب', latitude: 34.0209, longitude: -6.8416),
    CityData(name: 'الدار البيضاء', country: 'المغرب', latitude: 33.5731, longitude: -7.5898),
    CityData(name: 'الجزائر', country: 'الجزائر', latitude: 36.7538, longitude: 3.0588),
    CityData(name: 'تونس', country: 'تونس', latitude: 36.8065, longitude: 10.1815),
    CityData(name: 'طرابلس', country: 'ليبيا', latitude: 32.8872, longitude: 13.1913),
    CityData(name: 'إسطنبول', country: 'تركيا', latitude: 41.0082, longitude: 28.9784),
    CityData(name: 'أنقرة', country: 'تركيا', latitude: 39.9334, longitude: 32.8597),
    CityData(name: 'كراتشي', country: 'باكستان', latitude: 24.8607, longitude: 67.0011),
    CityData(name: 'لاهور', country: 'باكستان', latitude: 31.5497, longitude: 74.3436),
    CityData(name: 'جاكرتا', country: 'إندونيسيا', latitude: -6.2088, longitude: 106.8456),
    CityData(name: 'كوالالمبور', country: 'ماليزيا', latitude: 3.1390, longitude: 101.6869),
    CityData(name: 'داكا', country: 'بنغلاديش', latitude: 23.8103, longitude: 90.4125),
  ];

  static List<CityData> searchCities(String query) {
    if (query.isEmpty) return [];
    return cities.where((city) {
      return city.name.contains(query) || city.country.contains(query);
    }).toList();
  }

  static CityData? getCityByName(String name, String country) {
    try {
      return cities.firstWhere(
        (city) => city.name == name && city.country == country,
      );
    } catch (e) {
      return null;
    }
  }
}
