import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  
  Locale _appLocale = const Locale('ar');

  Locale get appLocale => _appLocale;

  LanguageProvider() {
    _fetchSavedLocale();
  }

  // 4. دالة لتغيير اللغة (يتم استدعاؤها عند الضغط على زر التبديل)
  Future<void> changeLanguage(Locale type) async {
    if (_appLocale == type) {
      return;
    }

    _appLocale = type;
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', type.languageCode);

  
    notifyListeners(); 
  }

  Future<void> _fetchSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _appLocale = Locale(languageCode);
      notifyListeners(); 
    }
  }
}