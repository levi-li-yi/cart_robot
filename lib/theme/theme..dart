/*
 * @Author: Levi Li
 * @Date: 2024-03-29 16:10:45
 * @description: 应用主题切换通知
 */
import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  AppTheme(String mode) {
    switch (mode) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
  }

  static AppTheme instance = AppTheme('system');

  static ThemeMode themeModeFormString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
