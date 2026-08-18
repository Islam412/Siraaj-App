import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  
  // جلب قائمة السور
  Future<List<dynamic>> getSurahList() async {
    final response = await http.get(Uri.parse('$_baseUrl/surah'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    throw Exception('فشل في تحميل قائمة السور');
  }
  
  // جلب سورة كاملة مع الآيات
  Future<Map<String, dynamic>> getSurah(int number) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/surah/$number/quran-uthmani'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    throw Exception('فشل في تحميل السورة');
  }
  
  // جلب التفسير - مع دعم تفاسير متعددة
  Future<String> getTafsir(int surahNum, int ayahNum, {String tafsirType = 'ar.muyassar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ayah/$surahNum:$ayahNum/$tafsirType'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'] ?? 'لا يوجد تفسير';
      }
    } catch (e) {
      return 'تعذر تحميل التفسير';
    }
    return 'لا يوجد تفسير متاح';
  }
  
  // قائمة التفاسير المتاحة
  List<Map<String, String>> getTafsirBooks() {
    return [
      {'id': 'ar.muyassar', 'name': 'التفسير الميسر'},
      {'id': 'ar.jalalayn', 'name': 'تفسير الجلالين'},
      {'id': 'ar.saddi', 'name': 'تفسير السعدي'},
      {'id': 'ar.baghawy', 'name': 'تفسير البغوي'},
      {'id': 'ar.qurtubi', 'name': 'تفسير القرطبي'},
      {'id': 'ar.tabari', 'name': 'تفسير الطبري'},
      {'id': 'ar.ibnkathir', 'name': 'تفسير ابن كثير'},
    ];
  }
  
  // رابط الصوت للآية
  String getAudioUrl(String reciterId, int ayahNumber) {
    return 'https://cdn.islamic.network/quran/audio/128/$reciterId/$ayahNumber.mp3';
  }
  
  // قائمة المشايخ الكاملة
  List<Map<String, String>> getReciters() {
    return [
      {'id': 'ar.alafasy', 'name': 'مشاري راشد العفاسي'},
      {'id': 'ar.abdurrahmaansudais', 'name': 'عبد الرحمن السديس'},
      {'id': 'ar.saoodshuraym', 'name': 'سعود الشريم'},
      {'id': 'ar.mahermuaiqly', 'name': 'ماهر المعيقلي'},
      {'id': 'ar.abdullahbasfar', 'name': 'عبدالله بصفر'},
      {'id': 'ar.husary', 'name': 'محمود خليل الحصري'},
      {'id': 'ar.husarymujawwad', 'name': 'الحصري (مجود)'},
      {'id': 'ar.minshawi', 'name': 'محمد صديق المنشاوي'},
      {'id': 'ar.minshawimujawwad', 'name': 'المنشاوي (مجود)'},
      {'id': 'ar.abdulbasitmurattal', 'name': 'عبد الباسط (مرتل)'},
      {'id': 'ar.abdulbasitmujawwad', 'name': 'عبد الباسط (مجود)'},
      {'id': 'ar.muhammadayyoub', 'name': 'محمد أيوب'},
      {'id': 'ar.muhammadjibreel', 'name': 'محمد جبريل'},
      {'id': 'ar.ibrahimakhdar', 'name': 'إبراهيم الأخضر'},
      {'id': 'ar.hanirifai', 'name': 'هاني الرفاعي'},
      {'id': 'ar.ahmadajamy', 'name': 'أحمد الأعجمي'},
      {'id': 'ar.shaatree', 'name': 'أبو بكر الشاطري'},
      {'id': 'ar.aliabdurrahman', 'name': 'علي الحذيفي'},
      {'id': 'ar.yasserdossari', 'name': 'ياسر الدوسري'},
    ];
  }
}
