import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('modo_oscuro') ?? false;
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setDark(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modo_oscuro', enabled);
    themeMode.value = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
