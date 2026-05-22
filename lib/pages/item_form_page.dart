import 'package:flutter/material.dart';
import 'package:pesalistas/core/date_formatting.dart';
import 'package:pesalistas/core/fields/movie_fields.dart';
import 'package:pesalistas/core/item_assignee_fields.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/fields/member_fields.dart';
import 'package:pesalistas/core/priority_types.dart';
import 'package:pesalistas/core/fields/profile_fields.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/movie_picker_page.dart';
import 'package:pesalistas/widgets/common/app_info_message.dart';
import 'package:pesalistas/widgets/common/app_network_image_thumbnail.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';
import 'package:pesalistas/core/fields/book_fields.dart';
import 'package:pesalistas/pages/book_picker_page.dart';

class ItemFormPageResult {
  const ItemFormPageResult({
    required this.title,
    this.description,
    this.priority = 0,
    this.deadlineAt,
    this.recurrenceType,
    this.recurrenceInterval,
    this.nextDueAt,
    this.movieTmdbId,
    this.bookOpenLibraryKey,
    this.assignmentScope = AppItemAssignmentScopes.none,
    this.assigneeUserIds = const [],
  });

  final String title;
  final String? description;
  final int priority;
  final DateTime? deadlineAt;
  final String? recurrenceType;
  final int? movieTmdbId;
  final String? bookOpenLibraryKey;
  final int? recurrenceInterval;
  final DateTime? nextDueAt;
  final String assignmentScope;
  final List<String> assigneeUserIds;
}

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({
    super.key,
    this.item,
    required this.listType,
    this.groupMembers = const [],
    this.currentUserId,
  });

  final Map<String, dynamic>? item;
  final String listType;
  final List<Map<String, dynamic>> groupMembers;
  final String? currentUserId;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController recurrenceIntervalController;
  late String selectedAssignmentScope;
  late Set<String> selectedAssigneeUserIds;

  int? selectedMovieTmdbId;
  Map<String, dynamic>? selectedMovie;
  String? movieLinkMessage;

  String? selectedBookOpenLibraryKey;
  Map<String, dynamic>? selectedBook;
  String? bookLinkMessage;

  int priority = 0;
  DateTime? deadlineAt;

  String? recurrenceType;
  int recurrenceInterval = 2;
  DateTime? nextDueAt;

  String? validationMessage;

  bool get isEditing => widget.item != null;

  AppListTypeConfig get listTypeConfig =>
      AppListTypes.fromValue(widget.listType);

  bool get isTaskList => widget.listType == AppListTypes.tasks.value;

  bool get isChoreList => widget.listType == AppListTypes.chores.value;

  bool get usesCustomInterval {
    return recurrenceType == AppRecurrenceTypes.everyNDays.value;
  }

  bool get hasRecurrence => recurrenceType != null;

  bool get supportsAssignments {
    return widget.listType == AppListTypes.tasks.value ||
        widget.listType == AppListTypes.chores.value;
  }

  bool get hasMultipleGroupMembers {
    return widget.groupMembers.length > 1;
  }

  bool get isMovieList {
    return widget.listType == AppListTypes.movies.value;
  }

  bool get isBookList {
    return widget.listType == AppListTypes.books.value;
  }

  String assignmentNameForMember(Map<String, dynamic> member) {
    final userId = member[AppMemberFields.userId]?.toString();

    if (userId == widget.currentUserId) {
      return 'You';
    }

    final profile = member[AppMemberFields.profiles];

    if (profile is Map<String, dynamic>) {
      final displayName = profile[AppProfileFields.displayName]?.toString();

      if (displayName != null && displayName.trim().isNotEmpty) {
        return displayName.trim();
      }
    }

    if (userId != null && userId.length >= 8) {
      return 'Member ${userId.substring(0, 8)}';
    }

    return 'Member';
  }

  String initialsForMember(Map<String, dynamic> member) {
    final name = assignmentNameForMember(member).trim();

    if (name.isEmpty) return '?';

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  void setNoAssignment() {
    setState(() {
      selectedAssignmentScope = AppItemAssignmentScopes.none;
      selectedAssigneeUserIds.clear();
    });
  }

  void setAssignToEveryone() {
    setState(() {
      selectedAssignmentScope = AppItemAssignmentScopes.all;
      selectedAssigneeUserIds.clear();
    });
  }

  void setAssignToMe() {
    final currentUserId = widget.currentUserId;

    if (currentUserId == null || currentUserId.isEmpty) {
      setNoAssignment();
      return;
    }

    setState(() {
      selectedAssignmentScope = AppItemAssignmentScopes.specific;
      selectedAssigneeUserIds = {currentUserId};
    });
  }

  void setPickMembersMode() {
    setState(() {
      selectedAssignmentScope = AppItemAssignmentScopes.specific;

      if (selectedAssigneeUserIds.isEmpty) {
        final currentUserId = widget.currentUserId;

        if (currentUserId != null && currentUserId.isNotEmpty) {
          selectedAssigneeUserIds = {currentUserId};
        }
      }
    });
  }

  void toggleAssignedMember(String userId) {
    setState(() {
      selectedAssignmentScope = AppItemAssignmentScopes.specific;

      if (selectedAssigneeUserIds.contains(userId)) {
        selectedAssigneeUserIds.remove(userId);
      } else {
        selectedAssigneeUserIds.add(userId);
      }

      if (selectedAssigneeUserIds.isEmpty) {
        selectedAssignmentScope = AppItemAssignmentScopes.none;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    titleController = TextEditingController(
      text: item?[AppItemFields.title]?.toString() ?? '',
    );

    descriptionController = TextEditingController(
      text: item?[AppItemFields.description]?.toString() ?? '',
    );

    priority = AppValueParsing.intOrNull(item?[AppItemFields.priority]) ?? 0;

    deadlineAt = AppValueParsing.dateTimeOrNull(
      item?[AppItemFields.deadlineAt],
    );

    recurrenceType = item?[AppItemFields.recurrenceType]?.toString();

    recurrenceInterval =
        AppValueParsing.intOrNull(item?[AppItemFields.recurrenceInterval]) ?? 2;

    selectedMovieTmdbId = AppValueParsing.intOrNull(
      widget.item?[AppItemFields.movieTmdbId],
    );

    final itemMovie = widget.item?[AppItemFields.movie];

    if (itemMovie is Map<String, dynamic>) {
      selectedMovie = itemMovie;
    } else if (itemMovie is Map) {
      selectedMovie = Map<String, dynamic>.from(itemMovie);
    }

    selectedBookOpenLibraryKey = widget.item?[AppItemFields.bookOpenLibraryKey]
        ?.toString();

    if (selectedBookOpenLibraryKey != null &&
        selectedBookOpenLibraryKey!.trim().isEmpty) {
      selectedBookOpenLibraryKey = null;
    }

    final itemBook = widget.item?[AppItemFields.book];

    if (itemBook is Map<String, dynamic>) {
      selectedBook = itemBook;
    } else if (itemBook is Map) {
      selectedBook = Map<String, dynamic>.from(itemBook);
    }

    if (recurrenceInterval < 2) {
      recurrenceInterval = 2;
    }

    nextDueAt = AppValueParsing.dateTimeOrNull(item?[AppItemFields.nextDueAt]);

    recurrenceIntervalController = TextEditingController(
      text: recurrenceInterval.toString(),
    );

    final currentUserId = widget.currentUserId;
    final itemAssignmentScope = widget.item?[AppItemFields.assignmentScope]
        ?.toString();

    selectedAssignmentScope =
        AppItemAssignmentScopes.isValid(itemAssignmentScope ?? '')
        ? itemAssignmentScope!
        : AppItemAssignmentScopes.none;

    selectedAssigneeUserIds = initialAssigneeUserIds();

    final shouldAutoAssignToCurrentUser =
        widget.item == null &&
        currentUserId != null &&
        currentUserId.isNotEmpty &&
        (widget.listType == 'tasks' || widget.listType == 'chores');

    if (shouldAutoAssignToCurrentUser) {
      selectedAssignmentScope = AppItemAssignmentScopes.specific;
      selectedAssigneeUserIds = {currentUserId};
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    recurrenceIntervalController.dispose();
    super.dispose();
  }

  Set<String> initialAssigneeUserIds() {
    final value = widget.item?[AppItemFields.assignees];

    if (value is! List) {
      return {};
    }

    return value
        .map((row) {
          if (row is! Map) return null;
          return row[AppItemAssigneeFields.userId]?.toString();
        })
        .whereType<String>()
        .where((userId) => userId.isNotEmpty)
        .toSet();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void submit() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    setState(() => validationMessage = null);

    if (title.isEmpty) {
      setState(() => validationMessage = context.l10n.titleIsRequired);
      return;
    }

    if (isChoreList && usesCustomInterval && recurrenceInterval < 2) {
      setState(
        () =>
            validationMessage = context.l10n.customRecurrenceMustBeAtLeast2Days,
      );
      return;
    }

    final assignmentScope = supportsAssignments
        ? selectedAssignmentScope
        : AppItemAssignmentScopes.none;

    final assigneeUserIds = assignmentScope == AppItemAssignmentScopes.specific
        ? selectedAssigneeUserIds.toList()
        : <String>[];

    final movieTmdbId = isMovieList ? selectedMovieTmdbId : null;
    final bookOpenLibraryKey = isBookList ? selectedBookOpenLibraryKey : null;

    Navigator.of(context).pop(
      ItemFormPageResult(
        title: title,
        description: description.isEmpty ? null : description,
        priority: priority,
        deadlineAt: deadlineAt,
        recurrenceType: recurrenceType,
        movieTmdbId: movieTmdbId,
        bookOpenLibraryKey: bookOpenLibraryKey,
        recurrenceInterval: usesCustomInterval ? recurrenceInterval : null,
        nextDueAt: nextDueAt,
        assignmentScope: assignmentScope,
        assigneeUserIds: assigneeUserIds,
      ),
    );
  }

  Future<void> findMovie() async {
    final movie = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/movie_picker'),
        builder: (_) => MoviePickerPage(
          initialQuery: titleController.text.trim().isEmpty
              ? null
              : titleController.text.trim(),
        ),
      ),
    );

    if (movie == null) return;

    final tmdbId = AppValueParsing.intOrNull(movie[AppMovieFields.tmdbId]);
    final title = movie[AppMovieFields.title]?.toString();

    if (tmdbId == null) {
      setState(() {
        movieLinkMessage = 'Selected movie has no TMDb id.';
      });
      return;
    }

    setState(() {
      selectedMovieTmdbId = tmdbId;
      selectedMovie = movie;

      if (title != null && title.trim().isNotEmpty) {
        titleController.text = title.trim();
      }

      movieLinkMessage = 'Movie linked.';
      validationMessage = null;
    });
  }

  void unlinkMovie() {
    setState(() {
      selectedMovieTmdbId = null;
      selectedMovie = null;
      movieLinkMessage = 'Movie link removed.';
      validationMessage = null;
    });
  }

  Future<void> findBook() async {
    final book = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/book_picker'),
        builder: (_) => const BookPickerPage(),
      ),
    );

    if (book == null) return;

    final openLibraryKey = book[AppBookFields.openLibraryKey]?.toString();
    final title = book[AppBookFields.title]?.toString();

    if (openLibraryKey == null || openLibraryKey.trim().isEmpty) {
      setState(() {
        bookLinkMessage = 'Selected book has no Open Library key.';
      });
      return;
    }

    setState(() {
      selectedBookOpenLibraryKey = openLibraryKey.trim();
      selectedBook = book;

      if (title != null && title.trim().isNotEmpty) {
        titleController.text = title.trim();
      }

      bookLinkMessage = 'Book linked.';
      validationMessage = null;
    });
  }

  void unlinkBook() {
    setState(() {
      selectedBookOpenLibraryKey = null;
      selectedBook = null;
      bookLinkMessage = 'Book link removed.';
      validationMessage = null;
    });
  }

  Future<void> pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: isEditing ? DateTime(2020) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: deadlineAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => deadlineAt = picked);
  }

  Future<void> pickNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: isEditing ? DateTime(2020) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      initialDate: nextDueAt ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() => nextDueAt = picked);
  }

  void updateRecurrenceType(String? value) {
    setState(() {
      recurrenceType = value;
      validationMessage = null;

      if (value == null) {
        nextDueAt = null;
      } else {
        nextDueAt ??= DateTime.now();

        if (value == AppRecurrenceTypes.everyNDays.value &&
            recurrenceInterval < 2) {
          recurrenceInterval = 2;
          recurrenceIntervalController.text = '2';
        }
      }
    });
  }

  void updateRecurrenceInterval(String value) {
    setState(() {
      recurrenceInterval = int.tryParse(value) ?? 2;
      validationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? context.l10n.editItem
              : context.l10n.addListTypeItem(
                  config.label(context).toLowerCase(),
                ),
        ),
      ),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: isEditing ? context.l10n.save : context.l10n.add,
        primaryIcon: isEditing ? Icons.save_outlined : Icons.add,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: config.icon,
              title: config.label(context),
              subtitle: config.description(context),
            ),
            const SizedBox(height: 16),
            if (supportsAssignments) ...[
              const SizedBox(height: 12),
              _AssignmentSelectorCard(
                groupMembers: widget.groupMembers,
                currentUserId: widget.currentUserId,
                selectedAssignmentScope: selectedAssignmentScope,
                selectedAssigneeUserIds: selectedAssigneeUserIds,
                memberNameBuilder: assignmentNameForMember,
                memberInitialsBuilder: initialsForMember,
                onNoAssignment: setNoAssignment,
                onAssignToMe: setAssignToMe,
                onAssignToEveryone: setAssignToEveryone,
                onPickMembersMode: setPickMembersMode,
                onToggleMember: toggleAssignedMember,
              ),
            ],
            if (isMovieList) ...[
              const SizedBox(height: 12),
              _LinkedMovieActionsCard(
                movie: selectedMovie,
                message: movieLinkMessage,
                onFindMovie: findMovie,
                movieTmdbId: selectedMovieTmdbId,
                onUnlinkMovie: selectedMovieTmdbId == null ? null : unlinkMovie,
              ),
            ],
            if (isBookList) ...[
              const SizedBox(height: 12),
              _LinkedBookActionsCard(
                book: selectedBook,
                bookOpenLibraryKey: selectedBookOpenLibraryKey,
                message: bookLinkMessage,
                onFindBook: findBook,
                onUnlinkBook: selectedBookOpenLibraryKey == null
                    ? null
                    : unlinkBook,
              ),
            ],
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: titleController,
                  autofocus: !isEditing,
                  decoration: InputDecoration(
                    labelText: context.l10n.title,
                    hintText: context.l10n.buyMilkWatchMovieCleanKitchen,
                    prefixIcon: const Icon(Icons.title_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => clearValidation(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.description,
                    hintText: context.l10n.optional,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                ),
                if (isTaskList) ...[
                  const SizedBox(height: 16),
                  _TaskFieldsSection(
                    priority: priority,
                    deadlineAt: deadlineAt,
                    onPriorityChanged: (value) {
                      setState(() => priority = value);
                    },
                    onPickDeadline: pickDeadline,
                    onRemoveDeadline: () {
                      setState(() => deadlineAt = null);
                    },
                  ),
                ],
                if (isChoreList) ...[
                  const SizedBox(height: 16),
                  _ChoreFieldsSection(
                    recurrenceType: recurrenceType,
                    recurrenceIntervalController: recurrenceIntervalController,
                    usesCustomInterval: usesCustomInterval,
                    hasRecurrence: hasRecurrence,
                    nextDueAt: nextDueAt,
                    onRecurrenceTypeChanged: updateRecurrenceType,
                    onRecurrenceIntervalChanged: updateRecurrenceInterval,
                    onPickNextDueDate: pickNextDueDate,
                    onRemoveNextDueDate: () {
                      setState(() => nextDueAt = null);
                    },
                  ),
                ],
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _TaskFieldsSection extends StatelessWidget {
  const _TaskFieldsSection({
    required this.priority,
    required this.deadlineAt,
    required this.onPriorityChanged,
    required this.onPickDeadline,
    required this.onRemoveDeadline,
  });

  final int priority;
  final DateTime? deadlineAt;
  final void Function(int value) onPriorityChanged;
  final VoidCallback onPickDeadline;
  final VoidCallback onRemoveDeadline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int>(
          initialValue: priority,
          decoration: InputDecoration(
            labelText: context.l10n.priority,
            prefixIcon: const Icon(Icons.flag_outlined),
          ),
          items: AppPriorityTypes.all.map((config) {
            return DropdownMenuItem<int>(
              value: config.value,
              child: Text(config.label(context)),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            onPriorityChanged(value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickDeadline,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  deadlineAt == null
                      ? context.l10n.addDeadline
                      : context.l10n.deadlineDate(
                          AppDateFormatting.yyyyMmDd(deadlineAt!),
                        ),
                ),
              ),
            ),
            if (deadlineAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemoveDeadline,
                icon: const Icon(Icons.close),
                tooltip: context.l10n.removeDeadline,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ChoreFieldsSection extends StatelessWidget {
  const _ChoreFieldsSection({
    required this.recurrenceType,
    required this.recurrenceIntervalController,
    required this.usesCustomInterval,
    required this.hasRecurrence,
    required this.nextDueAt,
    required this.onRecurrenceTypeChanged,
    required this.onRecurrenceIntervalChanged,
    required this.onPickNextDueDate,
    required this.onRemoveNextDueDate,
  });

  final String? recurrenceType;
  final TextEditingController recurrenceIntervalController;
  final bool usesCustomInterval;
  final bool hasRecurrence;
  final DateTime? nextDueAt;
  final void Function(String? value) onRecurrenceTypeChanged;
  final void Function(String value) onRecurrenceIntervalChanged;
  final VoidCallback onPickNextDueDate;
  final VoidCallback onRemoveNextDueDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: recurrenceType,
          decoration: InputDecoration(
            labelText: context.l10n.recurrence,
            helperText: context.l10n.chooseHowOftenThisChoreRepeats,
            prefixIcon: const Icon(Icons.repeat_outlined),
          ),
          items: AppRecurrenceTypes.all.map((config) {
            return DropdownMenuItem<String?>(
              value: config.value,
              child: Text(config.label(context)),
            );
          }).toList(),
          onChanged: onRecurrenceTypeChanged,
        ),
        if (usesCustomInterval) ...[
          const SizedBox(height: 12),
          TextField(
            controller: recurrenceIntervalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.repeatEvery,
              suffixText: context.l10n.days,
              helperText: context.l10n.minimum2Days,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
            onChanged: onRecurrenceIntervalChanged,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasRecurrence ? onPickNextDueDate : null,
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  nextDueAt == null
                      ? context.l10n.setNextDueDate
                      : context.l10n.nextDueDate(
                          AppDateFormatting.yyyyMmDd(nextDueAt!),
                        ),
                ),
              ),
            ),
            if (nextDueAt != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemoveNextDueDate,
                icon: const Icon(Icons.close),
                tooltip: context.l10n.removeNextDueDate,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hasRecurrence
              ? context
                    .l10n
                    .whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate
              : context.l10n.nonRecurringChoresCanStillBeCompletedManually,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AssignmentSelectorCard extends StatelessWidget {
  const _AssignmentSelectorCard({
    required this.groupMembers,
    required this.currentUserId,
    required this.selectedAssignmentScope,
    required this.selectedAssigneeUserIds,
    required this.memberNameBuilder,
    required this.memberInitialsBuilder,
    required this.onNoAssignment,
    required this.onAssignToMe,
    required this.onAssignToEveryone,
    required this.onPickMembersMode,
    required this.onToggleMember,
  });

  final List<Map<String, dynamic>> groupMembers;
  final String? currentUserId;
  final String selectedAssignmentScope;
  final Set<String> selectedAssigneeUserIds;
  final String Function(Map<String, dynamic> member) memberNameBuilder;
  final String Function(Map<String, dynamic> member) memberInitialsBuilder;
  final VoidCallback onNoAssignment;
  final VoidCallback onAssignToMe;
  final VoidCallback onAssignToEveryone;
  final VoidCallback onPickMembersMode;
  final void Function(String userId) onToggleMember;

  bool get isNone {
    return selectedAssignmentScope == AppItemAssignmentScopes.none;
  }

  bool get isAll {
    return selectedAssignmentScope == AppItemAssignmentScopes.all;
  }

  bool get isSpecific {
    return selectedAssignmentScope == AppItemAssignmentScopes.specific;
  }

  bool get hasMultipleMembers {
    return groupMembers.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.assignment_ind_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assignment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text('Choose who is responsible for this item.'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  selected: isNone,
                  label: const Text('No assignment'),
                  avatar: const Icon(Icons.person_off_outlined, size: 16),
                  onSelected: (_) => onNoAssignment(),
                ),
                ChoiceChip(
                  selected:
                      isSpecific &&
                      currentUserId != null &&
                      selectedAssigneeUserIds.length == 1 &&
                      selectedAssigneeUserIds.contains(currentUserId),
                  label: const Text('Me'),
                  avatar: const Icon(Icons.person_outline, size: 16),
                  onSelected: (_) => onAssignToMe(),
                ),
                if (hasMultipleMembers)
                  ChoiceChip(
                    selected: isAll,
                    label: const Text('Everyone'),
                    avatar: const Icon(Icons.groups_outlined, size: 16),
                    onSelected: (_) => onAssignToEveryone(),
                  ),
                if (hasMultipleMembers)
                  ChoiceChip(
                    selected: isSpecific,
                    label: const Text('Pick members'),
                    avatar: const Icon(Icons.checklist_outlined, size: 16),
                    onSelected: (_) => onPickMembersMode(),
                  ),
              ],
            ),
            if (isSpecific && hasMultipleMembers) ...[
              const SizedBox(height: 14),
              Text(
                'Members',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              for (final member in groupMembers)
                _AssignmentMemberTile(
                  member: member,
                  selectedAssigneeUserIds: selectedAssigneeUserIds,
                  memberNameBuilder: memberNameBuilder,
                  memberInitialsBuilder: memberInitialsBuilder,
                  onToggleMember: onToggleMember,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssignmentMemberTile extends StatelessWidget {
  const _AssignmentMemberTile({
    required this.member,
    required this.selectedAssigneeUserIds,
    required this.memberNameBuilder,
    required this.memberInitialsBuilder,
    required this.onToggleMember,
  });

  final Map<String, dynamic> member;
  final Set<String> selectedAssigneeUserIds;
  final String Function(Map<String, dynamic> member) memberNameBuilder;
  final String Function(Map<String, dynamic> member) memberInitialsBuilder;
  final void Function(String userId) onToggleMember;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = member[AppMemberFields.userId]?.toString();

    if (userId == null || userId.isEmpty) {
      return const SizedBox.shrink();
    }

    final selected = selectedAssigneeUserIds.contains(userId);
    final name = memberNameBuilder(member);
    final initials = memberInitialsBuilder(member);

    return CheckboxListTile(
      value: selected,
      onChanged: (_) => onToggleMember(userId),
      contentPadding: EdgeInsets.zero,
      secondary: CircleAvatar(
        backgroundColor: selected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Text(
          initials,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class _LinkedMovieActionsCard extends StatelessWidget {
  const _LinkedMovieActionsCard({
    required this.movie,
    required this.movieTmdbId,
    required this.message,
    required this.onFindMovie,
    required this.onUnlinkMovie,
  });

  final Map<String, dynamic>? movie;
  final int? movieTmdbId;
  final String? message;
  final VoidCallback onFindMovie;
  final VoidCallback? onUnlinkMovie;

  bool get hasMovie {
    return movieTmdbId != null;
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  String get title {
    return text(
      movie?[AppMovieFields.title],
      fallback: movieTmdbId == null ? 'Linked movie' : 'Linked movie details',
    );
  }

  String get year {
    return text(movie?[AppMovieFields.year]);
  }

  String get posterUrl {
    return text(movie?[AppMovieFields.posterUrl], fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppNetworkImageThumbnail(
                  imageUrl: posterUrl,
                  width: 58,
                  height: 84,
                  borderRadius: 12,
                  fallbackIcon: Icons.movie_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMovie ? title : 'No movie linked',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (hasMovie) ...[
                        const SizedBox(height: 4),
                        Text(
                          year == '—'
                              ? 'TMDb $movieTmdbId'
                              : '$year • TMDb $movieTmdbId',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasMovie
                            ? movie == null
                                  ? 'This item has a TMDb link, but cached details were not loaded yet.'
                                  : 'This list item is linked to cached TMDb movie details.'
                            : 'Search TMDb and link this item to a movie.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              AppInfoMessage(message: message!),
            ],
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: onFindMovie,
                  icon: const Icon(Icons.movie_filter_outlined),
                  label: Text(hasMovie ? 'Change movie' : 'Find movie'),
                ),
                if (onUnlinkMovie != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onUnlinkMovie,
                    icon: const Icon(Icons.link_off_outlined),
                    label: const Text('Remove movie link'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedBookActionsCard extends StatelessWidget {
  const _LinkedBookActionsCard({
    required this.book,
    required this.bookOpenLibraryKey,
    required this.message,
    required this.onFindBook,
    required this.onUnlinkBook,
  });

  final Map<String, dynamic>? book;
  final String? bookOpenLibraryKey;
  final String? message;
  final VoidCallback onFindBook;
  final VoidCallback? onUnlinkBook;

  bool get hasBook {
    return bookOpenLibraryKey != null && bookOpenLibraryKey!.trim().isNotEmpty;
  }

  String text(dynamic value, {String fallback = '—'}) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return fallback;
    }

    return result;
  }

  String get title {
    return text(
      book?[AppBookFields.title],
      fallback: bookOpenLibraryKey == null
          ? 'Linked book'
          : 'Linked book details',
    );
  }

  String get authors {
    return text(book?[AppBookFields.authors]);
  }

  String get firstPublishYear {
    return text(book?[AppBookFields.firstPublishYear]);
  }

  String get coverUrl {
    return text(book?[AppBookFields.coverUrl], fallback: '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppNetworkImageThumbnail(
                  imageUrl: coverUrl,
                  width: 58,
                  height: 84,
                  borderRadius: 12,
                  fallbackIcon: Icons.menu_book_outlined,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasBook ? title : 'No book linked',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (hasBook) ...[
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (authors != '—') authors,
                            if (firstPublishYear != '—') firstPublishYear,
                          ].join(' • '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        hasBook
                            ? book == null
                                  ? 'This item has an Open Library link, but cached details were not loaded yet.'
                                  : 'This list item is linked to cached Open Library book details.'
                            : 'Search Open Library and link this item to a book.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              AppInfoMessage(message: message!),
            ],
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: onFindBook,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(hasBook ? 'Change book' : 'Find book'),
                ),
                if (onUnlinkBook != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onUnlinkBook,
                    icon: const Icon(Icons.link_off_outlined),
                    label: const Text('Remove book link'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
