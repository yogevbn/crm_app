import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslationService {
  final Locale locale;
  Map<String, String>? _localizedStrings;

  TranslationService(this.locale);

  static TranslationService of(BuildContext context) {
    return Localizations.of<TranslationService>(context, TranslationService)!;
  }

  Locale get currentLocale => locale;

  Future<void> load() async {
    print("Loading translations for locale: ${locale.languageCode}");
    try {
      // Load base language files first
      Map<String, String> enMap = await _loadJsonData('en');
      Map<String, String> heMap = await _loadJsonData('he');

      // Set localized strings based on selected locale
      _localizedStrings = locale.languageCode == 'he' ? heMap : enMap;

      print("Translations loaded successfully for ${locale.languageCode}");
    } catch (e) {
      print("Error loading translations: $e");
    }
  }

  Future<Map<String, String>> _loadJsonData(String languageCode) async {
    String path = 'assets/lang/$languageCode.json';
    print("Attempting to load $languageCode JSON data from $path");
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    Map<String, String> localizedMap =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    // Check for missing keys and add placeholders if necessary
    await _checkAndAddMissingKeys(languageCode, localizedMap);
    return localizedMap;
  }

  Future<void> _checkAndAddMissingKeys(
      String languageCode, Map<String, String> map) async {
    bool updated = false;
    List<String> missingTranslations = [];

    // Define a standard list of keys if _localizedStrings is not initialized
    List<String> allKeys = _localizedStrings?.keys.toList() ?? [];
    if (allKeys.isEmpty) {
      allKeys = map.keys.toList(); // Use keys from the map as a fallback
    }

    for (String key in allKeys) {
      if (!map.containsKey(key)) {
        map[key] = '[missing translation]';
        missingTranslations.add(
            '"$key": "${_localizedStrings?[key] ?? "Translation needed"}"');
        updated = true;
      }
    }

    if (updated) {
      print('Missing keys for $languageCode:\n' +
          missingTranslations.join(",\n"));
      await _writeUpdatedJson('assets/lang/$languageCode.json', map);
    }
  }

  Future<void> _writeUpdatedJson(String path, Map<String, String> map) async {
    final jsonFile = File(path);
    if (await jsonFile.exists()) {
      await jsonFile.writeAsString(json.encode(map));
      print("Updated $path with new keys.");
    } else {
      print("Error: JSON file $path does not exist, unable to write new keys.");
    }
  }

  String translate(String key, {Map<String, String>? placeholders}) {
    String translation = _localizedStrings?[key] ?? '[missing translation]';
    if (translation == '[missing translation]') {
      print("Warning: Missing translation for key '$key'");
    }
    if (placeholders != null) {
      placeholders.forEach((placeholder, value) {
        translation = translation.replaceAll('{$placeholder}', value);
      });
    }
    return translation;
  }

  static const LocalizationsDelegate<TranslationService> delegate =
      _TranslationServiceDelegate();
}

class _TranslationServiceDelegate
    extends LocalizationsDelegate<TranslationService> {
  const _TranslationServiceDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<TranslationService> load(Locale locale) async {
    print("Initializing TranslationService for ${locale.languageCode}");
    TranslationService service = TranslationService(locale);
    await service.load();
    return service;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<TranslationService> old) =>
      false;
}
