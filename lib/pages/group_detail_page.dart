import 'package:flutter/material.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/dialogs/create_list_dialog.dart';
import 'package:pesalistas/dialogs/invite_member_dialog.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';
import 'package:pesalistas/widgets/group_detail/group_list_card.dart';
import 'package:pesalistas/widgets/group_detail/member_card.dart';
import 'package:pesalistas/widgets/group_detail/pending_group_invite_card.dart';
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
              const EmptyInfoCard(
                icon: Icons.person_off,
                title: 'No members found',
                subtitle: 'Members will appear here.',
              )
            else
              for (final member in members) MemberCard(member: member),

            const SizedBox(height: 24),

            const Text(
              'Pending invites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (loadingInvitations)
              const Center(child: CircularProgressIndicator())
            else if (pendingInvitations.isEmpty)
              const EmptyInfoCard(
                icon: Icons.person_off,
                title: 'No pending invites',
                subtitle: 'Invited people will appear here.',
              )
            else
              for (final invitation in pendingInvitations)
                PendingGroupInviteCard(
                  invitation: invitation,
                  onCancel: () => cancelInvitation(invitation['id']),
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
                ),
              )
            else
              for (final list in lists)
                GroupListCard(
                  list: list,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListDetailPage(list: list),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
