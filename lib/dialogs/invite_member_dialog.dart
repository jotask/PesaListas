import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';

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
      title: Text(S.inviteMember),
      content: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          labelText: S.email,
          hintText: S.friendExampleCom,
        ),
      ),
      actions: [
        TextButton(onPressed: cancel, child: Text(S.cancel)),
        ElevatedButton(onPressed: closeWithEmail, child: Text(S.invite)),
      ],
    );
  }
}
