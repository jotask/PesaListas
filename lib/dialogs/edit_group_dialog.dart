import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/group_fields.dart';

class EditGroupDialogResult {
  const EditGroupDialogResult({required this.name, this.description});

  final String name;
  final String? description;
}

class EditGroupDialog extends StatefulWidget {
  const EditGroupDialog({super.key, required this.group});

  final Map<String, dynamic> group;

  @override
  State<EditGroupDialog> createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends State<EditGroupDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  String? validationMessage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.group[AppGroupFields.name]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.group[AppGroupFields.description]?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = S.groupNameIsRequired);
      return;
    }

    Navigator.of(context).pop(
      EditGroupDialogResult(
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.editGroup),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.groups_2_outlined)),
              title: Text(S.groupInfo),
              subtitle: Text(S.updateTheSharedSpaceNameAndDescription),
            ),
            SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: S.groupName),
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
            ),
            SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: S.description,
                hintText: S.optional,
              ),
              minLines: 1,
              maxLines: 4,
            ),
            if (validationMessage != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline, size: 18),
                  SizedBox(width: 8),
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
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.save)),
      ],
    );
  }
}
