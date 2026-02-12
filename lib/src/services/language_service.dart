import 'package:flutter/material.dart';
import 'package:diplomaapp/src/core/setup_locator.dart';
import 'package:diplomaapp/src/services/user_service.dart';
import 'package:diplomaapp/src/shared/data/user_repository.dart';
import 'package:diplomaapp/src/shared/domain/language.dart';
import 'package:diplomaapp/src/utils/other.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  Language _currentLanguage = Language.from("en");
  final translations = ValueNotifier<Map<String, String>>({});

  Language get current => _currentLanguage;

  Future<void> init() async {
    String? langCode = getIt<SharedPreferences>().getString('language');

    await setLanguage(Language.from(langCode ?? "en"));
  }

  Future<void> setLanguage(Language lang) async {
    if (_currentLanguage == lang && translations.value.isNotEmpty) {
      return;
    }

    _currentLanguage = lang;
    await getIt<SharedPreferences>().setString('language', lang.code);

    final acc = getIt<UserService>().currentAccount;

    final decoded = await loadJson("assets/translations/${lang.code}.json");
    translations.value = Map<String, String>.from(decoded);

    if (acc == null) return;

    await getIt<UserRepository>().setLanguage(acc.id!, lang.code);
  }
}
