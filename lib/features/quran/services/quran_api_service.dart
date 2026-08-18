import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _tafsirBaseUrl = 'https://api.alquran.cloud/v1';
  
  // جلب سورة كاملة
  Future<Map<String, dynamic>> getSurah(int number) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/surah/$number/quran-uthmani'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('فشل في تحميل السورة');
      }
    } catch (e) {
      print('Error fetching surah: $e');
      rethrow;
    }
  }
  
  // جلب التفسير
  Future<String> getTafsir(int surahNum, int ayahNum, {String tafsirType = 'ar.muyassar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_tafsirBaseUrl/ayah/$surahNum:$ayahNum/$tafsirType'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'] ?? 'لا يوجد تفسير متاح';
      } else {
        return 'تعذر تحميل التفسير';
      }
    } catch (e) {
      print('Error fetching tafsir: $e');
      return 'حدث خطأ في تحميل التفسير';
    }
  }
  
  // رابط الصوت
  String getAudioUrl(String reciterId, int ayahNumber) {
    return 'https://cdn.islamic.network/quran/audio/128/$reciterId/$ayahNumber.mp3';
  }
  
  // قائمة القراء
  List<Map<String, String>> getReciters() {
    return [
      {'id': 'ar.alafasy', 'name': 'مشاري العفاسي'},
      {'id': 'ar.abdurrahmaansudais', 'name': 'عبد الرحمن السديس'},
      {'id': 'ar.husary', 'name': 'محمود خليل الحصري'},
      {'id': 'ar.minshawi', 'name': 'محمد صديق المنشاوي'},
      {'id': 'ar.abdulbasitmurattal', 'name': 'عبد الباسط عبد الصمد'},
    ];
  }
}