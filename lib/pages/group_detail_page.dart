import 'package:flutter/material.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/create_list_dialog.dart';
import 'package:pesalistas/dialogs/invite_member_dialog.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/widgets/group_detail/group_detail_header.dart';
import 'package:pesalistas/widgets/group_detail/group_lists_section.dart';
import 'package:pesalistas/widgets/group_detail/group_people_section.dart';
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
  bool invitingMember = false;
  bool creatingList = false;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> pendingInvitations = [];
  List<Map<String, dynamic>> lists = [];

  String get groupId => widget.group[AppGroupFields.id].toString();

  String get groupName =>
      widget.group[AppGroupFields.name]?.toString() ?? 'Group';

  String? get groupDescription =>
      widget.group[AppGroupFields.description]?.toString();

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
    if (!mounted) return;

    setState(() => loadingMembers = true);

    try {
      final result = await memberRepository.getGroupMembers(groupId);

      if (!mounted) return;

      setState(() {
        members = result;
        loadingMembers = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingMembers = false);
      showErrorSnackBar(context, 'Failed to load members', error);
    }
  }

  Future<void> loadPendingInvitations() async {
    if (!mounted) return;

    setState(() => loadingInvitations = true);

    try {
      final result = await invitationRepository.getPendingInvitationsForGroup(
        groupId,
      );

      if (!mounted) return;

      setState(() {
        pendingInvitations = result;
        loadingInvitations = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingInvitations = false);
      showErrorSnackBar(context, 'Failed to load pending invitations', error);
    }
  }

  Future<void> loadLists() async {
    if (!mounted) return;

    setState(() => loadingLists = true);

    try {
      final result = await listRepository.getListsForGroup(groupId);

      if (!mounted) return;

      setState(() {
        lists = result;
        loadingLists = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingLists = false);
      showErrorSnackBar(context, 'Failed to load lists', error);
    }
  }

  Future<void> inviteMemberDialog() async {
    if (invitingMember) return;

    final email = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const InviteMemberDialog(),
    );

    if (email == null || email.isEmpty) return;

    setState(() => invitingMember = true);

    try {
      await invitationRepository.inviteToGroup(groupId: groupId, email: email);

      await loadPendingInvitations();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Invitation sent to $email');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to send invitation', error);
    } finally {
      if (!mounted) return;

      setState(() => invitingMember = false);
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    try {
      await invitationRepository.cancelInvitation(invitationId);
      await loadPendingInvitations();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Invitation cancelled');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to cancel invitation', error);
    }
  }

  Future<void> createListDialog() async {
    if (creatingList) return;

    final result = await showDialog<CreateListDialogResult>(
      context: context,
      builder: (_) => const CreateListDialog(),
    );

    if (result == null) return;

    setState(() => creatingList = true);

    try {
      await listRepository.createList(
        groupId: groupId,
        name: result.name,
        listType: result.listType,
      );

      await loadLists();

      if (!mounted) return;

      showSuccessSnackBar(context, 'List "${result.name}" created');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to create list', error);
    } finally {
      if (!mounted) return;

      setState(() => creatingList = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            onPressed: invitingMember ? null : inviteMemberDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Invite member',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadGroupData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GroupDetailHeader(
              groupName: groupName,
              description: groupDescription,
            ),

            const SizedBox(height: 24),

            GroupPeopleSection(
              members: members,
              pendingInvitations: pendingInvitations,
              loadingMembers: loadingMembers,
              loadingInvitations: loadingInvitations,
              invitingMember: invitingMember,
              onInvite: inviteMemberDialog,
              onCancelInvitation: cancelInvitation,
            ),

            const SizedBox(height: 24),

            GroupListsSection(
              lists: lists,
              loading: loadingLists,
              creatingList: creatingList,
              onCreateList: createListDialog,
            ),
          ],
        ),
      ),
    );
  }
}
