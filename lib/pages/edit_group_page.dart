import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class EditGroupPageResult {
  const EditGroupPageResult({required this.name, this.description});

  final String name;
  final String? description;
}

class EditGroupPage extends StatefulWidget {
  const EditGroupPage({super.key, required this.group});

  final Map<String, dynamic> group;

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
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

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.groupNameIsRequired);
      return;
    }

    Navigator.of(context).pop(
      EditGroupPageResult(
        name: name,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editGroup)),
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
              icon: Icons.groups_2_outlined,
              title: context.l10n.groupInfo,
              subtitle: context.l10n.updateTheSharedSpaceNameAndDescription,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.groupName,
                    prefixIcon: const Icon(Icons.group_outlined),
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
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}
