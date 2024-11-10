import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageSettings {
  static const _languageCodeKey = 'languageCode';

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }

  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey) ?? 'en';
    return Locale(languageCode);
  }
}
