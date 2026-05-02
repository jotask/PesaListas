import 'package:flutter/material.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.member});

  final Map<String, dynamic> member;

  @override
  Widget build(BuildContext context) {
    final profile = member['profiles'];

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(
          profile?['display_name'] ?? profile?['username'] ?? 'Unknown user',
        ),
        subtitle: Text('Role: ${member['role'] ?? 'member'}'),
      ),
    );
  }
}
