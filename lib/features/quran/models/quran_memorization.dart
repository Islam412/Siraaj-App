import 'package:hive/hive.dart';

part 'quran_memorization.g.dart';

@HiveType(typeId: 1)
class QuranMemorization extends HiveObject {
  @HiveField(0)
  int surahNumber;

  @HiveField(1)
  String surahName;

  @HiveField(2)
  int totalAyahs;

  @HiveField(3)
  List<int> memorizedAyahs;

  @HiveField(4)
  List<int> reviewingAyahs;

  @HiveField(5)
  DateTime? lastReviewDate;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? completionDate;

  QuranMemorization({
    required this.surahNumber,
    required this.surahName,
    required this.totalAyahs,
    this.memorizedAyahs = const [],
    this.reviewingAyahs = const [],
    this.lastReviewDate,
    required this.startDate,
    this.completionDate,
  });

  double get progress => memorizedAyahs.length / totalAyahs;
  
  bool get isCompleted => memorizedAyahs.length == totalAyahs;
  
  int get remainingAyahs => totalAyahs - memorizedAyahs.length;
}

@HiveType(typeId: 2)
class KhatmaPlan extends HiveObject {
  @HiveField(0)
  String planName;

  @HiveField(1)
  int partsPerDay;

  @HiveField(2)
  int totalDays;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  List<int> completedParts;

  @HiveField(6)
  bool isActive;

  KhatmaPlan({
    required this.planName,
    required this.partsPerDay,
    required this.totalDays,
    required this.startDate,
    this.endDate,
    this.completedParts = const [],
    this.isActive = true,
  });

  double get progress => completedParts.length / (totalDays * partsPerDay);
  
  bool get isCompleted => completedParts.length == (totalDays * partsPerDay);
}
