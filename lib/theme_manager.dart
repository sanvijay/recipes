import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Theme
import 'package:recipes/theme.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData = ThemeKlass.lightTheme;
  ThemeData getTheme() => _themeData;

  ThemeNotifier() {
    SharedPreferences.getInstance().then((pref) {
      String? darkTheme = pref.getString('theme:dark_theme');
      var themeMode = darkTheme ?? 'light';
      if (themeMode == 'light') {
        _themeData = ThemeKlass.lightTheme;
      } else if (themeMode == 'dark') {
        _themeData = ThemeKlass.darkTheme;
      } else if (themeMode == 'system') {
        var brightness = SchedulerBinding.instance!.window.platformBrightness;
        bool isDarkMode = brightness == Brightness.dark;

        _themeData = isDarkMode ? ThemeKlass.darkTheme : ThemeKlass.lightTheme;
      }
      notifyListeners();
    });
  }

  Future<bool> isDarkMode() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? darkTheme = pref.getString('theme:dark_theme');

    if (darkTheme == 'light') {
      return false;
    }
    else if (darkTheme == 'dark') {
      return true;
    }
    else if (darkTheme == 'system') {
      var brightness = SchedulerBinding.instance!.window.platformBrightness;
      return brightness == Brightness.dark;
    }

    return false;
  }

  void setDarkMode() async {
    _themeData = ThemeKlass.darkTheme;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('theme:dark_theme', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = ThemeKlass.lightTheme;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('theme:dark_theme', 'light');
    notifyListeners();
  }

  void setSystemMode() async {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    _themeData = isDarkMode ? ThemeKlass.darkTheme : ThemeKlass.lightTheme;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('theme:dark_theme', 'system');
    notifyListeners();
  }
}
