import 'package:flutter/material.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/tools/create_list_dialog.dart';
import 'package:pesalistas/tools/invite_member_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.group});

  final Map<String, dynamic> group;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late final InvitationRepository invitationRepository;
  late final MemberRepository memberRepository;
  late final ListRepository listRepository;

  bool loadingMembers = true;
  bool loadingInvitations = true;
  bool loadingLists = true;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> pendingInvitations = [];
  List<Map<String, dynamic>> lists = [];

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    invitationRepository = InvitationRepository(client);
    memberRepository = MemberRepository(client);
    listRepository = ListRepository(client);

    loadGroupData();
  }

  Future<void> loadGroupData() async {
    await Future.wait([loadMembers(), loadPendingInvitations(), loadLists()]);
  }

  Future<void> loadMembers() async {
    setState(() => loadingMembers = true);

    final result = await memberRepository.getGroupMembers(widget.group['id']);

    if (!mounted) return;

    setState(() {
      members = result;
      loadingMembers = false;
    });
  }

  Future<void> loadPendingInvitations() async {
    setState(() => loadingInvitations = true);

    final result = await invitationRepository.getPendingInvitationsForGroup(
      widget.group['id'],
    );

    if (!mounted) return;

    setState(() {
      pendingInvitations = result;
      loadingInvitations = false;
    });
  }

  Future<void> loadLists() async {
    setState(() => loadingLists = true);

    final result = await listRepository.getListsForGroup(widget.group['id']);

    if (!mounted) return;

    setState(() {
      lists = result;
      loadingLists = false;
    });
  }

  Future<void> inviteMemberDialog() async {
    final email = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const InviteMemberDialog(),
    );

    if (email == null || email.isEmpty) return;

    try {
      await invitationRepository.inviteToGroup(
        groupId: widget.group['id'],
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invitation sent to $email')));

      await loadPendingInvitations();
    } catch (error, stackTrace) {
      debugPrint('INVITE ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    try {
      await invitationRepository.cancelInvitation(invitationId);
      await loadPendingInvitations();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitation cancelled')));
    } catch (error, stackTrace) {
      debugPrint('CANCEL INVITE ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  Future<void> createListDialog() async {
    final result = await showDialog<CreateListDialogResult>(
      context: context,
      builder: (_) => const CreateListDialog(),
    );

    if (result == null) return;

    try {
      await listRepository.createList(
        groupId: widget.group['id'],
        name: result.name,
        listType: result.listType,
      );

      await loadLists();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('List "${result.name}" created')));
    } catch (error, stackTrace) {
      debugPrint('CREATE LIST ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = widget.group['name'] ?? 'Group';
    final description = widget.group['description'];

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            onPressed: inviteMemberDialog,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadGroupData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.groups)),
                title: Text(groupName),
                subtitle: Text(description ?? 'Shared space'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (loadingMembers)
              const Center(child: CircularProgressIndicator())
            else if (members.isEmpty)
              const Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person_off)),
                  title: Text('No members found'),
                ),
              )
            else
              for (final member in members)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      member['profiles']?['display_name'] ??
                          member['profiles']?['username'] ??
                          'Unknown user',
                    ),
                    subtitle: Text('Role: ${member['role'] ?? 'member'}'),
                  ),
                ),

            const SizedBox(height: 24),

            const Text(
              'Pending invites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (loadingInvitations)
              const Center(child: CircularProgressIndicator())
            else if (pendingInvitations.isEmpty)
              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.mark_email_read_outlined),
                  ),
                  title: Text('No pending invites'),
                  subtitle: Text('Invited people will appear here.'),
                ),
              )
            else
              for (final invitation in pendingInvitations)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.mail_outline),
                    ),
                    title: Text(invitation['invited_email'] ?? 'Unknown email'),
                    subtitle: Text('Role: ${invitation['role'] ?? 'member'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel invitation',
                      onPressed: () => cancelInvitation(invitation['id']),
                    ),
                  ),
                ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lists',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: createListDialog,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            if (loadingLists)
              const Center(child: CircularProgressIndicator())
            else if (lists.isEmpty)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.list_alt)),
                  title: const Text('No lists yet'),
                  subtitle: const Text('Create your first shared list here.'),
                  trailing: const Icon(Icons.add),
                  onTap: createListDialog,
                ),
              )
            else
              for (final list in lists)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.list_alt)),
                    title: Text(list['name'] ?? 'Untitled list'),
                    subtitle: Text(list['list_type'] ?? 'generic'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListDetailPage(list: list),
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
