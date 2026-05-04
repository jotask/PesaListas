import 'package:flutter/widgets.dart';
import 'package:pesalistas/core/app_locale_controller.dart';
import 'package:pesalistas/l10n/app_localizations.dart';
import 'package:pesalistas/l10n/app_localizations_en.dart';
import 'package:pesalistas/l10n/app_localizations_es.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Fallback localization access for legacy getters/helpers that do not receive
/// a BuildContext yet. Prefer BuildContext.l10n in new UI code.
final dynamic context = _FallbackLocalizationContext();

class _FallbackLocalizationContext {
  AppLocalizations get l10n {
    final forcedLocale = AppLocaleController.locale.value?.languageCode;
    if (forcedLocale == 'es') return AppLocalizationsEs();

    final platformLocale = WidgetsBinding
        .instance.platformDispatcher.locale.languageCode;
    if (platformLocale == 'es' && forcedLocale == null) {
      return AppLocalizationsEs();
    }

    return AppLocalizationsEn();
  }
}
