import 'package:flutter/material.dart';
import 'app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = AppLocalizations.en;
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.isSupported(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? AppLocalizations.am : AppLocalizations.en;
    notifyListeners();
  }
}
