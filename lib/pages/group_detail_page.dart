import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/create_list_page.dart';
import 'package:pesalistas/pages/edit_group_page.dart';
import 'package:pesalistas/pages/invite_member_page.dart';
import 'package:pesalistas/repositories/group_repository.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/widgets/group_detail/group_lists_section.dart';
import 'package:pesalistas/widgets/group_detail/group_overview_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pesalistas/pages/archived_lists_page.dart';
import 'package:pesalistas/core/fields/member_fields.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';

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
  bool removingMember = false;
  bool updatingMemberRole = false;
  bool transferringOwnership = false;

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
        updatingMemberRole ||
        removingMember ||
        transferringOwnership ||
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

  String? get currentUserRole {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null) return null;

    for (final member in members) {
      final userId = member[AppMemberFields.userId]?.toString();

      if (userId == currentUserId) {
        return member[AppMemberFields.role]?.toString();
      }
    }

    return null;
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

  String memberDisplayName(Map<String, dynamic> member) {
    final profile = member[AppMemberFields.profiles];

    if (profile is Map<String, dynamic>) {
      final displayName = profile[AppProfileFields.displayName]?.toString();

      if (displayName != null && displayName.trim().isNotEmpty) {
        return displayName.trim();
      }

      final username = profile[AppProfileFields.username]?.toString();

      if (username != null && username.trim().isNotEmpty) {
        return username.trim();
      }
    }

    return context.l10n.member;
  }

  Future<void> transferOwnership(Map<String, dynamic> member) async {
    if (transferringOwnership) return;

    final userId = member[AppMemberFields.userId]?.toString();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) return;

    if (currentUserRole != 'owner') {
      showErrorSnackBar(context, 'Only owners can transfer ownership.');
      return;
    }

    if (userId == currentUserId) {
      showErrorSnackBar(context, 'You are already the owner.');
      return;
    }

    final role = member[AppMemberFields.role]?.toString();

    if (role == 'owner') {
      showErrorSnackBar(context, 'This member is already an owner.');
      return;
    }

    final name = memberDisplayName(member);

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: 'Transfer ownership?',
      message:
          'This will make $name the owner of this group. Your role will become admin.',
      deleteLabel: 'Transfer ownership',
    );

    if (!confirmed) return;

    setState(() => transferringOwnership = true);

    try {
      await memberRepository.transferGroupOwnership(
        groupId: groupId,
        newOwnerUserId: userId,
      );

      await loadMembers();

      if (!mounted) return;

      showSuccessSnackBar(context, 'Ownership transferred.');
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, 'Failed to transfer ownership.', error);
    } finally {
      if (mounted) {
        setState(() => transferringOwnership = false);
      }
    }
  }

  Future<void> updateMemberRole({
    required Map<String, dynamic> member,
    required String role,
  }) async {
    if (updatingMemberRole) return;

    final userId = member[AppMemberFields.userId]?.toString();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) return;

    if (currentUserRole != 'owner') {
      showErrorSnackBar(context, context.l10n.onlyOwnersCanChangeRoles);
      return;
    }

    if (userId == currentUserId) {
      showErrorSnackBar(context, context.l10n.cannotRemoveYourself);
      return;
    }

    final currentRole = member[AppMemberFields.role]?.toString();

    if (currentRole == 'owner') {
      showErrorSnackBar(context, context.l10n.ownerRoleCannotBeChanged);
      return;
    }

    final name = memberDisplayName(member);

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.changeRoleTitle,
      message: role == 'admin'
          ? context.l10n.changeRoleToAdminMessage(name)
          : context.l10n.changeRoleToMemberMessage(name),
      deleteLabel: role == 'admin'
          ? context.l10n.makeAdmin
          : context.l10n.makeMember,
    );

    if (!confirmed) return;

    setState(() => updatingMemberRole = true);

    try {
      await memberRepository.updateGroupMemberRole(
        groupId: groupId,
        userId: userId,
        role: role,
      );

      await loadMembers();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.memberRoleUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToUpdateMemberRole, error);
    } finally {
      if (mounted) {
        setState(() => updatingMemberRole = false);
      }
    }
  }

  Future<void> removeMember(Map<String, dynamic> member) async {
    if (removingMember) return;

    final userId = member[AppMemberFields.userId]?.toString();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) return;

    if (userId == currentUserId) {
      showErrorSnackBar(context, context.l10n.cannotRemoveYourself);
      return;
    }

    final role = member[AppMemberFields.role]?.toString();

    if (role == 'owner') {
      showErrorSnackBar(context, context.l10n.ownersCannotBeRemoved);
      return;
    }

    final name = memberDisplayName(member);

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.removeMemberTitle,
      message: context.l10n.removeMemberMessage(name),
      deleteLabel: context.l10n.removeMember,
    );

    if (!confirmed) return;

    setState(() => removingMember = true);

    try {
      await memberRepository.removeGroupMember(
        groupId: groupId,
        userId: userId,
      );

      await loadMembers();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.memberRemoved);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToRemoveMember, error);
    } finally {
      if (mounted) {
        setState(() => removingMember = false);
      }
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

  Future<void> openArchivedLists() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/archived_lists'),
        builder: (_) => ArchivedListsPage(groupId: groupId),
      ),
    );

    if (!mounted) return;

    await loadLists();
  }

  Future<void> editGroup() async {
    if (editingGroup) return;

    final result = await Navigator.of(context).push<EditGroupPageResult>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/edit_group'),
        builder: (_) => EditGroupPage(group: currentGroup),
      ),
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

    final email = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/invite_member'),
        builder: (_) => const InviteMemberPage(),
      ),
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

    final result = await Navigator.of(context).push<CreateListPageResult>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/create_list'),
        builder: (_) => const CreateListPage(),
      ),
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
            currentUserId: Supabase.instance.client.auth.currentUser?.id,
            currentUserRole: currentUserRole,
            onInvite: inviteMember,
            onBack: goBack,
            onEdit: editGroup,
            onCancelInvitation: cancelInvitation,
            onRemoveMember: removeMember,
            onChangeMemberRole: updateMemberRole,
            onTransferOwnership: transferOwnership,
          ),
          if (isBusy) const LinearProgressIndicator(),
          Expanded(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: loadData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ArchivedListsShortcutCard(onTap: openArchivedLists),
                    const SizedBox(height: 12),
                    GroupListsSection(
                      lists: lists,
                      loading: loadingLists,
                      creatingList: creatingList,
                      onCreateList: createList,
                      onListsChanged: loadLists,
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedListsShortcutCard extends StatelessWidget {
  const _ArchivedListsShortcutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.archive_outlined)),
        title: Text(context.l10n.archivedLists),
        subtitle: Text(context.l10n.archivedListsSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
