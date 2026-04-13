import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const List<Color> accentPalette = [
    Color(0xFF2563EB), // Blue
    Color(0xFF4F46E5), // Indigo
    Color(0xFF059669), // Emerald
    Color(0xFFE11D48), // Rose
    Color(0xFFF59E0B), // Amber
  ];

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<Color> accentColor = ValueNotifier(accentPalette.first);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    final savedAccent = prefs.getInt('accent_color');

    if (savedAccent != null) {
      accentColor.value = Color(savedAccent);
    }

    if (saved != null) {
      if (saved == 'light') {
        themeMode.value = ThemeMode.light;
      } else if (saved == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else {
        themeMode.value = ThemeMode.system;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.light ? 'light' : mode == ThemeMode.dark ? 'dark' : 'system');
  }

  Future<void> setAccentColor(Color color) async {
    accentColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.toARGB32());
  }

  void toggle() {
    setThemeMode(themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
