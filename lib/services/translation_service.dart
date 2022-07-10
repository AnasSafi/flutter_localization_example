import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class TranslationService {
  final Locale? locale;
  Map<String, dynamic> _localizedStrings = Map();

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<TranslationService> delegate = _TranslationServiceDelegate();

  TranslationService(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static TranslationService? of(BuildContext context) {
    return Localizations.of<TranslationService>(context, TranslationService);
  }

  static String currentLocale(BuildContext context) {
    return of(context)!.locale!.languageCode;
  }

  static Future<TranslationService> getTranslationService() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('appLocale') ?? AppConfig.defaultLanguage;
    return await TranslationService.delegate.load(Locale(languageCode));
  }

  Future<bool> load() async {
    String jsonString = "{}";
    jsonString = await rootBundle.loadString('assets/i18n/translations.json');

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('appLocale', locale!.languageCode);

    _localizedStrings = json.decode(jsonString);

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key, [List? replacements]) {
    return _replace(key, replacements);
  }

  String getDependsOnLocale(String key, Map<String, dynamic>? founded){
    if(founded == null){
      return key;
    }else{
      return founded[locale!.languageCode] ?? founded[0] ?? key;
    }
  }

  String _replace(String key, [List? words]) {
      Map<String, dynamic>? founded = _localizedStrings[key];
      String translation = getDependsOnLocale(key, founded);
      if (words != null) {
        words.asMap().forEach((index, value) =>
          translation = translation.replaceAll('({$index})', value.toString())
        );
      }
      return translation;
  }


}

class _TranslationServiceDelegate extends LocalizationsDelegate<TranslationService> {

  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _TranslationServiceDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return AppConfig.supportedLanguage.contains(locale.languageCode);
  }

  @override
  Future<TranslationService> load(Locale locale) async {
    // TranslationService class is where the JSON loading actually runs
    TranslationService localizations = TranslationService(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_TranslationServiceDelegate old) => false;
}
