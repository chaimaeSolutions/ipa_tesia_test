import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', locale.languageCode);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('localeCode');
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> reloadLocale() async {
    await _loadLocale();
  }
}
