import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/settings_store.dart';

/// Language codes the app is translated into.
const supportedLanguageCodes = ['fr', 'ar', 'en'];

class AppPreferences extends Equatable {
  /// 'system' (follow the phone), 'fr', 'ar' or 'en'.
  final String language;
  final ThemeMode themeMode;

  const AppPreferences({
    this.language = 'system',
    this.themeMode = ThemeMode.system,
  });

  /// The forced locale, or null to follow the phone.
  Locale? get locale => language == 'system' ? null : Locale(language);

  @override
  List<Object?> get props => [language, themeMode];
}

/// Language and light/dark choice of this phone, saved in [SettingsStore].
class AppPreferencesCubit extends Cubit<AppPreferences> {
  final SettingsStore settings;

  AppPreferencesCubit(this.settings)
      : super(AppPreferences(
          language: _validLanguage(settings.get(SettingsKeys.language)),
          themeMode: _parseTheme(settings.get(SettingsKeys.themeMode)),
        ));

  Future<void> setLanguage(String language) async {
    final value = _validLanguage(language);
    await settings.set(SettingsKeys.language, value);
    emit(AppPreferences(language: value, themeMode: state.themeMode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await settings.set(SettingsKeys.themeMode, mode.name);
    emit(AppPreferences(language: state.language, themeMode: mode));
  }

  static String _validLanguage(String? value) =>
      supportedLanguageCodes.contains(value) ? value! : 'system';

  static ThemeMode _parseTheme(String? value) => ThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => ThemeMode.system,
      );
}

/// Picks the language when "follow the phone" is chosen: the phone's
/// language if the app knows it, otherwise French.
Locale resolveAppLocale(Locale? phoneLocale, Iterable<Locale> supported) {
  if (phoneLocale != null &&
      supported.any((l) => l.languageCode == phoneLocale.languageCode)) {
    return Locale(phoneLocale.languageCode);
  }
  return const Locale('fr');
}
