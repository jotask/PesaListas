import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void submit() {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.createGroup),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: S.groupName,
          hintText: S.meAndPartner,
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        ElevatedButton(onPressed: submit, child: Text(S.create)),
      ],
    );
  }
}
