import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/item_assignee_fields.dart';
import 'package:pesalistas/core/meal_plan_cost_fields.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:pesalistas/core/profile_fields.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/core/vote_fields.dart';
import 'package:pesalistas/pages/edit_recipe_info_page.dart';
import 'package:pesalistas/pages/edit_recipe_instructions_page.dart';
import 'package:pesalistas/pages/generate_shopping_page.dart';
import 'package:pesalistas/pages/meal_plan_form_page.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/dialogs/vote_details_dialog.dart';
import 'package:pesalistas/dialogs/vote_dialog.dart';
import 'package:pesalistas/pages/create_recipe_page.dart';
import 'package:pesalistas/pages/edit_list_page.dart';
import 'package:pesalistas/pages/item_form_page.dart';
import 'package:pesalistas/pages/product_catalog_page.dart';
import 'package:pesalistas/pages/product_scanner_page.dart';
import 'package:pesalistas/pages/recipe_details_page.dart';
import 'package:pesalistas/pages/recipe_ingredient_form_page.dart';
import 'package:pesalistas/pages/shopping_item_form_page.dart';
import 'package:pesalistas/repositories/item_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/meal_plan_repository.dart';
import 'package:pesalistas/repositories/recipe_ingredient_repository.dart';
import 'package:pesalistas/repositories/recipe_repository.dart';
import 'package:pesalistas/repositories/shopping_repository.dart';
import 'package:pesalistas/repositories/vote_repository.dart';
import 'package:pesalistas/widgets/list_detail/list_detail_header.dart';
import 'package:pesalistas/widgets/list_detail/list_items_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListDetailPage extends StatefulWidget {
  const ListDetailPage({super.key, required this.list});

  final Map<String, dynamic> list;

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  late final ItemRepository itemRepository;
  late final VoteRepository voteRepository;
  late final RecipeRepository recipeRepository;
  late final RecipeIngredientRepository recipeIngredientRepository;
  late final MealPlanRepository mealPlanRepository;
  late final ShoppingRepository shoppingRepository;
  late final ListRepository listRepository;

  bool loadingItems = true;
  bool creatingItem = false;
  bool editingItem = false;
  bool deletingItem = false;
  bool completingItem = false;
  bool votingItem = false;
  bool loadingVoteDetails = false;
  bool loadingRecipeDetails = false;
  bool deletingRecipe = false;
  bool generatingShopping = false;
  bool editingList = false;
  bool archivingList = false;
  bool clearingBoughtItems = false;
  bool deletingList = false;
  bool clearingAllShoppingItems = false;

  List<Map<String, dynamic>> items = [];
  late Map<String, dynamic> currentList;
  List<Map<String, dynamic>> groupMembers = [];

  String get listId => currentList[AppListFields.id].toString();

  String get groupId => currentList[AppListFields.groupId].toString();

  String get listName =>
      currentList[AppListFields.name]?.toString() ?? context.l10n.list;

  String get listType =>
      currentList[AppListFields.listType]?.toString() ??
      AppListTypes.generic.value;

  AppListTypeConfig get listTypeConfig => AppListTypes.fromValue(listType);

  bool get isTaskList => listType == AppListTypes.tasks.value;

  bool get isChoreList => listType == AppListTypes.chores.value;

  bool get isRecipeList => listType == AppListTypes.recipes.value;

  bool get isMealPlanList => listType == AppListTypes.mealPlan.value;

  bool get isShoppingList => listType == AppListTypes.shopping.value;

  bool get isVotableList {
    return listType == AppListTypes.movies.value ||
        listType == AppListTypes.ideas.value ||
        listType == AppListTypes.activities.value;
  }

  bool get shouldShowStatusSummary {
    return listType == AppListTypes.tasks.value ||
        listType == AppListTypes.shopping.value ||
        listType == AppListTypes.generic.value;
  }

  bool get isBusy =>
      creatingItem ||
      editingItem ||
      deletingItem ||
      completingItem ||
      votingItem ||
      clearingBoughtItems ||
      loadingVoteDetails ||
      loadingRecipeDetails ||
      deletingRecipe ||
      generatingShopping ||
      clearingAllShoppingItems ||
      archivingList ||
      deletingList ||
      editingList;

  String? get currentUserId {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  @override
  void initState() {
    super.initState();

    currentList = Map<String, dynamic>.from(widget.list);
    final client = Supabase.instance.client;

    itemRepository = ItemRepository(client);
    voteRepository = VoteRepository(client);
    recipeRepository = RecipeRepository(client);
    recipeIngredientRepository = RecipeIngredientRepository(client);
    mealPlanRepository = MealPlanRepository(client);
    shoppingRepository = ShoppingRepository(client);
    listRepository = ListRepository(client);

    loadItems();
  }

  Future<List<Map<String, dynamic>>> loadGroupMembersWithProfiles() async {
    final client = Supabase.instance.client;

    final membersResponse = await client
        .from(AppTables.groupMembers)
        .select()
        .eq(AppMemberFields.groupId, groupId)
        .order(AppMemberFields.createdAt, ascending: true);

    final members = List<Map<String, dynamic>>.from(membersResponse);

    if (members.isEmpty) {
      return members;
    }

    final userIds = members
        .map((member) => member[AppMemberFields.userId]?.toString())
        .whereType<String>()
        .where((userId) => userId.isNotEmpty)
        .toSet()
        .toList();

    if (userIds.isEmpty) {
      return members;
    }

    final profilesResponse = await client
        .from(AppTables.profiles)
        .select()
        .inFilter(AppProfileFields.id, userIds);

    final profiles = List<Map<String, dynamic>>.from(profilesResponse);

    final profilesById = {
      for (final profile in profiles)
        profile[AppProfileFields.id].toString(): profile,
    };

    return members.map((member) {
      final userId = member[AppMemberFields.userId]?.toString();
      final profile = userId == null ? null : profilesById[userId];

      return {...member, AppMemberFields.profiles: profile};
    }).toList();
  }

  Future<void> loadItems() async {
    if (!mounted) return;

    setState(() => loadingItems = true);

    try {
      final loadedGroupMembers = await loadGroupMembersWithProfiles();

      if (isShoppingList) {
        final shoppingItems = await shoppingRepository.getShoppingItemsForGroup(
          groupId,
        );

        if (!mounted) return;

        setState(() {
          items = shoppingItems;
          loadingItems = false;
        });

        return;
      }

      if (isMealPlanList) {
        final mealPlans = await mealPlanRepository.getMealPlansForGroup(
          groupId,
        );
        final recipes = await recipeRepository.getRecipesForGroup(groupId);

        final recipesById = {
          for (final recipe in recipes)
            recipe[AppRecipeFields.id].toString(): recipe,
        };

        final recipeIds = mealPlans
            .map((mealPlan) => mealPlan[AppMealPlanFields.recipeId]?.toString())
            .whereType<String>()
            .where((recipeId) => recipeId.isNotEmpty)
            .toSet()
            .toList();

        final ingredientsByRecipeId = <String, List<Map<String, dynamic>>>{};

        for (final recipeId in recipeIds) {
          ingredientsByRecipeId[recipeId] = await recipeIngredientRepository
              .getIngredientsForRecipe(recipeId);
        }

        final enrichedMealPlans = mealPlans.map((mealPlan) {
          final recipeId = mealPlan[AppMealPlanFields.recipeId]?.toString();

          if (recipeId == null || recipeId.isEmpty) {
            return enrichMealPlanWithEstimatedCost(
              mealPlan: mealPlan,
              ingredients: const [],
            );
          }

          final recipe = recipesById[recipeId];
          final ingredients = ingredientsByRecipeId[recipeId] ?? const [];

          final mealPlanWithCost = enrichMealPlanWithEstimatedCost(
            mealPlan: mealPlan,
            ingredients: ingredients,
          );

          if (recipe == null) {
            return mealPlanWithCost;
          }

          return {...mealPlanWithCost, AppMealPlanFields.recipes: recipe};
        }).toList();

        if (!mounted) return;

        setState(() {
          groupMembers = loadedGroupMembers;
          items = enrichedMealPlans;
          loadingItems = false;
        });

        return;
      }

      if (isRecipeList) {
        final recipes = await recipeRepository.getRecipesForGroup(groupId);

        if (!mounted) return;

        setState(() {
          groupMembers = loadedGroupMembers;
          items = recipes;
          loadingItems = false;
        });

        return;
      }

      final rawItems = await itemRepository.getItemsForList(listId);
      final itemsWithAssignees = await enrichItemsWithAssignees(
        rawItems,
        loadedGroupMembers,
      );
      final enrichedItems = await enrichItemsWithVoteSummaries(
        itemsWithAssignees,
      );

      if (!mounted) return;

      setState(() {
        groupMembers = loadedGroupMembers;
        items = enrichedItems;
        loadingItems = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingItems = false);
      showErrorSnackBar(context, context.l10n.failedToLoadItems, error);
    }
  }

  Future<void> openProductCatalog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductCatalogPage(groupId: groupId)),
    );

    if (!mounted) return;

    if (isShoppingList) {
      await loadItems();
    }
  }

  Future<void> clearAllShoppingItems() async {
    if (clearingAllShoppingItems) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.clearAllShoppingItemsTitle,
      message: context.l10n.clearAllShoppingItemsMessage,
      deleteLabel: context.l10n.clearAll,
    );

    if (!confirmed) return;

    setState(() => clearingAllShoppingItems = true);

    try {
      await shoppingRepository.clearAllItems(groupId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.allShoppingItemsCleared);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToClearAllShoppingItems,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => clearingAllShoppingItems = false);
      }
    }
  }

  Future<void> archiveList() async {
    if (archivingList) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.archiveListTitle,
      message: context.l10n.archiveListMessage,
      deleteLabel: context.l10n.archive,
    );

    if (!confirmed) return;

    setState(() => archivingList = true);

    try {
      await listRepository.archiveList(listId);

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.listArchived);
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToArchiveList, error);
    } finally {
      if (mounted) {
        setState(() => archivingList = false);
      }
    }
  }

  Future<void> deleteList() async {
    if (deletingList) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteListTitle,
      message: context.l10n.deleteListMessage,
      deleteLabel: context.l10n.deleteList,
    );

    if (!confirmed) return;

    setState(() => deletingList = true);

    try {
      await listRepository.deleteList(listId);

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.listDeleted);
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeleteList, error);
    } finally {
      if (mounted) {
        setState(() => deletingList = false);
      }
    }
  }

  Future<void> clearBoughtShoppingItems() async {
    if (clearingBoughtItems) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.clearBoughtItemsTitle,
      message: context.l10n.clearBoughtItemsMessage,
      deleteLabel: context.l10n.clearBought,
    );

    if (!confirmed) return;

    setState(() => clearingBoughtItems = true);

    try {
      await shoppingRepository.clearBoughtItems(groupId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.boughtItemsCleared);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToClearBoughtItems, error);
    } finally {
      if (mounted) {
        setState(() => clearingBoughtItems = false);
      }
    }
  }

  Future<void> editList() async {
    if (editingList || archivingList || deletingList) return;

    final result = await Navigator.of(context).push<EditListPageResult>(
      MaterialPageRoute(builder: (_) => EditListPage(list: currentList)),
    );

    if (result == null) return;

    switch (result.action) {
      case EditListPageAction.archive:
        await archiveList();
        return;

      case EditListPageAction.delete:
        await deleteList();
        return;

      case EditListPageAction.save:
        break;
    }

    final name = result.name?.trim();

    if (name == null || name.isEmpty) return;

    setState(() => editingList = true);

    try {
      await listRepository.updateListInfo(
        listId: listId,
        name: name,
        description: result.description,
      );

      if (!mounted) return;

      setState(() {
        currentList = {
          ...currentList,
          AppListFields.name: name,
          AppListFields.description: result.description,
        };
      });

      showSuccessSnackBar(context, context.l10n.listUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToUpdateList, error);
    } finally {
      if (mounted) {
        setState(() => editingList = false);
      }
    }
  }

  Future<void> generateShoppingFromMealPlans() async {
    if (generatingShopping) return;

    final result = await Navigator.of(context).push<GenerateShoppingPageResult>(
      MaterialPageRoute(builder: (_) => const GenerateShoppingPage()),
    );

    if (result == null) return;

    setState(() => generatingShopping = true);

    try {
      await listRepository.ensureShoppingListForGroup(groupId: groupId);

      final createdCount = await mealPlanRepository
          .generateShoppingFromMealPlans(
            groupId: groupId,
            fromDate: result.fromDate,
            toDate: result.toDate,
          );

      if (!mounted) return;

      if (createdCount == 0) {
        showInfoSnackBar(context, context.l10n.noNewShoppingItemsGenerated);
      } else {
        showSuccessSnackBar(
          context,
          context.l10n.shoppingItemsGeneratedCount(createdCount),
        );
      }
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToGenerateShoppingItems,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => generatingShopping = false);
      }
    }
  }

  double? doubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String? nullableText(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) return null;

    return text;
  }

  double? estimatedIngredientTotal(Map<String, dynamic> ingredient) {
    final explicitTotal = doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
    );

    if (explicitTotal != null) {
      return explicitTotal;
    }

    final unitPrice = doubleOrNull(
      ingredient[AppRecipeIngredientFields.estimatedUnitPrice],
    );

    if (unitPrice == null) {
      return null;
    }

    final quantity = doubleOrNull(
      ingredient[AppRecipeIngredientFields.quantity],
    );

    if (quantity == null) {
      return unitPrice;
    }

    return unitPrice * quantity;
  }

  String ingredientCurrency(Map<String, dynamic> ingredient) {
    return nullableText(ingredient[AppRecipeIngredientFields.priceCurrency]) ??
        AppConfig.defaultCurrency;
  }

  Map<String, dynamic> enrichMealPlanWithEstimatedCost({
    required Map<String, dynamic> mealPlan,
    required List<Map<String, dynamic>> ingredients,
  }) {
    var total = 0.0;
    var hasEstimatedCost = false;
    var currency = AppConfig.defaultCurrency;

    for (final ingredient in ingredients) {
      final ingredientTotal = estimatedIngredientTotal(ingredient);

      if (ingredientTotal == null) {
        continue;
      }

      hasEstimatedCost = true;
      total += ingredientTotal;
      currency = ingredientCurrency(ingredient);
    }

    return {
      ...mealPlan,
      AppMealPlanCostFields.hasEstimatedCost: hasEstimatedCost,
      AppMealPlanCostFields.estimatedCost: total,
      AppMealPlanCostFields.priceCurrency: currency,
    };
  }

  Future<List<Map<String, dynamic>>> enrichItemsWithVoteSummaries(
    List<Map<String, dynamic>> loadedItems,
  ) async {
    if (!isVotableList || loadedItems.isEmpty) {
      return loadedItems;
    }

    final itemIds = loadedItems
        .map((item) => item[AppItemFields.id]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    final summaries = await voteRepository.getVoteSummariesForItems(itemIds);

    return loadedItems.map((item) {
      final itemId = item[AppItemFields.id]?.toString();
      final summary = summaries[itemId];

      if (summary == null) {
        return item;
      }

      return {...item, ...summary};
    }).toList();
  }

  Future<void> createItemDialog() async {
    if (creatingItem) return;

    if (isShoppingList) {
      await createShoppingItemDialog();
      return;
    }

    if (isMealPlanList) {
      await createMealPlanDialog();
      return;
    }

    if (isRecipeList) {
      await createRecipeDialog();
      return;
    }

    final result = await Navigator.of(context).push<ItemFormPageResult>(
      MaterialPageRoute(
        builder: (_) => ItemFormPage(
          listType: listType,
          groupMembers: groupMembers,
          currentUserId: currentUserId,
        ),
      ),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await itemRepository.createItem(
        listId: listId,
        title: result.title,
        description: result.description,
        priority: result.priority,
        deadlineAt: result.deadlineAt,
        recurrenceType: result.recurrenceType,
        recurrenceInterval: result.recurrenceInterval,
        nextDueAt: result.nextDueAt,
        assignmentScope: result.assignmentScope,
        assigneeUserIds: result.assigneeUserIds,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.itemCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCreateItem, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> enrichItemsWithAssignees(
    List<Map<String, dynamic>> rawItems,
    List<Map<String, dynamic>> loadedGroupMembers,
  ) async {
    if (rawItems.isEmpty) {
      return rawItems;
    }

    final itemIds = rawItems
        .map((item) => item[AppItemFields.id]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    if (itemIds.isEmpty) {
      return rawItems;
    }

    final assigneesByItemId = await itemRepository.getAssigneesForItems(
      itemIds,
    );

    final membersByUserId = {
      for (final member in loadedGroupMembers)
        if (member[AppMemberFields.userId] != null)
          member[AppMemberFields.userId].toString(): member,
    };

    return rawItems.map((item) {
      final itemId = item[AppItemFields.id]?.toString();

      final assignees = itemId == null
          ? <Map<String, dynamic>>[]
          : assigneesByItemId[itemId] ?? <Map<String, dynamic>>[];

      final enrichedAssignees = assignees.map((assignee) {
        final userId = assignee[AppItemAssigneeFields.userId]?.toString();
        final member = userId == null ? null : membersByUserId[userId];

        return {
          ...assignee,
          if (member != null) AppMemberFields.groupMembers: member,
        };
      }).toList();

      return {...item, AppItemFields.assignees: enrichedAssignees};
    }).toList();
  }

  Future<void> createShoppingItemDialog() async {
    final result = await Navigator.of(context).push<ShoppingItemFormPageResult>(
      MaterialPageRoute(builder: (_) => ShoppingItemFormPage(groupId: groupId)),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await shoppingRepository.createShoppingItem(
        groupId: groupId,
        name: result.name,
        quantity: result.quantity,
        unit: result.unit,
        estimatedUnitPrice: result.estimatedUnitPrice,
        priceCurrency: result.priceCurrency,
        barcode: result.barcode,
        catalogItemId: result.catalogItemId,
        productName: result.productName,
        productImageUrl: result.productImageUrl,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.shoppingItemCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToCreateShoppingItem,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<void> openProductScanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductScannerPage(groupId: groupId)),
    );

    if (!mounted) return;

    if (isShoppingList) {
      await loadItems();
    }
  }

  Future<void> createMealPlanDialog() async {
    if (creatingItem) return;

    setState(() => creatingItem = true);

    List<Map<String, dynamic>> recipes = [];

    try {
      recipes = await recipeRepository.getRecipesForGroup(groupId);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToLoadRecipes, error);
      setState(() => creatingItem = false);
      return;
    }

    if (!mounted) return;

    setState(() => creatingItem = false);

    final result = await Navigator.of(context).push<MealPlanFormPageResult>(
      MaterialPageRoute(builder: (_) => MealPlanFormPage(recipes: recipes)),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await mealPlanRepository.createMealPlan(
        groupId: groupId,
        plannedFor: result.plannedFor,
        mealType: result.mealType,
        recipeId: result.recipeId,
        note: result.note,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.mealPlanned);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCreateMealPlan, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<void> createRecipeDialog() async {
    final result = await Navigator.of(context).push<CreateRecipePageResult>(
      MaterialPageRoute(builder: (_) => const CreateRecipePage()),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await recipeRepository.createRecipe(
        groupId: groupId,
        name: result.name,
        description: result.description,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.recipeCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCreateRecipe, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<void> editItem(Map<String, dynamic> item) async {
    if (editingItem || isRecipeList) return;

    if (isShoppingList) {
      await editShoppingItem(item);
      return;
    }

    if (isMealPlanList) {
      await editMealPlan(item);
      return;
    }

    final result = await Navigator.of(context).push<ItemFormPageResult>(
      MaterialPageRoute(
        builder: (_) => ItemFormPage(
          item: item,
          listType: listType,
          groupMembers: groupMembers,
          currentUserId: currentUserId,
        ),
      ),
    );

    if (result == null) return;

    setState(() => editingItem = true);

    try {
      await itemRepository.updateItem(
        itemId: item[AppItemFields.id].toString(),
        title: result.title,
        description: result.description,
        updateTaskFields: isTaskList,
        priority: result.priority,
        deadlineAt: result.deadlineAt,
        updateChoreFields: isChoreList,
        recurrenceType: result.recurrenceType,
        recurrenceInterval: result.recurrenceInterval,
        nextDueAt: result.nextDueAt,
        assignmentScope: result.assignmentScope,
        assigneeUserIds: result.assigneeUserIds,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.itemUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToUpdateItem, error);
    } finally {
      if (mounted) {
        setState(() => editingItem = false);
      }
    }
  }

  Future<void> editShoppingItem(Map<String, dynamic> item) async {
    if (editingItem) return;

    final result = await Navigator.of(context).push<ShoppingItemFormPageResult>(
      MaterialPageRoute(
        builder: (_) => ShoppingItemFormPage(groupId: groupId, item: item),
      ),
    );

    if (result == null) return;

    setState(() => editingItem = true);

    try {
      await shoppingRepository.updateShoppingItem(
        shoppingItemId: item[AppShoppingItemFields.id].toString(),
        name: result.name,
        quantity: result.quantity,
        unit: result.unit,
        estimatedUnitPrice: result.estimatedUnitPrice,
        priceCurrency: result.priceCurrency,
        barcode: result.barcode,
        catalogItemId: result.catalogItemId,
        productName: result.productName,
        productImageUrl: result.productImageUrl,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.shoppingItemUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToUpdateShoppingItem,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => editingItem = false);
      }
    }
  }

  Future<void> editMealPlan(Map<String, dynamic> mealPlan) async {
    if (editingItem) return;

    setState(() => editingItem = true);

    List<Map<String, dynamic>> recipes = [];

    try {
      recipes = await recipeRepository.getRecipesForGroup(groupId);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToLoadRecipes, error);
      setState(() => editingItem = false);
      return;
    }

    if (!mounted) return;

    setState(() => editingItem = false);

    final result = await Navigator.of(context).push<MealPlanFormPageResult>(
      MaterialPageRoute(
        builder: (_) => MealPlanFormPage(mealPlan: mealPlan, recipes: recipes),
      ),
    );

    if (result == null) return;

    setState(() => editingItem = true);

    try {
      await mealPlanRepository.updateMealPlan(
        mealPlanId: mealPlan[AppMealPlanFields.id].toString(),
        plannedFor: result.plannedFor,
        mealType: result.mealType,
        recipeId: result.recipeId,
        note: result.note,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.mealPlanUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToUpdateMealPlan, error);
    } finally {
      if (mounted) {
        setState(() => editingItem = false);
      }
    }
  }

  Future<void> completeItem(String itemId) async {
    if (completingItem) return;

    if (isShoppingList) {
      await setShoppingItemChecked(shoppingItemId: itemId, checked: true);
      return;
    }

    setState(() => completingItem = true);

    try {
      await itemRepository.completeItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.itemCompleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToCompleteItem, error);
    } finally {
      if (mounted) {
        setState(() => completingItem = false);
      }
    }
  }

  Future<void> reopenItem(String itemId) async {
    if (completingItem) return;

    if (isShoppingList) {
      await setShoppingItemChecked(shoppingItemId: itemId, checked: false);
      return;
    }

    setState(() => completingItem = true);

    try {
      await itemRepository.reopenItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        listType == AppListTypes.shopping.value
            ? context.l10n.shoppingItemReopened
            : listType == AppListTypes.generic.value
            ? context.l10n.itemReopened
            : context.l10n.taskReopened,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToReopenItem, error);
    } finally {
      if (mounted) {
        setState(() => completingItem = false);
      }
    }
  }

  Future<void> setShoppingItemChecked({
    required String shoppingItemId,
    required bool checked,
  }) async {
    if (completingItem) return;

    setState(() => completingItem = true);

    try {
      await shoppingRepository.setShoppingItemChecked(
        shoppingItemId: shoppingItemId,
        checked: checked,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        checked ? context.l10n.markedAsBought : context.l10n.markedAsNotBought,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToUpdateShoppingItem,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => completingItem = false);
      }
    }
  }

  Future<void> deleteItem(String itemId) async {
    if (deletingItem || isRecipeList) return;

    if (isShoppingList) {
      await deleteShoppingItem(itemId);
      return;
    }

    if (isMealPlanList) {
      await deleteMealPlan(itemId);
      return;
    }

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteItem2,
      message: context.l10n.thisWillPermanentlyDeleteTheItemFromThisList,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await itemRepository.deleteItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.itemDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeleteItem, error);
    } finally {
      if (mounted) {
        setState(() => deletingItem = false);
      }
    }
  }

  Future<void> deleteShoppingItem(String shoppingItemId) async {
    if (deletingItem) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteShoppingItem,
      message: context.l10n.thisWillRemoveThisItemFromYourShoppingList,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await shoppingRepository.deleteShoppingItem(shoppingItemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.shoppingItemDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(
        context,
        context.l10n.failedToDeleteShoppingItem,
        error,
      );
    } finally {
      if (mounted) {
        setState(() => deletingItem = false);
      }
    }
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    if (deletingItem) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteMealPlan2,
      message: context.l10n.thisWillRemoveThisMealFromYourPlan,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await mealPlanRepository.deleteMealPlan(mealPlanId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.mealPlanDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeleteMealPlan, error);
    } finally {
      if (mounted) {
        setState(() => deletingItem = false);
      }
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    if (deletingRecipe) return;

    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: context.l10n.deleteRecipe2,
      message:
          context.l10n.thisWillPermanentlyDeleteThisRecipeAndItsIngredients,
    );

    if (!confirmed) return;

    setState(() => deletingRecipe = true);

    try {
      await recipeRepository.deleteRecipe(recipeId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, context.l10n.recipeDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToDeleteRecipe, error);
    } finally {
      if (mounted) {
        setState(() => deletingRecipe = false);
      }
    }
  }

  Future<void> voteItem(Map<String, dynamic> item) async {
    if (votingItem) return;

    setState(() => votingItem = true);

    try {
      final itemId = item[AppItemFields.id].toString();

      final existingVote = await voteRepository.getMyVote(itemId);

      if (!mounted) return;

      final existingPoints = existingVote?[AppVoteFields.points];
      final initialPoints = existingPoints is int
          ? existingPoints
          : int.tryParse(existingPoints?.toString() ?? '') ?? 5;

      final result = await showDialog<VoteDialogResult>(
        context: context,
        builder: (_) => VoteDialog(
          initialPoints: initialPoints,
          initialComment: existingVote?[AppVoteFields.comment]?.toString(),
          canRemove: existingVote != null,
        ),
      );

      if (result == null) return;

      if (result.removeVote) {
        await voteRepository.deleteMyVote(itemId);
      } else {
        await voteRepository.upsertVote(
          itemId: itemId,
          points: result.points,
          comment: result.comment,
        );
      }

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        result.removeVote ? context.l10n.voteRemoved : context.l10n.voteSaved,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToSaveVote, error);
    } finally {
      if (mounted) {
        setState(() => votingItem = false);
      }
    }
  }

  Future<void> viewVotes(Map<String, dynamic> item) async {
    if (loadingVoteDetails) return;

    setState(() => loadingVoteDetails = true);

    try {
      final itemId = item[AppItemFields.id].toString();
      final votes = await voteRepository.getVotesForItem(itemId);

      if (!mounted) return;

      final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

      await showDialog<void>(
        context: context,
        builder: (_) =>
            VoteDetailsDialog(votes: votes, currentUserId: currentUserId),
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToLoadVotes, error);
    } finally {
      if (mounted) {
        setState(() => loadingVoteDetails = false);
      }
    }
  }

  Future<void> viewRecipeDetails(Map<String, dynamic> recipe) async {
    if (loadingRecipeDetails) return;

    setState(() => loadingRecipeDetails = true);

    try {
      final recipeId = recipe['id'].toString();

      var keepDetailsOpen = true;

      while (keepDetailsOpen) {
        final loadedRecipe = await recipeRepository.getRecipe(recipeId);
        final currentRecipe = loadedRecipe ?? recipe;

        final ingredients = await recipeIngredientRepository
            .getIngredientsForRecipe(recipeId);

        if (!mounted) return;

        setState(() => loadingRecipeDetails = false);

        final result = await Navigator.of(context)
            .push<RecipeDetailsPageResult>(
              MaterialPageRoute(
                builder: (_) => RecipeDetailsPage(
                  recipe: currentRecipe,
                  ingredients: ingredients,
                ),
              ),
            );

        if (result == null) {
          keepDetailsOpen = false;
          break;
        }

        if (result.action == RecipeDetailsPageAction.editRecipeInfo) {
          if (!mounted) return;

          final editResult = await Navigator.of(context)
              .push<EditRecipeInfoPageResult>(
                MaterialPageRoute(
                  builder: (_) => EditRecipeInfoPage(recipe: currentRecipe),
                ),
              );

          if (editResult == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeRepository.updateRecipeInfo(
            recipeId: recipeId,
            name: editResult.name,
            description: editResult.description,
            prepTimeMinutes: editResult.prepTimeMinutes,
            cookTimeMinutes: editResult.cookTimeMinutes,
            servings: editResult.servings,
          );

          if (!mounted) return;

          await loadItems();

          if (!mounted) return;

          showSuccessSnackBar(context, context.l10n.recipeInfoUpdated);
          continue;
        }

        if (result.action == RecipeDetailsPageAction.editRecipeInstructions) {
          if (!mounted) return;

          final instructionsResult = await Navigator.of(context)
              .push<EditRecipeInstructionsPageResult>(
                MaterialPageRoute(
                  builder: (_) =>
                      EditRecipeInstructionsPage(recipe: currentRecipe),
                ),
              );

          if (instructionsResult == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeRepository.updateRecipeInstructions(
            recipeId: recipeId,
            instructions: instructionsResult.instructions,
          );

          if (!mounted) return;

          showSuccessSnackBar(context, context.l10n.instructionsUpdated);
          continue;
        }

        if (result.action == RecipeDetailsPageAction.addIngredient) {
          if (!mounted) return;

          final ingredientResult = await Navigator.of(context)
              .push<RecipeIngredientFormPageResult>(
                MaterialPageRoute(
                  builder: (_) => RecipeIngredientFormPage(groupId: groupId),
                ),
              );

          if (ingredientResult == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeIngredientRepository.createIngredient(
            recipeId: recipeId,
            name: ingredientResult.name,
            quantity: ingredientResult.quantity,
            unit: ingredientResult.unit,
            note: ingredientResult.note,
            estimatedUnitPrice: ingredientResult.estimatedUnitPrice,
            priceCurrency: ingredientResult.priceCurrency,
            barcode: ingredientResult.barcode,
            catalogItemId: ingredientResult.catalogItemId,
            productName: ingredientResult.productName,
            productImageUrl: ingredientResult.productImageUrl,
          );

          if (!mounted) return;

          showSuccessSnackBar(context, context.l10n.ingredientAdded);
          continue;
        }

        if (result.action == RecipeDetailsPageAction.editIngredient) {
          final ingredientId = result.ingredientId;
          final ingredient = result.ingredient;

          if (ingredientId == null ||
              ingredientId.isEmpty ||
              ingredient == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          final editIngredientResult = await Navigator.of(context)
              .push<RecipeIngredientFormPageResult>(
                MaterialPageRoute(
                  builder: (_) => RecipeIngredientFormPage(
                    groupId: groupId,
                    ingredient: ingredient,
                  ),
                ),
              );

          if (editIngredientResult == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeIngredientRepository.updateIngredient(
            ingredientId: ingredientId,
            name: editIngredientResult.name,
            quantity: editIngredientResult.quantity,
            unit: editIngredientResult.unit,
            note: editIngredientResult.note,
            estimatedUnitPrice: editIngredientResult.estimatedUnitPrice,
            priceCurrency: editIngredientResult.priceCurrency,
            barcode: editIngredientResult.barcode,
            catalogItemId: editIngredientResult.catalogItemId,
            productName: editIngredientResult.productName,
            productImageUrl: editIngredientResult.productImageUrl,
          );

          if (!mounted) return;

          showSuccessSnackBar(context, context.l10n.ingredientUpdated);
          continue;
        }

        if (result.action == RecipeDetailsPageAction.deleteIngredient) {
          final ingredientId = result.ingredientId;

          if (ingredientId == null || ingredientId.isEmpty) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          final confirmed = await showConfirmDeleteDialog(
            context: context,
            title: context.l10n.deleteIngredient2,
            message: context.l10n.deleteIngredientMessage(
              result.ingredientName ?? context.l10n.thisIngredient,
            ),
          );

          if (!confirmed) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeIngredientRepository.deleteIngredient(ingredientId);

          if (!mounted) return;

          showSuccessSnackBar(context, context.l10n.ingredientDeleted);
          continue;
        }
      }
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, context.l10n.failedToLoadRecipeDetails, error);
    } finally {
      if (mounted) {
        setState(() => loadingRecipeDetails = false);
      }
    }
  }

  void goBack() {
    Navigator.of(context).maybePop(currentList);
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: creatingItem ? null : createItemDialog,
        icon: const Icon(Icons.add),
        label: Text(
          isRecipeList
              ? context.l10n.addRecipe
              : isMealPlanList
              ? context.l10n.addMeal
              : isShoppingList
              ? context.l10n.addItem
              : context.l10n.addItem,
        ),
      ),
      body: Column(
        children: [
          ListDetailHeader(
            listName: listName,
            config: config,
            onBack: goBack,
            onEdit: editList,
          ),
          if (isBusy) const LinearProgressIndicator(),
          Expanded(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: loadItems,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (isShoppingList) ...[
                      _ProductScannerShortcutCard(onTap: openProductScanner),
                      const SizedBox(height: 12),
                      _ProductCatalogShortcutCard(onTap: openProductCatalog),
                      const SizedBox(height: 12),
                    ],
                    ListItemsSection(
                      listType: listType,
                      items: items,
                      loading: loadingItems,
                      showStatusSummary: shouldShowStatusSummary,
                      onCreate: createItemDialog,
                      onComplete: completeItem,
                      onReopen: reopenItem,
                      onEdit: editItem,
                      onDelete: deleteItem,
                      onVote: voteItem,
                      onViewVotes: viewVotes,
                      onViewRecipeDetails: viewRecipeDetails,
                      onDeleteRecipe: deleteRecipe,
                      onGenerateShoppingFromMealPlans:
                          generateShoppingFromMealPlans,
                      onClearBoughtShoppingItems: clearBoughtShoppingItems,
                      onClearAllShoppingItems: clearAllShoppingItems,
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

class _ProductScannerShortcutCard extends StatelessWidget {
  const _ProductScannerShortcutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.qr_code_scanner_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          context.l10n.productScannerTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(context.l10n.productScannerShortcutSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ProductCatalogShortcutCard extends StatelessWidget {
  const _ProductCatalogShortcutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.inventory_2_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          context.l10n.productDatabaseTitle,
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(context.l10n.productCatalogShortcutSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
