// Persists and exposes light/dark/system [ThemeMode].

import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  void setDark() {
    themeMode.value = ThemeMode.dark;
  }

  void setLight() {
    themeMode.value = ThemeMode.light;
  }

  void setSystem() {
    themeMode.value = ThemeMode.system;
  }
}
