import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
);
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
);

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;

  bool get isLightMode => _themeData == lightMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
  }

  ThemeProvider() {
    _loadTheme();
    notifyListeners();
  }

  toggleTheme() async {
    if (_themeData == lightMode)
      _themeData = darkMode;
    else
      _themeData = lightMode;
    await _saveTheme();
    notifyListeners();
  }

  _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLightMode", isLightMode);
  }

  _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isLightMode") == true)
      themeData = lightMode;
    else
      themeData = darkMode;
  }
}
