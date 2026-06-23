import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/activity_inbox_page.dart';
import 'package:pesalistas/pages/auth_page.dart';
import 'package:pesalistas/pages/create_group_page.dart';
import 'package:pesalistas/pages/list_detail_page.dart';
import 'package:pesalistas/pages/settings_page.dart';
import 'package:pesalistas/repositories/activity_repository.dart';
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
  late final ActivityRepository activityRepository;
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
  Map<String, ListUnreadActivity> unreadActivityByListId = {};
  List<Map<String, dynamic>> invitations = [];
  HomeAttentionSummary attentionSummary = const HomeAttentionSummary();

  RealtimeChannel? activityChannel;
  Timer? homeRealtimeReloadDebounce;

  bool get processingInvitation => acceptingInvitation || decliningInvitation;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    authRepository = AuthRepository(client);
    groupRepository = GroupRepository(client);
    listRepository = ListRepository(client);
    activityRepository = ActivityRepository(client);
    invitationRepository = InvitationRepository(client);
    profileRepository = ProfileRepository(client);

    unawaited(
      profileRepository.syncCurrentProfileFromAuth(
        debugLabel: 'HomePageProfileSync',
      ),
    );

    subscribeToHomeActivity();

    loadHomeData();
  }

  @override
  void dispose() {
    homeRealtimeReloadDebounce?.cancel();

    final channel = activityChannel;

    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }

    super.dispose();
  }

  String? get currentUserId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  bool get hasUnreadInboxActivity {
    return unreadActivityByListId.values.any((activity) => activity.hasUnread);
  }

  Future<void> openActivityInbox() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/activity_inbox'),
        builder: (_) => const ActivityInboxPage(),
      ),
    );

    if (!mounted) return;

    await loadHomeData();
  }

  void subscribeToHomeActivity() {
    final channel = Supabase.instance.client.channel(
      'home:list_activity_events',
    );

    activityChannel = channel;

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: AppTables.listActivityEvents,
          callback: (payload) {
            unawaited(handleHomeRealtimeActivity(payload));
          },
        )
        .subscribe();

    debugPrint('HOME ACTIVITY REALTIME SUBSCRIBED');
  }

  Future<void> handleHomeRealtimeActivity(PostgresChangePayload payload) async {
    final event = payload.newRecord;
    final actorId = event['actor_id']?.toString();

    if (actorId != null && actorId == currentUserId) {
      return;
    }

    if (!mounted) {
      return;
    }

    debugPrint('HOME REALTIME ACTIVITY RECEIVED: ${event['event_type']}');

    homeRealtimeReloadDebounce?.cancel();
    homeRealtimeReloadDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      unawaited(loadHomeData(showLoading: false));
    });
  }

  Future<void> loadHomeData({bool showLoading = true}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() => loading = true);
    }

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

      final loadedUnreadActivityByListId = await activityRepository
          .getUnreadActivityByList(
            loadedLists
                .map((list) => list[AppListFields.id]?.toString())
                .whereType<String>()
                .where((id) => id.isNotEmpty)
                .toList(),
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
        unreadActivityByListId = loadedUnreadActivityByListId;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      if (showLoading) {
        setState(() => loading = false);
      }
      showErrorSnackBar(context, context.l10n.failedToLoadHomeData, error);
    }
  }

  Future<void> openHomeList(Map<String, dynamic> list) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/list_detail'),
        builder: (_) => ListDetailPage(list: list),
      ),
    );

    if (!mounted) return;

    await loadHomeData();
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

    await openHomeList(list);
  }

  @override
  Widget build(BuildContext context) {
    final attentionCount =
        invitations.length +
        attentionSummary.overdueChores +
        attentionSummary.choresDueToday +
        attentionSummary.overdueTasks +
        attentionSummary.tasksDueToday +
        attentionSummary.tasksDueSoon +
        attentionSummary.shoppingToBuy +
        attentionSummary.mealsToday;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF4),
      floatingActionButton: loading
          ? null
          : FloatingActionButton.extended(
              onPressed: creatingGroup ? null : createGroupDialog,
              backgroundColor: const Color(0xFF19A873),
              foregroundColor: Colors.white,
              elevation: 0,
              icon: creatingGroup
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_rounded),
              label: const Text(
                'New group',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
      body: SafeArea(
        child: loading
            ? const _HomeLoadingView()
            : RefreshIndicator(
                onRefresh: loadHomeData,
                color: const Color(0xFF19A873),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                  children: [
                    _HomeHeroHeader(
                      groupCount: groups.length,
                      listCount: lists.length,
                      attentionCount: attentionCount,
                      hasUnreadInboxActivity: hasUnreadInboxActivity,
                      onOpenActivity: openActivityInbox,
                      onOpenSettings: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/settings'),
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                      unreadActivityByListId: unreadActivityByListId,
                      onOpenList: openHomeList,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HomeAppIcon(size: 72, radius: 22),
          SizedBox(height: 18),
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3.2,
              color: Color(0xFF19A873),
              backgroundColor: Color(0xFFEAF5EF),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading your home...',
            style: TextStyle(
              color: Color(0xFF727A83),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeroHeader extends StatelessWidget {
  const _HomeHeroHeader({
    required this.groupCount,
    required this.listCount,
    required this.attentionCount,
    required this.hasUnreadInboxActivity,
    required this.onOpenActivity,
    required this.onOpenSettings,
  });

  final int groupCount;
  final int listCount;
  final int attentionCount;
  final bool hasUnreadInboxActivity;
  final VoidCallback onOpenActivity;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFECE7DC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _HomeAppIcon(size: 52, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 0.98,
                      letterSpacing: -1,
                    ),
                    children: [
                      TextSpan(
                        text: 'Pesa',
                        style: TextStyle(color: Color(0xFF26363B)),
                      ),
                      TextSpan(
                        text: 'Listas',
                        style: TextStyle(color: Color(0xFF19A873)),
                      ),
                    ],
                  ),
                ),
              ),
              _HomeIconButton(
                icon: Icons.inbox_outlined,
                tooltip: 'Activity',
                hasBadge: hasUnreadInboxActivity,
                onPressed: onOpenActivity,
              ),
              const SizedBox(width: 8),
              _HomeIconButton(
                icon: Icons.settings_outlined,
                tooltip: 'Settings',
                onPressed: onOpenSettings,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Your shared home',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF26363B),
              fontWeight: FontWeight.w900,
              height: 1.02,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Groups, lists, meals and routines in one calm place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF727A83),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HomeMetricCard(
                  label: 'Groups',
                  value: groupCount.toString(),
                  icon: Icons.groups_2_outlined,
                  color: const Color(0xFF19A873),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeMetricCard(
                  label: 'Lists',
                  value: listCount.toString(),
                  icon: Icons.checklist_rounded,
                  color: const Color(0xFF3478F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomeMetricCard(
                  label: 'Focus',
                  value: attentionCount.toString(),
                  icon: Icons.priority_high_rounded,
                  color: const Color(0xFFFF7A59),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeAppIcon extends StatelessWidget {
  const _HomeAppIcon({required this.size, required this.radius});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF149D6E).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/app_icon.png',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF25C889), Color(0xFF149D6E)],
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(
              Icons.checklist_rounded,
              color: Colors.white,
              size: size * 0.52,
            ),
          );
        },
      ),
    );
  }
}

class _HomeIconButton extends StatelessWidget {
  const _HomeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.hasBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF3F8F4),
            foregroundColor: const Color(0xFF26363B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: Icon(icon),
        ),
        if (hasBadge)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.4),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeMetricCard extends StatelessWidget {
  const _HomeMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 11, 10, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF727A83),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
