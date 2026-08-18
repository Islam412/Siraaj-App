import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: SiraajApp(),
    ),
  );
}

class SiraajApp extends ConsumerStatefulWidget {
  const SiraajApp({super.key});

  @override
  ConsumerState<SiraajApp> createState() => _SiraajAppState();
}

class _SiraajAppState extends ConsumerState<SiraajApp> {
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سراج',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      
      locale: _locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      home: HomeScreen(
        onLocaleChanged: (locale) => setState(() => _locale = locale),
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
