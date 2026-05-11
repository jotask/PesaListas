import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

enum EditListPageAction { save, archive, delete }

class EditListPageResult {
  const EditListPageResult({required this.action, this.name, this.description});

  final EditListPageAction action;
  final String? name;
  final String? description;
}

class EditListPage extends StatefulWidget {
  const EditListPage({super.key, required this.list});

  final Map<String, dynamic> list;

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  String? validationMessage;

  String get listType {
    return widget.list[AppListFields.listType]?.toString() ??
        AppListTypes.generic.value;
  }

  AppListTypeConfig get config {
    return AppListTypes.fromValue(listType);
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.list[AppListFields.name]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.list[AppListFields.description]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.listNameIsRequired);
      return;
    }

    Navigator.of(context).pop(
      EditListPageResult(
        action: EditListPageAction.save,
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  void archive() {
    Navigator.of(
      context,
    ).pop(const EditListPageResult(action: EditListPageAction.archive));
  }

  void delete() {
    Navigator.of(
      context,
    ).pop(const EditListPageResult(action: EditListPageAction.delete));
  }

  @override
  Widget build(BuildContext context) {
    final listConfig = config;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editList)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.save,
        primaryIcon: Icons.save_outlined,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: listConfig.icon,
              title: context.l10n.editListInfo,
              subtitle: context.l10n.updateListNameAndDescription,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.listName,
                    prefixIcon: const Icon(Icons.list_alt_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _ListTypeInfoCard(config: listConfig),
            const SizedBox(height: 16),
            _DangerZoneCard(onArchive: archive, onDelete: delete),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _ListTypeInfoCard extends StatelessWidget {
  const _ListTypeInfoCard({required this.config});

  final AppListTypeConfig config;

  @override
  Widget build(BuildContext context) {
    return AppFormSectionCard(
      children: [
        Row(
          children: [
            CircleAvatar(child: Icon(config.icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.listType,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(config.label(context)),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.listTypeCannotBeChangedYet,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({required this.onArchive, required this.onDelete});

  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.dangerZone,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.archiveListMessage,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onArchive,
                    icon: const Icon(Icons.archive_outlined),
                    label: Text(context.l10n.archive),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.l10n.deleteList),
                    style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
