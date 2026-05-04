// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageDialogTitle => 'Choose language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageSubtitleSystem => 'Using device language';

  @override
  String get languageSubtitleEnglish => 'English';

  @override
  String get languageSubtitleSpanish => 'Spanish';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSectionTitle => 'Profile';

  @override
  String get profileEditDisplayNameTitle => 'Edit display name';

  @override
  String get profileEditDisplayNameSubtitle =>
      'Change how your name appears to other members.';

  @override
  String get profileSyncTitle => 'Sync profile from Google';

  @override
  String get profileSyncSubtitle =>
      'Refresh display name and avatar from your auth account.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get profileSynced => 'Profile synced';

  @override
  String get profileLoadFailed => 'Failed to load profile';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get profileSyncFailed => 'Failed to sync profile';

  @override
  String get profileLoading => 'Loading profile...';

  @override
  String get profileNoEmail => 'No email available';

  @override
  String get profileEditTooltip => 'Edit profile';

  @override
  String get preferencesSectionTitle => 'Preferences';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'English for now';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'System default for now';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Notification preferences later';

  @override
  String get comingSoon => 'Soon';

  @override
  String comingSoonMessage(Object feature) {
    return '$feature is coming soon';
  }

  @override
  String get languageSettingsFeature => 'Language settings';

  @override
  String get themeSettingsFeature => 'Theme settings';

  @override
  String get notificationSettingsFeature => 'Notification settings';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String get signOutTitle => 'Sign out';

  @override
  String get signOutSubtitle => 'Return to the login screen.';

  @override
  String get signOutFailed => 'Failed to sign out';

  @override
  String get editProfileDialogTitle => 'Edit profile';

  @override
  String get editProfileDisplayNameTitle => 'Display name';

  @override
  String get editProfileDisplayNameSubtitle =>
      'This is how your name appears to other members.';

  @override
  String get editProfileDisplayNameLabel => 'Display name';

  @override
  String get editProfileDisplayNameRequired => 'Display name is required.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';
}
