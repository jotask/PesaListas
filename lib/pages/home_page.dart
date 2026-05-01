import 'package:flutter/material.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/group_detail_page.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/group_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GroupRepository groupRepository;

  bool loading = true;
  List<Map<String, dynamic>> groups = [];

  late final InvitationRepository invitationRepository;
  List<Map<String, dynamic>> invitations = [];

  @override
  void initState() {
    super.initState();
    groupRepository = GroupRepository(Supabase.instance.client);
    invitationRepository = InvitationRepository(Supabase.instance.client);
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    setState(() => loading = true);

    await Future.wait([loadGroups(), loadInvitations()]);

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> loadGroups() async {
    try {
      final result = await groupRepository.getMyGroups();

      if (!mounted) return;

      setState(() {
        groups = result;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load groups: $error')));
    }
  }

  Future<void> loadInvitations() async {
    try {
      final result = await invitationRepository.getPendingInvitations();

      if (!mounted) return;

      setState(() {
        invitations = result;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load invitations: $error')),
      );
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    await invitationRepository.acceptInvitation(invitationId);
    await loadHomeData();
  }

  Future<void> createGroupDialog() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create group'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'Me and Partner',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    await groupRepository.createGroup(name: name);
    await loadGroups();
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My groups'),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createGroupDialog,
        icon: const Icon(Icons.add),
        label: const Text('New group'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHomeData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Pending invitations',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (invitations.isEmpty)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.mark_email_read_outlined),
                        ),
                        title: const Text('No pending invitations'),
                        subtitle: const Text('Group invites will appear here.'),
                      ),
                    )
                  else
                    for (final invitation in invitations)
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.mail_outline),
                          ),
                          title: Text(
                            invitation['groups']?['name'] ?? 'Group invitation',
                          ),
                          subtitle: Text(
                            'Invited as ${invitation['role'] ?? 'member'}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => acceptInvitation(invitation['id']),
                            child: const Text('Accept'),
                          ),
                        ),
                      ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 12),

                  for (final invitation in invitations)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.mail_outline),
                        ),
                        title: Text(
                          invitation['groups']?['name'] ?? 'Group invitation',
                        ),
                        subtitle: Text(
                          'Invited as ${invitation['role'] ?? 'member'}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => acceptInvitation(invitation['id']),
                          child: const Text('Accept'),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Logged in as ${user?.email ?? "Unknown user"}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: createGroupDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first group'),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final group in groups)
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.groups),
                          ),
                          title: Text(group['name'] ?? 'Untitled group'),
                          subtitle: Text(
                            group['description'] ?? 'Shared space',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GroupDetailPage(group: group),
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
