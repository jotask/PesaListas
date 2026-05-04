// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageDialogTitle => 'Elegir idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageSubtitleSystem => 'Usando el idioma del dispositivo';

  @override
  String get languageSubtitleEnglish => 'Inglés';

  @override
  String get languageSubtitleSpanish => 'Español';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get profileSectionTitle => 'Perfil';

  @override
  String get profileEditDisplayNameTitle => 'Editar nombre visible';

  @override
  String get profileEditDisplayNameSubtitle =>
      'Cambia cómo aparece tu nombre para otros miembros.';

  @override
  String get profileSyncTitle => 'Sincronizar perfil desde Google';

  @override
  String get profileSyncSubtitle =>
      'Actualiza tu nombre y avatar desde tu cuenta de autenticación.';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileSynced => 'Perfil sincronizado';

  @override
  String get profileLoadFailed => 'No se pudo cargar el perfil';

  @override
  String get profileUpdateFailed => 'No se pudo actualizar el perfil';

  @override
  String get profileSyncFailed => 'No se pudo sincronizar el perfil';

  @override
  String get profileLoading => 'Cargando perfil...';

  @override
  String get profileNoEmail => 'No hay email disponible';

  @override
  String get profileEditTooltip => 'Editar perfil';

  @override
  String get preferencesSectionTitle => 'Preferencias';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Español por ahora';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSubtitle => 'Predeterminado del sistema por ahora';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle =>
      'Preferencias de notificaciones más adelante';

  @override
  String get comingSoon => 'Pronto';

  @override
  String comingSoonMessage(Object feature) {
    return '$feature estará disponible pronto';
  }

  @override
  String get languageSettingsFeature => 'Ajustes de idioma';

  @override
  String get themeSettingsFeature => 'Ajustes de tema';

  @override
  String get notificationSettingsFeature => 'Ajustes de notificaciones';

  @override
  String get accountSectionTitle => 'Cuenta';

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutSubtitle => 'Volver a la pantalla de inicio de sesión.';

  @override
  String get signOutFailed => 'No se pudo cerrar sesión';

  @override
  String get editProfileDialogTitle => 'Editar perfil';

  @override
  String get editProfileDisplayNameTitle => 'Nombre visible';

  @override
  String get editProfileDisplayNameSubtitle =>
      'Así aparecerá tu nombre para otros miembros.';

  @override
  String get editProfileDisplayNameLabel => 'Nombre visible';

  @override
  String get editProfileDisplayNameRequired =>
      'El nombre visible es obligatorio.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';
}
