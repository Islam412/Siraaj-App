import 'package:adhan/adhan.dart';

class PrayerTimeService {
  static PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    String method = 'UmmAlQura',
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = getCalculationMethod(method);
    final dateComponents = DateComponents.from(date);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  static CalculationParameters getCalculationMethod(String method) {
    switch (method) {
      case 'UmmAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'Egypt':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'Makkah':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'Dubai':
        return CalculationMethod.dubai.getParameters();
      case 'Qatar':
        return CalculationMethod.qatar.getParameters();
      case 'Kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'Tehran':
        return CalculationMethod.tehran.getParameters();
      case 'Singapore':
        return CalculationMethod.singapore.getParameters();
      default:
        return CalculationMethod.umm_al_qura.getParameters();
    }
  }

  static Map<String, DateTime> getPrayerTimesMap(PrayerTimes prayerTimes) {
    return {
      'Fajr': prayerTimes.fajr,
      'Sunrise': prayerTimes.sunrise,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };
  }

  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static Duration getTimeRemaining(DateTime prayerTime) {
    final now = DateTime.now();
    return prayerTime.difference(now);
  }

  static String getNextPrayerName(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    for (var prayer in prayers) {
      if (prayerTimes[prayer]!.isAfter(now)) {
        return prayer;
      }
    }
    return 'Fajr';
  }

  static String getArabicPrayerName(String englishName) {
    final names = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return names[englishName] ?? englishName;
  }
}
