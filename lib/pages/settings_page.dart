import 'package:flutter/material.dart';
import 'package:pesalistas/core/profile_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/edit_profile_dialog.dart';
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

    return userEmail ?? 'User';
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
      showErrorSnackBar(context, 'Failed to load profile', error);
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

      showSuccessSnackBar(context, 'Profile updated');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to update profile', error);
    } finally {
      if (!mounted) return;

      setState(() => editingProfile = false);
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

      showSuccessSnackBar(context, 'Profile synced');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to sync profile', error);
    } finally {
      if (!mounted) return;

      setState(() => syncingProfile = false);
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

      showErrorSnackBar(context, 'Failed to sign out', error);
    } finally {
      if (!mounted) return;

      setState(() => signingOut = false);
    }
  }

  void showComingSoon(String feature) {
    showInfoSnackBar(context, '$feature is coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final busy =
        loadingProfile || syncingProfile || editingProfile || signingOut;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Profile',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Edit display name'),
                        subtitle: const Text(
                          'Change how your name appears to other members.',
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
                        title: const Text('Sync profile from Google'),
                        subtitle: const Text(
                          'Refresh display name and avatar from your auth account.',
                        ),
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
                    title: 'Preferences',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language_outlined),
                        title: const Text('Language'),
                        subtitle: const Text('English for now'),
                        trailing: const _ComingSoonPill(),
                        onTap: () => showComingSoon('Language settings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Theme'),
                        subtitle: const Text('System default for now'),
                        trailing: const _ComingSoonPill(),
                        onTap: () => showComingSoon('Theme settings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_none_outlined),
                        title: const Text('Notifications'),
                        subtitle: const Text('Notification preferences later'),
                        trailing: const _ComingSoonPill(),
                        onTap: () => showComingSoon('Notification settings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsSection(
                    title: 'Account',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign out'),
                        subtitle: const Text('Return to the login screen.'),
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
                  ? const Text('Loading profile...')
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
                          email ?? 'No email available',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile',
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
        'Soon',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
