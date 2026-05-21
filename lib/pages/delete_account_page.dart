import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/repositories/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late final AccountRepository accountRepository;

  bool loading = true;
  bool deleting = false;

  Map<String, dynamic>? dryRunResult;
  AccountDeletionBlockedException? blockedError;
  Object? loadError;

  @override
  void initState() {
    super.initState();

    accountRepository = AccountRepository(Supabase.instance.client);

    runDryRun();
  }

  bool get canDelete {
    return !loading &&
        !deleting &&
        loadError == null &&
        blockedError == null &&
        dryRunResult != null;
  }

  Future<void> openBlockingGroup(AccountDeletionBlockingGroup group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/group_detail'),
        builder: (_) => GroupDetailPage(
          group: {
            AppGroupFields.id: group.id,
            AppGroupFields.name: group.name,
            AppGroupFields.description: group.description,
          },
        ),
      ),
    );

    if (!mounted) return;

    await runDryRun();
  }

  Future<void> runDryRun() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      dryRunResult = null;
      blockedError = null;
      loadError = null;
    });

    try {
      final result = await accountRepository.dryRunDeleteCurrentAccount();

      if (!mounted) return;

      setState(() {
        dryRunResult = result;
        loading = false;
      });
    } on AccountDeletionBlockedException catch (error) {
      if (!mounted) return;

      setState(() {
        blockedError = error;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadError = error;
        loading = false;
      });
    }
  }

  Future<void> confirmAndDeleteAccount() async {
    if (!canDelete) return;

    final confirmed = await showDeleteConfirmationDialog();

    if (confirmed != true) return;

    setState(() => deleting = true);

    try {
      await accountRepository.deleteCurrentAccount();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Account deleted.');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/auth'),
          builder: (_) => const AuthPage(),
        ),
        (_) => false,
      );
    } on AccountDeletionBlockedException catch (error) {
      if (!mounted) return;

      setState(() {
        blockedError = error;
        deleting = false;
      });

      showErrorSnackBar(context, 'Account deletion is blocked.', error);
    } catch (error) {
      if (!mounted) return;

      setState(() => deleting = false);

      showErrorSnackBar(context, 'Account deletion failed.', error);
    }
  }

  Future<bool?> showDeleteConfirmationDialog() async {
    final controller = TextEditingController();
    var typedDelete = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              icon: const Icon(Icons.warning_amber_rounded),
              title: const Text('Delete account?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This will delete your login account and remove your private account data. Shared group content may remain visible to other group members.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Type DELETE to confirm.',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'DELETE',
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        typedDelete = value.trim() == 'DELETE';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: typedDelete
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Delete account'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final blocked = blockedError;
    final error = loadError;
    final result = dryRunResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete account'),
        actions: [
          IconButton(
            tooltip: 'Run check again',
            onPressed: loading || deleting ? null : runDryRun,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loading || deleting) const LinearProgressIndicator(),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _DangerHeaderCard(),
                  const SizedBox(height: 16),
                  if (loading) const _LoadingCard(),
                  if (!loading && blocked != null)
                    _BlockedCard(
                      error: blocked,
                      onOpenGroup: openBlockingGroup,
                    ),
                  if (!loading && error != null) _ErrorCard(error: error),
                  if (!loading && result != null) _ReadyCard(result: result),
                  const SizedBox(height: 16),
                  _WhatWillHappenCard(result: result),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: canDelete ? confirmAndDeleteAccount : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text(
                      deleting ? 'Deleting account...' : 'Delete my account',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: loading || deleting ? null : runDryRun,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Run safety check again'),
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

class _DangerHeaderCard extends StatelessWidget {
  const _DangerHeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This action is permanent. Before deleting your account, PesaListas checks whether your groups would be left without an owner.',
                style: TextStyle(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Checking whether this account can be deleted safely...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedCard extends StatelessWidget {
  const _BlockedCard({required this.error, required this.onOpenGroup});

  final AccountDeletionBlockedException error;
  final void Function(AccountDeletionBlockingGroup group) onOpenGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = error.soleOwnerGroups;

    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error.soleOwnerGroupCount > 0
                        ? 'You cannot delete this account yet because you are the only owner of ${error.soleOwnerGroupCount} group(s).'
                        : 'You cannot delete this account yet because you are the only owner of one or more groups.',
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Transfer ownership to another member, or delete those groups first.',
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (groups.isNotEmpty) ...[
              const SizedBox(height: 14),
              for (final group in groups)
                _BlockingGroupTile(
                  group: group,
                  onTap: () => onOpenGroup(group),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlockingGroupTile extends StatelessWidget {
  const _BlockingGroupTile({required this.group, required this.onTap});

  final AccountDeletionBlockingGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = group.canTransferOwnership
        ? 'Open this group to transfer ownership to another member.'
        : 'This group has no other members. Invite someone or delete the group first.';

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.groups_2_outlined)),
        title: Text(
          group.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SelectableText(
          'Safety check failed:\n$error',
          style: TextStyle(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReadyCard extends StatelessWidget {
  const _ReadyCard({required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final membershipCount = result['membershipCount'] ?? 0;
    final ownedGroupCount = result['ownedGroupCount'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Safety check passed. Memberships: $membershipCount. Owned groups: $ownedGroupCount. You can delete this account.',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatWillHappenCard extends StatelessWidget {
  const _WhatWillHappenCard({required this.result});

  final Map<String, dynamic>? result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What happens when you delete your account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _InfoBullet(
              icon: Icons.login_outlined,
              text: 'Your Supabase Auth login is deleted.',
            ),
            _InfoBullet(
              icon: Icons.person_remove_outlined,
              text: 'Your profile is anonymized as “Deleted user”.',
            ),
            _InfoBullet(
              icon: Icons.group_remove_outlined,
              text: 'Your group memberships are removed.',
            ),
            _InfoBullet(
              icon: Icons.how_to_vote_outlined,
              text:
                  'Your item votes, completions, and assignments are removed.',
            ),
            _InfoBullet(
              icon: Icons.groups_outlined,
              text:
                  'Shared group content may remain for other members unless you delete it first.',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
