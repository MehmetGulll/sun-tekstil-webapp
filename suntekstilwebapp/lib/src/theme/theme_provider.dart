import 'package:flutter/material.dart';

enum ThemeType { System, Light, Dark }

class ThemeProvider with ChangeNotifier {
  ThemeType _themeType = ThemeType.System;

  ThemeType get themeType => _themeType;

  Future<void> setThemeType(ThemeType newThemeType) async {
    if (newThemeType == _themeType) return;

    _themeType = newThemeType;
    notifyListeners();
  }

  ThemeData getThemeData(BuildContext context) {
    Brightness brightness;
    switch (_themeType) {
      case ThemeType.System:
        brightness = MediaQuery.of(context).platformBrightness;
        break;
      case ThemeType.Light:
        brightness = Brightness.light;
        break;
      case ThemeType.Dark:
        brightness = Brightness.dark;
        break;
      default:
        brightness = MediaQuery.of(context).platformBrightness;
    }

    return ThemeData(
      brightness: brightness,
    );
  }
}
