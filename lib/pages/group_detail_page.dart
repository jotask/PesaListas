import 'package:flutter/material.dart';
import 'package:pesalistas/core/group_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/dialogs/create_list_dialog.dart';
import 'package:pesalistas/dialogs/edit_group_dialog.dart';
import 'package:pesalistas/dialogs/invite_member_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/repositories/group_repository.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/widgets/group_detail/group_lists_section.dart';
import 'package:pesalistas/widgets/group_detail/group_overview_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.group});

  final Map<String, dynamic> group;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late final GroupRepository groupRepository;
  late final MemberRepository memberRepository;
  late final InvitationRepository invitationRepository;
  late final ListRepository listRepository;

  bool loadingMembers = true;
  bool loadingInvitations = true;
  bool loadingLists = true;
  bool invitingMember = false;
  bool cancellingInvitation = false;
  bool creatingList = false;
  bool editingGroup = false;

  late Map<String, dynamic> currentGroup;

  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> pendingInvitations = [];
  List<Map<String, dynamic>> lists = [];

  String get groupId => currentGroup[AppGroupFields.id].toString();

  bool get loadingPeople => loadingMembers || loadingInvitations;

  bool get isBusy {
    return invitingMember ||
        cancellingInvitation ||
        creatingList ||
        editingGroup ||
        loadingPeople;
  }

  @override
  void initState() {
    super.initState();

    currentGroup = Map<String, dynamic>.from(widget.group);

    final client = Supabase.instance.client;

    groupRepository = GroupRepository(client);
    memberRepository = MemberRepository(client);
    invitationRepository = InvitationRepository(client);
    listRepository = ListRepository(client);

    loadData();
  }

  Future<void> loadData() async {
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
      showErrorSnackBar(context, context.l10n.failedToLoadMembers, error);
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
      showErrorSnackBar(context, context.l10n.failedToLoadInvitations, error);
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
      showErrorSnackBar(context, context.l10n.failedToLoadLists, error);
    }
  }

  Future<void> editGroup() async {
    if (editingGroup) return;

    final result = await showDialog<EditGroupDialogResult>(
      context: context,
      builder: (_) => EditGroupDialog(group: currentGroup),
    );

    if (result == null) return;

    setState(() => editingGroup = true);

    try {
      await groupRepository.updateGroup(
        groupId: groupId,
        name: result.name,
        description: result.description,
      );

      if (!mounted) return;

      setState(() {
        currentGroup = {
          ...currentGroup,
          AppGroupFields.name: result.name,
          AppGroupFields.description: result.description,
        };
      });

      showSuccessSnackBar(context, context.l10n.groupUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToUpdateGroup, error);
    } finally {
      if (mounted) {
        setState(() => editingGroup = false);
      }
    }
  }

  Future<void> inviteMember() async {
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

      showSuccessSnackBar(context, context.l10n.invitationSentTo(email));
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToInviteMember, error);
    } finally {
      if (mounted) {
        setState(() => invitingMember = false);
      }
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    if (cancellingInvitation) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.cancelInvitationTitle,
      message: context.l10n.cancelInvitationMessage,
      deleteLabel: context.l10n.cancelInvitation,
    );

    if (!confirmed) return;

    setState(() => cancellingInvitation = true);

    try {
      await invitationRepository.cancelInvitation(invitationId);
      await loadPendingInvitations();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.invitationCancelled);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCancelInvitation, error);
    } finally {
      if (mounted) {
        setState(() => cancellingInvitation = false);
      }
    }
  }

  Future<void> createList() async {
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

      showSuccessSnackBar(
        context,
        context.l10n.listCreatedWithName(result.name),
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCreateList, error);
    } finally {
      if (mounted) {
        setState(() => creatingList = false);
      }
    }
  }

  void goBack() {
    Navigator.of(context).maybePop(currentGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: creatingList ? null : createList,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newList),
      ),
      body: Column(
        children: [
          GroupOverviewCard(
            group: currentGroup,
            members: members,
            pendingInvitations: pendingInvitations,
            onInvite: inviteMember,
            onBack: goBack,
            onEdit: editGroup,
            onCancelInvitation: cancelInvitation,
          ),
          if (isBusy) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GroupListsSection(
                    lists: lists,
                    loading: loadingLists,
                    creatingList: creatingList,
                    onCreateList: createList,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
