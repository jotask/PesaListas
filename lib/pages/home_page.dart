import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/create_group_dialog.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/settings_page.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/group_repository.dart';
import 'package:pesalistas/repositories/invitation_repository.dart';
import 'package:pesalistas/repositories/profile_repository.dart';
import 'package:pesalistas/widgets/home/group_grid_section.dart';
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
  late final InvitationRepository invitationRepository;
  late final ProfileRepository profileRepository;

  bool loading = true;
  bool acceptingInvitation = false;
  bool creatingGroup = false;
  bool signingOut = false;

  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> invitations = [];

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    groupRepository = GroupRepository(client);
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
      final results = await Future.wait([
        groupRepository.getMyGroups(),
        invitationRepository.getPendingInvitations(),
      ]);

      if (!mounted) return;

      setState(() {
        groups = results[0];
        invitations = results[1];
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loading = false);
      showErrorSnackBar(context, context.l10n.failedToLoadHomeData, error);
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    if (acceptingInvitation) return;

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

  void declineInvitation(String invitationId) {
    showErrorSnackBar(
      context,
      context.l10n.declineInvitationIsNotAvailableYet,
      context.l10n.weCanAddProperDeclineSupportInTheNextStep,
    );
  }

  Future<void> createGroupDialog() async {
    if (creatingGroup) return;

    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateGroupDialog(),
    );

    if (name == null || name.isEmpty) return;

    setState(() => creatingGroup = true);

    try {
      await groupRepository.createGroup(name: name);
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

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.signOutFailed, error);
    } finally {
      if (mounted) {
        setState(() => signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myGroups),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
            icon: Icon(Icons.settings_outlined),
            tooltip: context.l10n.settingsTitle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: creatingGroup ? null : createGroupDialog,
        icon: Icon(Icons.add),
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
                    acceptingInvitation: acceptingInvitation,
                    onAcceptInvitation: acceptInvitation,
                    onDeclineInvitation: declineInvitation,
                  ),
                  if (invitations.isNotEmpty) SizedBox(height: 16),
                  GroupGridSection(
                    groups: groups,
                    loading: false,
                    creatingGroup: creatingGroup,
                    onCreateGroup: createGroupDialog,
                  ),
                ],
              ),
            ),
    );
  }
}
