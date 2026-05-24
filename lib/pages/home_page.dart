import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/create_group_page.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/pages/settings_page.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/group_repository.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/profile_repository.dart';
import 'package:pesalistas/widgets/home/home_attention_section.dart';
import 'package:pesalistas/widgets/home/home_lists_section.dart';
import 'package:pesalistas/widgets/home/pending_invitations_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AuthRepository authRepository;
  late final GroupRepository groupRepository;
  late final ListRepository listRepository;
  late final InvitationRepository invitationRepository;
  late final ProfileRepository profileRepository;

  bool loading = true;
  bool acceptingInvitation = false;
  bool decliningInvitation = false;
  bool creatingGroup = false;
  bool signingOut = false;

  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> lists = [];
  Map<String, String> listSummaries = {};
  List<Map<String, dynamic>> invitations = [];
  HomeAttentionSummary attentionSummary = const HomeAttentionSummary();

  bool get processingInvitation => acceptingInvitation || decliningInvitation;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    groupRepository = GroupRepository(client);
    listRepository = ListRepository(client);
    invitationRepository = InvitationRepository(client);
    profileRepository = ProfileRepository(client);

    unawaited(
      profileRepository.syncCurrentProfileFromAuth(
        debugLabel: 'HomePageProfileSync',
      ),
    );

    loadHomeData();
  }

  Future<void> loadHomeData() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final invitationsFuture = invitationRepository.getPendingInvitations();
      final loadedGroups = await groupRepository.getMyGroups();

      final groupIds = loadedGroups
          .map((group) => group[AppGroupFields.id]?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      final loadedLists = await listRepository.getListsForGroups(groupIds);
      final loadedListSummaries = await listRepository.getHomeListSummaries(
        loadedLists,
      );

      final loadedAttentionSummary = await listRepository
          .getHomeAttentionSummary(groups: loadedGroups, lists: loadedLists);

      final loadedInvitations = await invitationsFuture;

      if (!mounted) return;

      setState(() {
        groups = loadedGroups;
        lists = loadedLists;
        invitations = loadedInvitations;
        listSummaries = loadedListSummaries;
        attentionSummary = loadedAttentionSummary;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loading = false);
      showErrorSnackBar(context, context.l10n.failedToLoadHomeData, error);
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    if (processingInvitation) return;

    setState(() => acceptingInvitation = true);

    try {
      await invitationRepository.acceptInvitation(invitationId);
      await loadHomeData();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.invitationAccepted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToAcceptInvitation, error);
    } finally {
      if (mounted) {
        setState(() => acceptingInvitation = false);
      }
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    if (processingInvitation) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.declineInvitationTitle,
      message: context.l10n.declineInvitationMessage,
      deleteLabel: context.l10n.decline,
    );

    if (!confirmed) return;

    setState(() => decliningInvitation = true);

    try {
      await invitationRepository.declineInvitation(invitationId);
      await loadHomeData();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.invitationDeclined);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeclineInvitation, error);
    } finally {
      if (mounted) {
        setState(() => decliningInvitation = false);
      }
    }
  }

  Future<void> createGroupDialog() async {
    if (creatingGroup) return;

    final result = await Navigator.of(context).push<CreateGroupPageResult>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/create_group'),
        builder: (_) => const CreateGroupPage(),
      ),
    );

    if (result == null) return;

    setState(() => creatingGroup = true);

    try {
      await groupRepository.createGroup(
        name: result.name,
        description: result.description,
      );

      await loadHomeData();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.groupCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCreateGroup, error);
    } finally {
      if (mounted) {
        setState(() => creatingGroup = false);
      }
    }
  }

  Future<void> signOut() async {
    if (signingOut) return;

    setState(() => signingOut = true);

    try {
      await authRepository.signOut();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/auth'),
          builder: (_) => const AuthPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.signOutFailed, error);
    } finally {
      if (mounted) {
        setState(() => signingOut = false);
      }
    }
  }

  Map<String, dynamic>? firstListOfType(String listType) {
    for (final list in lists) {
      if (list[AppListFields.listType]?.toString() == listType) {
        return list;
      }
    }

    return null;
  }

  Future<void> openHomeListType(String listType) async {
    final list = firstListOfType(listType);

    if (list == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/list_detail'),
        builder: (_) => ListDetailPage(list: list),
      ),
    );

    if (!mounted) return;

    await loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/settings'),
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.settingsTitle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: creatingGroup ? null : createGroupDialog,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.newGroup),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadHomeData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PendingInvitationsSection(
                    invitations: invitations,
                    loading: false,
                    processingInvitation: processingInvitation,
                    onAcceptInvitation: acceptInvitation,
                    onDeclineInvitation: declineInvitation,
                  ),
                  if (invitations.isNotEmpty) const SizedBox(height: 16),
                  HomeAttentionSection(
                    summary: attentionSummary,
                    pendingInvitationCount: invitations.length,
                    onOpenTasks: () =>
                        openHomeListType(AppListTypes.tasks.value),
                    onOpenChores: () =>
                        openHomeListType(AppListTypes.chores.value),
                    onOpenShopping: () =>
                        openHomeListType(AppListTypes.shopping.value),
                    onOpenMealPlan: () =>
                        openHomeListType(AppListTypes.mealPlan.value),
                  ),
                  if (invitations.isNotEmpty || attentionSummary.hasAttention)
                    const SizedBox(height: 16),
                  HomeListsSection(
                    groups: groups,
                    lists: lists,
                    loading: false,
                    creatingGroup: creatingGroup,
                    onCreateGroup: createGroupDialog,
                    onHomeChanged: loadHomeData,
                    listSummaries: listSummaries,
                  ),
                ],
              ),
            ),
    );
  }
}
