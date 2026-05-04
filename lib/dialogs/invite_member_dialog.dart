import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class InviteMemberDialog extends StatefulWidget {
  const InviteMemberDialog({super.key});

  @override
  State<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<InviteMemberDialog> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> closeWithEmail() async {
    final email = emailController.text.trim().toLowerCase();

    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    Navigator.of(context).pop(email);
  }

  Future<void> cancel() async {
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.inviteMember),
      content: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          labelText: context.l10n.email,
          hintText: context.l10n.friendExampleCom,
        ),
      ),
      actions: [
        TextButton(onPressed: cancel, child: Text(context.l10n.cancel)),
        ElevatedButton(onPressed: closeWithEmail, child: Text(context.l10n.invite)),
      ],
    );
  }
}
