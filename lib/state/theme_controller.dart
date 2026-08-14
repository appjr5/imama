import 'package:flutter/material.dart';

/// Controls light/dark mode only. The purple color scheme itself is
/// untouched — see theme/app_theme.dart for both variants.
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
