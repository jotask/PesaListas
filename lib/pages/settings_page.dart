import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pesalistas/core/app_locale_controller.dart';
import 'package:pesalistas/core/app_notification_controller.dart';
import 'package:pesalistas/core/app_theme_controller.dart';
import 'package:pesalistas/core/profile_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/edit_profile_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final Future<PackageInfo> packageInfoFuture;

  bool loadingProfile = true;
  bool syncingProfile = false;
  bool editingProfile = false;
  bool signingOut = false;

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    profileRepository = ProfileRepository(client);
    packageInfoFuture = PackageInfo.fromPlatform();

    loadProfile();
  }

  String? get userEmail {
    return authRepository.currentUser?.email;
  }

  String get displayName {
    final value = profile?[AppProfileFields.displayName]?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }

    final metadata = authRepository.currentUser?.userMetadata;
    final metadataName =
        metadata?['full_name']?.toString() ??
        metadata?['name']?.toString() ??
        metadata?['display_name']?.toString();

    if (metadataName != null && metadataName.trim().isNotEmpty) {
      return metadataName.trim();
    }

    return userEmail ?? context.l10n.user;
  }

  String? get avatarUrl {
    final value = profile?[AppProfileFields.avatarUrl]?.toString();

    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }

    final metadata = authRepository.currentUser?.userMetadata;
    final metadataAvatar =
        metadata?['avatar_url']?.toString() ?? metadata?['picture']?.toString();

    if (metadataAvatar != null && metadataAvatar.trim().isNotEmpty) {
      return metadataAvatar.trim();
    }

    return null;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  String get themeSubtitle {
    final themeMode = AppThemeController.themeMode.value;

    switch (themeMode) {
      case ThemeMode.light:
        return context.l10n.themeSubtitleLight;
      case ThemeMode.dark:
        return context.l10n.themeSubtitleDark;
      case ThemeMode.system:
        return context.l10n.themeSubtitleSystem;
    }
  }

  String get languageSubtitle {
    final locale = AppLocaleController.locale.value;

    if (locale == null) {
      return context.l10n.languageSubtitleSystem;
    }

    if (locale.languageCode == 'es') {
      return context.l10n.languageSubtitleSpanish;
    }

    return context.l10n.languageSubtitleEnglish;
  }

  Future<void> chooseLanguage() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        final currentLocale = AppLocaleController.locale.value;
        final currentValue = currentLocale?.languageCode ?? 'system';

        Widget languageTile({
          required String value,
          required String title,
          required String subtitle,
        }) {
          final selected = currentValue == value;

          return ListTile(
            leading: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            onTap: () => Navigator.of(context).pop(value),
          );
        }

        return AlertDialog(
          title: Text(l10n.languageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              languageTile(
                value: 'system',
                title: l10n.languageSystem,
                subtitle: l10n.languageSubtitleSystem,
              ),
              languageTile(
                value: 'en',
                title: l10n.languageEnglish,
                subtitle: l10n.languageSubtitleEnglish,
              ),
              languageTile(
                value: 'es',
                title: l10n.languageSpanish,
                subtitle: l10n.languageSubtitleSpanish,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    switch (selected) {
      case 'system':
        await AppLocaleController.useSystem();
        break;
      case 'en':
        await AppLocaleController.useEnglish();
        break;
      case 'es':
        await AppLocaleController.useSpanish();
        break;
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> chooseTheme() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        final currentThemeMode = AppThemeController.themeMode.value;
        final currentValue = switch (currentThemeMode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        };

        Widget themeTile({
          required String value,
          required String title,
          required String subtitle,
        }) {
          final selected = currentValue == value;

          return ListTile(
            leading: Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            onTap: () => Navigator.of(context).pop(value),
          );
        }

        return AlertDialog(
          title: Text(l10n.themeDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              themeTile(
                value: 'system',
                title: l10n.themeSystem,
                subtitle: l10n.themeSubtitleSystem,
              ),
              themeTile(
                value: 'light',
                title: l10n.themeLight,
                subtitle: l10n.themeSubtitleLight,
              ),
              themeTile(
                value: 'dark',
                title: l10n.themeDark,
                subtitle: l10n.themeSubtitleDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selected == null) return;

    switch (selected) {
      case 'system':
        await AppThemeController.useSystem();
        break;
      case 'light':
        await AppThemeController.useLight();
        break;
      case 'dark':
        await AppThemeController.useDark();
        break;
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> loadProfile() async {
    if (!mounted) return;

    setState(() => loadingProfile = true);

    try {
      final result = await profileRepository.getCurrentProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        loadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingProfile = false);
      showErrorSnackBar(context, context.l10n.profileLoadFailed, error);
    }
  }

  Future<void> editProfile() async {
    if (editingProfile) return;

    final result = await showDialog<EditProfileDialogResult>(
      context: context,
      builder: (_) =>
          EditProfileDialog(profile: profile, fallbackDisplayName: displayName),
    );

    if (result == null) return;

    setState(() => editingProfile = true);

    try {
      final updatedProfile = await profileRepository
          .updateCurrentProfileDisplayName(displayName: result.displayName);

      if (!mounted) return;

      setState(() => profile = updatedProfile ?? profile);

      showSuccessSnackBar(context, context.l10n.profileUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.profileUpdateFailed, error);
    } finally {
      if (mounted) {
        setState(() => editingProfile = false);
      }
    }
  }

  Future<void> syncProfile() async {
    if (syncingProfile) return;

    setState(() => syncingProfile = true);

    try {
      await profileRepository.syncCurrentProfileFromAuth(
        debugLabel: 'SettingsProfileSync',
      );

      final refreshedProfile = await profileRepository.getCurrentProfile();

      if (!mounted) return;

      setState(() => profile = refreshedProfile);

      showSuccessSnackBar(context, context.l10n.profileSynced);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.profileSyncFailed, error);
    } finally {
      if (mounted) {
        setState(() => syncingProfile = false);
      }
    }
  }

  Future<void> signOut() async {
    if (signingOut) return;

    setState(() => signingOut = true);

    try {
      await authRepository.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.signOutFailed, error);
    } finally {
      if (mounted) {
        setState(() => signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        loadingProfile || syncingProfile || editingProfile || signingOut;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: loadProfile,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ProfileHeaderCard(
                      displayName: displayName,
                      email: userEmail,
                      avatarUrl: avatarUrl,
                      initials: initials,
                      loading: loadingProfile,
                      onEdit: editingProfile ? null : editProfile,
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: context.l10n.profileSectionTitle,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(context.l10n.profileEditDisplayNameTitle),
                          subtitle: Text(
                            context.l10n.profileEditDisplayNameSubtitle,
                          ),
                          trailing: editingProfile
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: editingProfile ? null : editProfile,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.sync),
                          title: Text(context.l10n.profileSyncTitle),
                          subtitle: Text(context.l10n.profileSyncSubtitle),
                          trailing: syncingProfile
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: syncingProfile ? null : syncProfile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: context.l10n.preferencesSectionTitle,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: Text(context.l10n.languageTitle),
                          subtitle: Text(languageSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: chooseLanguage,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.dark_mode_outlined),
                          title: Text(context.l10n.themeTitle),
                          subtitle: Text(themeSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: chooseTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _NotificationsSection(),
                    const SizedBox(height: 16),
                    _AboutSection(packageInfoFuture: packageInfoFuture),
                    const SizedBox(height: 16),
                    _SettingsSection(
                      title: context.l10n.accountSectionTitle,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: Text(context.l10n.signOutTitle),
                          subtitle: Text(context.l10n.signOutSubtitle),
                          trailing: signingOut
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: signingOut ? null : signOut,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.initials,
    required this.loading,
    required this.onEdit,
  });

  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String initials;
  final bool loading;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = avatarUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: url == null ? null : NetworkImage(url),
              child: url == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: loading
                  ? Text(context.l10n.profileLoading)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? context.l10n.profileNoEmail,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.profileEditTooltip,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.packageInfoFuture});

  final Future<PackageInfo> packageInfoFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture,
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;

        return _SettingsSection(
          title: context.l10n.about,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.aboutApp),
              subtitle: Text(context.l10n.aboutAppSubtitle),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.tag_outlined),
              title: Text(context.l10n.appVersion),
              subtitle: Text(packageInfo?.version ?? '—'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.numbers_outlined),
              title: Text(context.l10n.buildNumber),
              subtitle: Text(packageInfo?.buildNumber ?? '—'),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppNotificationPreferences>(
      valueListenable: AppNotificationController.preferences,
      builder: (context, preferences, _) {
        final enabled = preferences.enabled;

        return _SettingsSection(
          title: context.l10n.notificationsTitle,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: Text(context.l10n.enableNotifications),
              subtitle: Text(context.l10n.enableNotificationsSubtitle),
              value: preferences.enabled,
              onChanged: (value) async {
                final granted = await AppNotificationController.setEnabled(
                  value,
                );

                if (!granted && context.mounted) {
                  showInfoSnackBar(
                    context,
                    context.l10n.notificationPermissionDenied,
                  );
                }
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.cleaning_services_outlined),
              title: Text(context.l10n.choreReminderNotifications),
              subtitle: Text(context.l10n.choreReminderNotificationsSubtitle),
              value: preferences.choreReminders,
              onChanged: enabled
                  ? AppNotificationController.setChoreReminders
                  : null,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.restaurant_menu_outlined),
              title: Text(context.l10n.mealPlanReminderNotifications),
              subtitle: Text(
                context.l10n.mealPlanReminderNotificationsSubtitle,
              ),
              value: preferences.mealPlanReminders,
              onChanged: enabled
                  ? AppNotificationController.setMealPlanReminders
                  : null,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.shopping_cart_outlined),
              title: Text(context.l10n.shoppingReminderNotifications),
              subtitle: Text(
                context.l10n.shoppingReminderNotificationsSubtitle,
              ),
              value: preferences.shoppingReminders,
              onChanged: enabled
                  ? AppNotificationController.setShoppingReminders
                  : null,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(context.l10n.notificationPreferencesStoredOnDevice),
            ),
          ],
        );
      },
    );
  }
}
