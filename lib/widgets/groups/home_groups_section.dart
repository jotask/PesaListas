import 'package:flutter/material.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/widgets/groups/group_card.dart';

class HomeGroupsSection extends StatelessWidget {
  const HomeGroupsSection({
    super.key,
    required this.groups,
    required this.userEmail,
    required this.creatingGroup,
    required this.onCreateGroup,
  });

  final List<Map<String, dynamic>> groups;
  final String? userEmail;
  final bool creatingGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My groups',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                const Icon(Icons.groups, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'No groups yet',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Logged in as ${userEmail ?? "Unknown user"}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: creatingGroup ? null : onCreateGroup,
                  icon: const Icon(Icons.add),
                  label: const Text('Create your first group'),
                ),
              ],
            ),
          )
        else
          for (final group in groups)
            GroupCard(
              group: group,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupDetailPage(group: group),
                  ),
                );
              },
            ),
      ],
    );
  }
}
