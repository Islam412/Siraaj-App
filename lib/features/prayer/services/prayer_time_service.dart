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

  // دالة تنسيق الوقت الجديدة التي تدعم 12 و 24 ساعة
  static String formatTime(DateTime time, bool is24Hour) {
    if (is24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      int hour = time.hour;
      String period = hour >= 12 ? 'م' : 'ص';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
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
