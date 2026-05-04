import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class EditListDialogResult {
  const EditListDialogResult({required this.name, this.description});

  final String name;
  final String? description;
}

class EditListDialog extends StatefulWidget {
  const EditListDialog({super.key, required this.list});

  final Map<String, dynamic> list;

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  String? validationMessage;

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

  String get listType {
    return widget.list[AppListFields.listType]?.toString() ??
        AppListTypes.generic.value;
  }

  AppListTypeConfig get config {
    return AppListTypes.fromValue(listType);
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
      EditListDialogResult(
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listConfig = config;

    return AlertDialog(
      title: Text(context.l10n.editList),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(listConfig.icon)),
              title: Text(context.l10n.editListInfo),
              subtitle: Text(context.l10n.updateListNameAndDescription),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: context.l10n.listName),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.description,
                hintText: context.l10n.optional,
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(labelText: context.l10n.listType),
              child: Row(
                children: [
                  Icon(listConfig.icon, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      listConfig.label(context),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.listTypeCannotBeChangedYet,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (validationMessage != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(context.l10n.save)),
      ],
    );
  }
}
