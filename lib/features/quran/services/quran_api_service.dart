import 'package:dio/dio.dart';

class QuranApiService {
  final Dio _dio = Dio();
  
  // جلب قائمة السور
  Future<List<dynamic>> getSurahList() async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/surah',
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('فشل في تحميل قائمة السور');
    }
  }
  
  // جلب سورة معينة مع الآيات
  Future<Map<String, dynamic>> getSurah(int surahNumber) async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/surah/$surahNumber',
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('فشل في تحميل السورة');
    }
  }
  
  // جلب آية معينة
  Future<Map<String, dynamic>> getAyah(int surahNumber, int ayahNumber) async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber',
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('فشل في تحميل الآية');
    }
  }
}