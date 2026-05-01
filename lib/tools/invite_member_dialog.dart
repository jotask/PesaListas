import 'package:flutter/material.dart';

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
      title: const Text('Invite member'),
      content: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'friend@example.com',
        ),
      ),
      actions: [
        TextButton(onPressed: cancel, child: const Text('Cancel')),
        ElevatedButton(onPressed: closeWithEmail, child: const Text('Invite')),
      ],
    );
  }
}
