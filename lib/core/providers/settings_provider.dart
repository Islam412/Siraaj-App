import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);