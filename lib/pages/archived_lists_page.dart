import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArchivedListsPage extends StatefulWidget {
  const ArchivedListsPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<ArchivedListsPage> createState() => _ArchivedListsPageState();
}

class _ArchivedListsPageState extends State<ArchivedListsPage> {
  late final ListRepository listRepository;

  bool loading = true;
  bool restoringList = false;
  bool deletingList = false;

  List<Map<String, dynamic>> archivedLists = [];

  bool get busy => loading || restoringList || deletingList;

  @override
  void initState() {
    super.initState();

    listRepository = ListRepository(Supabase.instance.client);
    loadArchivedLists();
  }

  Future<void> loadArchivedLists() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final result = await listRepository.getArchivedListsForGroup(
        widget.groupId,
      );

      if (!mounted) return;

      setState(() {
        archivedLists = result;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loading = false);
      showErrorSnackBar(context, context.l10n.failedToLoadArchivedLists, error);
    }
  }

  Future<void> restoreList(String listId) async {
    if (restoringList || deletingList) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.restoreListTitle,
      message: context.l10n.restoreListMessage,
      deleteLabel: context.l10n.restore,
    );

    if (!confirmed) return;

    setState(() => restoringList = true);

    try {
      await listRepository.restoreList(listId);
      await loadArchivedLists();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.listRestored);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToRestoreList, error);
    } finally {
      if (mounted) {
        setState(() => restoringList = false);
      }
    }
  }

  Future<void> deleteList(String listId) async {
    if (restoringList || deletingList) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteListTitle,
      message: context.l10n.deleteListMessage,
      deleteLabel: context.l10n.deleteList,
    );

    if (!confirmed) return;

    setState(() => deletingList = true);

    try {
      await listRepository.deleteList(listId);
      await loadArchivedLists();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.listDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeleteList, error);
    } finally {
      if (mounted) {
        setState(() => deletingList = false);
      }
    }
  }

  void goBack() {
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.archivedLists)),
      body: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadArchivedLists,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : archivedLists.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _EmptyArchivedListsCard(onRefresh: loadArchivedLists),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final list = archivedLists[index];

                        return _ArchivedListCard(
                          list: list,
                          disabled: restoringList || deletingList,
                          onRestore: () {
                            restoreList(list[AppListFields.id].toString());
                          },
                          onDelete: () {
                            deleteList(list[AppListFields.id].toString());
                          },
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemCount: archivedLists.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyArchivedListsCard extends StatelessWidget {
  const _EmptyArchivedListsCard({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                Icons.archive_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.noArchivedListsYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.noArchivedListsSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedListCard extends StatelessWidget {
  const _ArchivedListCard({
    required this.list,
    required this.disabled,
    required this.onRestore,
    required this.onDelete,
  });

  final Map<String, dynamic> list;
  final bool disabled;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  String name(BuildContext context) {
    final value = list[AppListFields.name]?.toString();

    if (value == null || value.trim().isEmpty) {
      return context.l10n.untitledList;
    }

    return value.trim();
  }

  String? get description {
    final value = list[AppListFields.description]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  AppListTypeConfig get config {
    return AppListTypes.fromValue(list[AppListFields.listType]?.toString());
  }

  String? get archivedDate {
    final value = list[AppListFields.archivedAt]?.toString();

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listConfig = config;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(
                listConfig.icon,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description ?? listConfig.description(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ArchivedListPill(
                        icon: listConfig.icon,
                        label: listConfig.label(context),
                      ),
                      if (archivedDate != null)
                        _ArchivedListPill(
                          icon: Icons.archive_outlined,
                          label: archivedDate!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: disabled ? null : onRestore,
                          icon: const Icon(Icons.unarchive_outlined),
                          label: Text(context.l10n.restore),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: disabled ? null : onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: context.l10n.deleteList,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedListPill extends StatelessWidget {
  const _ArchivedListPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
