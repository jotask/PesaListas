import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/app_locale_controller.dart';
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

    return userEmail ?? S.user;
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
        AppLocaleController.useSystem();
        break;
      case 'en':
        AppLocaleController.useEnglish();
        break;
      case 'es':
        AppLocaleController.useSpanish();
        break;
    }
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

      showErrorSnackBar(context, S.profileUpdateFailed, error);
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

  void showComingSoon(String feature) {
    showInfoSnackBar(context, context.l10n.comingSoonMessage(feature));
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
                  SizedBox(height: 16),
                  _SettingsSection(
                    title: S.profileSectionTitle,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text(S.profileEditDisplayNameTitle),
                        subtitle: Text(S.profileEditDisplayNameSubtitle),
                        trailing: editingProfile
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.chevron_right),
                        onTap: editingProfile ? null : editProfile,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.sync),
                        title: Text(S.profileSyncTitle),
                        subtitle: Text(S.profileSyncSubtitle),
                        trailing: syncingProfile
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.chevron_right),
                        onTap: syncingProfile ? null : syncProfile,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SettingsSection(
                    title: S.preferencesSectionTitle,
                    children: [
                      ListTile(
                        leading: Icon(Icons.language_outlined),
                        title: Text(context.l10n.languageTitle),
                        subtitle: Text(languageSubtitle),
                        trailing: Icon(Icons.chevron_right),
                        onTap: chooseLanguage,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.dark_mode_outlined),
                        title: Text(S.themeTitle),
                        subtitle: Text(S.themeSubtitle),
                        trailing: const _ComingSoonPill(),
                        onTap: () => showComingSoon(S.themeSettingsFeature),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.notifications_none_outlined),
                        title: Text(S.notificationsTitle),
                        subtitle: Text(S.notificationsSubtitle),
                        trailing: const _ComingSoonPill(),
                        onTap: () =>
                            showComingSoon(S.notificationSettingsFeature),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SettingsSection(
                    title: S.accountSectionTitle,
                    children: [
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text(S.signOutTitle),
                        subtitle: Text(S.signOutSubtitle),
                        trailing: signingOut
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.chevron_right),
                        onTap: signingOut ? null : signOut,
                      ),
                    ],
                  ),
                ],
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
            SizedBox(width: 16),
            Expanded(
              child: loading
                  ? Text(S.profileLoading)
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
                        SizedBox(height: 4),
                        Text(
                          email ?? S.profileNoEmail,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
            SizedBox(width: 8),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined),
              tooltip: S.profileEditTooltip,
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

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        S.comingSoon,
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
