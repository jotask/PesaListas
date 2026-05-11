import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class EditProfilePageResult {
  const EditProfilePageResult({required this.displayName});

  final String displayName;
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.profile,
    required this.fallbackDisplayName,
  });

  final Map<String, dynamic>? profile;
  final String fallbackDisplayName;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
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

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final displayName = displayNameController.text.trim();

    setState(() => validationMessage = null);

    if (displayName.isEmpty) {
      setState(
        () => validationMessage = context.l10n.editProfileDisplayNameRequired,
      );
      return;
    }

    Navigator.of(context).pop(EditProfilePageResult(displayName: displayName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editProfileDialogTitle)),
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
              icon: Icons.person_outline,
              title: context.l10n.editProfileDisplayNameTitle,
              subtitle: context.l10n.editProfileDisplayNameSubtitle,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: displayNameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.editProfileDisplayNameLabel,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) => clearValidation(),
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
