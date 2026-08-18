import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/quran/quran_screen.dart';
import '../../features/hadith/hadith_screen.dart';
import '../../features/azkar/azkar_screen.dart';
import '../../features/tasbih/tasbih_screen.dart';
import '../../features/prayer/prayer_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/muhasaba/muhasaba_screen.dart';
import '../../features/podcast/podcast_screen.dart';
import '../../features/lectures/lectures_screen.dart';
import '../../features/books/books_screen.dart';
import '../../features/radio/radio_screen.dart';
import '../../features/contact/contact_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
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
        path: '/qibla',
        name: 'qibla',
        builder: (context, state) => const QiblaScreen(),
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
        builder: (context, state) => const LecturesScreen(),
      ),
      GoRoute(
        path: '/books',
        name: 'books',
        builder: (context, state) => const BooksScreen(),
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