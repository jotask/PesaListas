import 'package:flutter/material.dart';
import 'package:pesalistas/core/profile_fields.dart';

class EditProfileDialogResult {
  const EditProfileDialogResult({required this.displayName});

  final String displayName;
}

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.fallbackDisplayName,
  });

  final Map<String, dynamic>? profile;
  final String fallbackDisplayName;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController displayNameController;

  String? validationMessage;

  @override
  void initState() {
    super.initState();

    final existingDisplayName = widget.profile?[AppProfileFields.displayName]
        ?.toString();

    displayNameController = TextEditingController(
      text: existingDisplayName == null || existingDisplayName.trim().isEmpty
          ? widget.fallbackDisplayName
          : existingDisplayName.trim(),
    );
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  void submit() {
    final displayName = displayNameController.text.trim();

    setState(() => validationMessage = null);

    if (displayName.isEmpty) {
      setState(() => validationMessage = 'Display name is required.');
      return;
    }

    Navigator.of(
      context,
    ).pop(EditProfileDialogResult(displayName: displayName));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('Display name'),
              subtitle: Text('This is how your name appears to other members.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: displayNameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Display name'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(),
              onChanged: (_) {
                if (validationMessage != null) {
                  setState(() => validationMessage = null);
                }
              },
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Save')),
      ],
    );
  }
}
