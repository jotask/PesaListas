import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final TextEditingController emailController = TextEditingController();

  String? validationMessage;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  bool isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final email = emailController.text.trim().toLowerCase();

    setState(() => validationMessage = null);

    if (email.isEmpty) {
      setState(() => validationMessage = context.l10n.emailIsRequired);
      return;
    }

    if (!isValidEmail(email)) {
      setState(() => validationMessage = context.l10n.invalidEmail);
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.inviteMember)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.invite,
        primaryIcon: Icons.person_add_alt_1,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.person_add_alt_1,
              title: context.l10n.inviteMember,
              subtitle: context.l10n.inviteMemberPageSubtitle,
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.email,
                    hintText: context.l10n.friendExampleCom,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
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
