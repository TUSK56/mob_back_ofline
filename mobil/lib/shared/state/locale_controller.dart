// Persists and exposes the active app [Locale].

import 'package:flutter/widgets.dart';

class LocaleController {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('en'));

  void toggle() {
    locale.value = locale.value.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }
}

