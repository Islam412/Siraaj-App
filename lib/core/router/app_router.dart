import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/stories/screens/stories_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/zakat/screens/zakat_screen.dart';
import '../../features/asma_allah/screens/asma_allah_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/quran/quran_screen.dart';
import '../../features/hadith/screens/hadith_screen.dart';
import '../../features/azkar/screens/azkar_screen.dart';
import '../../features/tasbih/screens/tasbih_screen.dart';
import '../../features/prayer/screens/prayer_screen.dart';
import '../../features/qibla/screens/qibla_screen.dart';
import '../../features/muhasaba/muhasaba_screen.dart';
import '../../features/podcast/screens/podcast_screen.dart';
import '../../features/lectures/screens/lecture_screen.dart';
import '../../features/books/screens/book_screen.dart';
import '../../features/radio/screens/radio_screen.dart';
import '../../features/contact/contact_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/stories',
        name: 'stories',
        builder: (context, state) => const StoriesScreen(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/zakat',
        name: 'zakat',
        builder: (context, state) => const ZakatScreen(),
      ),
      GoRoute(
        path: '/asma-allah',
        name: 'asmaAllah',
        builder: (context, state) => const AsmaAllahScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranScreen(),
      ),
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/hadith',
        name: 'hadith',
        builder: (context, state) => const HadithScreen(),
      ),
      GoRoute(
        path: '/azkar',
        name: 'azkar',
        builder: (context, state) => const AzkarScreen(),
      ),
      GoRoute(
        path: '/tasbih',
        name: 'tasbih',
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/prayer',
        name: 'prayer',
        builder: (context, state) => const PrayerScreen(),
      ),
      GoRoute(
        path: '/muhasaba',
        name: 'muhasaba',
        builder: (context, state) => const MuhasabaScreen(),
      ),
      GoRoute(
        path: '/podcast',
        name: 'podcast',
        builder: (context, state) => const PodcastScreen(),
      ),
      GoRoute(
        path: '/lectures',
        name: 'lectures',
        builder: (context, state) => const LectureScreen(),
      ),
      GoRoute(
        path: '/books',
        name: 'books',
        builder: (context, state) => const BookScreen(),
      ),
      GoRoute(
        path: '/radio',
        name: 'radio',
        builder: (context, state) => const RadioScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
    ],
  );
}
