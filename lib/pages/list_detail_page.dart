import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/core/item_fields.dart';
import 'package:pesalistas/core/list_fields.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/meal_plan_fields.dart';
import 'package:pesalistas/core/recipe_fields.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/core/ui_feedback.dart';
import 'package:pesalistas/core/vote_fields.dart';
import 'package:pesalistas/dialogs/add_meal_plan_dialog.dart';
import 'package:pesalistas/dialogs/add_recipe_ingredient_dialog.dart';
import 'package:pesalistas/dialogs/confirm_delete_dialog.dart';
import 'package:pesalistas/dialogs/create_item_dialog.dart';
import 'package:pesalistas/dialogs/create_recipe_dialog.dart';
import 'package:pesalistas/dialogs/edit_item_dialog.dart';
import 'package:pesalistas/dialogs/edit_meal_plan_dialog.dart';
import 'package:pesalistas/dialogs/edit_recipe_dialog.dart';
import 'package:pesalistas/dialogs/edit_recipe_ingredient_dialog.dart';
import 'package:pesalistas/dialogs/edit_recipe_instructions_dialog.dart';
import 'package:pesalistas/dialogs/generate_shopping_dialog.dart';
import 'package:pesalistas/dialogs/recipe_details_dialog.dart';
import 'package:pesalistas/dialogs/shopping_item_dialog.dart';
import 'package:pesalistas/dialogs/vote_details_dialog.dart';
import 'package:pesalistas/dialogs/vote_dialog.dart';
import 'package:pesalistas/repositories/item_repository.dart';
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

  List<Map<String, dynamic>> items = [];

  String get listId => widget.list[AppListFields.id].toString();

  String get groupId => widget.list[AppListFields.groupId].toString();

  String get listName => widget.list[AppListFields.name]?.toString() ?? S.list;

  String get listType =>
      widget.list[AppListFields.listType]?.toString() ??
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
      loadingVoteDetails ||
      loadingRecipeDetails ||
      deletingRecipe ||
      generatingShopping;

  @override
  void initState() {
    super.initState();

    final client = Supabase.instance.client;

    itemRepository = ItemRepository(client);
    voteRepository = VoteRepository(client);
    recipeRepository = RecipeRepository(client);
    recipeIngredientRepository = RecipeIngredientRepository(client);
    mealPlanRepository = MealPlanRepository(client);
    shoppingRepository = ShoppingRepository(client);

    loadItems();
  }

  Future<void> loadItems() async {
    if (!mounted) return;

    setState(() => loadingItems = true);

    try {
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

        final enrichedMealPlans = mealPlans.map((mealPlan) {
          final recipeId = mealPlan[AppMealPlanFields.recipeId]?.toString();

          if (recipeId == null || recipeId.isEmpty) {
            return mealPlan;
          }

          final recipe = recipesById[recipeId];

          if (recipe == null) {
            return mealPlan;
          }

          return {...mealPlan, AppMealPlanFields.recipes: recipe};
        }).toList();

        if (!mounted) return;

        setState(() {
          items = enrichedMealPlans;
          loadingItems = false;
        });

        return;
      }

      if (isRecipeList) {
        final recipes = await recipeRepository.getRecipesForGroup(groupId);

        if (!mounted) return;

        setState(() {
          items = recipes;
          loadingItems = false;
        });

        return;
      }

      final loadedItems = await itemRepository.getItemsForList(listId);
      final enrichedItems = await enrichItemsWithVoteSummaries(loadedItems);

      if (!mounted) return;

      setState(() {
        items = enrichedItems;
        loadingItems = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => loadingItems = false);
      showErrorSnackBar(context, S.failedToLoadItems, error);
    }
  }

  Future<void> generateShoppingFromMealPlans() async {
    if (generatingShopping) return;

    final result = await showDialog<GenerateShoppingDialogResult>(
      context: context,
      builder: (_) => const GenerateShoppingDialog(),
    );

    if (result == null) return;

    setState(() => generatingShopping = true);

    try {
      await mealPlanRepository.generateShoppingFromMealPlans(
        groupId: groupId,
        fromDate: result.fromDate,
        toDate: result.toDate,
      );

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        S.shoppingItemsGeneratedOpenShoppingToReviewThem,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToGenerateShoppingItems, error);
    } finally {
      if (mounted) {
        setState(() => generatingShopping = false);
      }
    }
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

    final result = await showDialog<CreateItemDialogResult>(
      context: context,
      builder: (_) => CreateItemDialog(listType: listType),
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
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.itemCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToCreateItem, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<void> createShoppingItemDialog() async {
    final result = await showDialog<ShoppingItemDialogResult>(
      context: context,
      builder: (_) => const ShoppingItemDialog(),
    );

    if (result == null) return;

    setState(() => creatingItem = true);

    try {
      await shoppingRepository.createShoppingItem(
        groupId: groupId,
        name: result.name,
        quantity: result.quantity,
        unit: result.unit,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.shoppingItemCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToCreateShoppingItem, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
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

      showErrorSnackBar(context, S.failedToLoadRecipes, error);
      setState(() => creatingItem = false);
      return;
    }

    if (!mounted) return;

    setState(() => creatingItem = false);

    final result = await showDialog<AddMealPlanDialogResult>(
      context: context,
      builder: (_) => AddMealPlanDialog(recipes: recipes),
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

      showSuccessSnackBar(context, S.mealPlanned);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToCreateMealPlan, error);
    } finally {
      if (mounted) {
        setState(() => creatingItem = false);
      }
    }
  }

  Future<void> createRecipeDialog() async {
    final result = await showDialog<CreateRecipeDialogResult>(
      context: context,
      builder: (_) => const CreateRecipeDialog(),
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

      showSuccessSnackBar(context, S.recipeCreated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToCreateRecipe, error);
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

    final result = await showDialog<EditItemDialogResult>(
      context: context,
      builder: (_) => EditItemDialog(item: item, listType: listType),
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
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.itemUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToUpdateItem, error);
    } finally {
      if (mounted) {
        setState(() => editingItem = false);
      }
    }
  }

  Future<void> editShoppingItem(Map<String, dynamic> item) async {
    if (editingItem) return;

    final result = await showDialog<ShoppingItemDialogResult>(
      context: context,
      builder: (_) => ShoppingItemDialog(item: item),
    );

    if (result == null) return;

    setState(() => editingItem = true);

    try {
      await shoppingRepository.updateShoppingItem(
        shoppingItemId: item[AppShoppingItemFields.id].toString(),
        name: result.name,
        quantity: result.quantity,
        unit: result.unit,
      );

      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.shoppingItemUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToUpdateShoppingItem, error);
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

      showErrorSnackBar(context, S.failedToLoadRecipes, error);
      setState(() => editingItem = false);
      return;
    }

    if (!mounted) return;

    setState(() => editingItem = false);

    final result = await showDialog<EditMealPlanDialogResult>(
      context: context,
      builder: (_) => EditMealPlanDialog(mealPlan: mealPlan, recipes: recipes),
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

      showSuccessSnackBar(context, S.mealPlanUpdated);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToUpdateMealPlan, error);
    } finally {
      if (mounted) {
        setState(() => editingItem = false);
      }
    }
  }

  Future<void> completeItem(String itemId) async {
    if (completingItem) return;

    setState(() => completingItem = true);

    try {
      if (isShoppingList) {
        await setShoppingItemChecked(shoppingItemId: itemId, checked: true);
        return;
      }

      await itemRepository.completeItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.itemCompleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToCompleteItem, error);
    } finally {
      if (mounted) {
        setState(() => completingItem = false);
      }
    }
  }

  Future<void> reopenItem(String itemId) async {
    if (completingItem) return;

    setState(() => completingItem = true);

    try {
      if (isShoppingList) {
        await setShoppingItemChecked(shoppingItemId: itemId, checked: false);
        return;
      }

      await itemRepository.reopenItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        listType == AppListTypes.shopping.value
            ? S.shoppingItemReopened
            : listType == AppListTypes.generic.value
            ? S.itemReopened
            : S.taskReopened,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToReopenItem, error);
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
        checked ? S.markedAsBought : S.markedAsNotBought,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToUpdateShoppingItem, error);
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
      title: S.deleteItem2,
      message: S.thisWillPermanentlyDeleteTheItemFromThisList,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await itemRepository.deleteItem(itemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.itemDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToDeleteItem, error);
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
      title: S.deleteShoppingItem,
      message: S.thisWillRemoveThisItemFromYourShoppingList,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await shoppingRepository.deleteShoppingItem(shoppingItemId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.shoppingItemDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToDeleteShoppingItem, error);
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
      title: S.deleteMealPlan2,
      message: S.thisWillRemoveThisMealFromYourPlan,
    );

    if (!confirmed) return;

    setState(() => deletingItem = true);

    try {
      await mealPlanRepository.deleteMealPlan(mealPlanId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.mealPlanDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToDeleteMealPlan, error);
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
      title: S.deleteRecipe2,
      message: S.thisWillPermanentlyDeleteThisRecipeAndItsIngredients,
    );

    if (!confirmed) return;

    setState(() => deletingRecipe = true);

    try {
      await recipeRepository.deleteRecipe(recipeId);
      await loadItems();

      if (!mounted) return;

      showSuccessSnackBar(context, S.recipeDeleted);
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToDeleteRecipe, error);
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
        result.removeVote ? S.voteRemoved : S.voteSaved,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToSaveVote, error);
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

      showErrorSnackBar(context, S.failedToLoadVotes, error);
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

        final result = await showDialog<RecipeDetailsDialogResult>(
          context: context,
          builder: (_) => RecipeDetailsDialog(
            recipe: currentRecipe,
            ingredients: ingredients,
          ),
        );

        if (result == null) {
          keepDetailsOpen = false;
          break;
        }

        if (result.action == RecipeDetailsDialogAction.editRecipeInfo) {
          if (!mounted) return;

          final editResult = await showDialog<EditRecipeDialogResult>(
            context: context,
            builder: (_) => EditRecipeDialog(recipe: currentRecipe),
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

          showSuccessSnackBar(context, S.recipeInfoUpdated);
          continue;
        }

        if (result.action == RecipeDetailsDialogAction.editRecipeInstructions) {
          if (!mounted) return;

          final instructionsResult =
              await showDialog<EditRecipeInstructionsDialogResult>(
                context: context,
                builder: (_) =>
                    EditRecipeInstructionsDialog(recipe: currentRecipe),
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

          showSuccessSnackBar(context, S.instructionsUpdated);
          continue;
        }

        if (result.action == RecipeDetailsDialogAction.addIngredient) {
          if (!mounted) return;

          final ingredientResult =
              await showDialog<AddRecipeIngredientDialogResult>(
                context: context,
                builder: (_) => const AddRecipeIngredientDialog(),
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
          );

          if (!mounted) return;

          showSuccessSnackBar(context, S.ingredientAdded);
          continue;
        }

        if (result.action == RecipeDetailsDialogAction.editIngredient) {
          final ingredientId = result.ingredientId;
          final ingredient = result.ingredient;

          if (ingredientId == null ||
              ingredientId.isEmpty ||
              ingredient == null) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          final editIngredientResult =
              await showDialog<EditRecipeIngredientDialogResult>(
                context: context,
                builder: (_) =>
                    EditRecipeIngredientDialog(ingredient: ingredient),
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
          );

          if (!mounted) return;

          showSuccessSnackBar(context, S.ingredientUpdated);
          continue;
        }

        if (result.action == RecipeDetailsDialogAction.deleteIngredient) {
          final ingredientId = result.ingredientId;

          if (ingredientId == null || ingredientId.isEmpty) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          final confirmed = await showConfirmDeleteDialog(
            context: context,
            title: S.deleteIngredient2,
            message:
                'This will remove "${result.ingredientName ?? 'this ingredient'}" from the recipe.',
          );

          if (!confirmed) {
            keepDetailsOpen = true;
            continue;
          }

          if (!mounted) return;

          setState(() => loadingRecipeDetails = true);

          await recipeIngredientRepository.deleteIngredient(ingredientId);

          if (!mounted) return;

          showSuccessSnackBar(context, 'Ingredient deleted');
          continue;
        }
      }
    } catch (error) {
      if (!mounted) return;

      showErrorSnackBar(context, S.failedToLoadRecipeDetails, error);
    } finally {
      if (mounted) {
        setState(() => loadingRecipeDetails = false);
      }
    }
  }

  void goBack() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final config = listTypeConfig;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: creatingItem ? null : createItemDialog,
        icon: Icon(Icons.add),
        label: Text(
          isRecipeList
              ? S.addRecipe
              : isMealPlanList
              ? S.addMeal
              : isShoppingList
              ? S.addItem
              : S.addItem,
        ),
      ),
      body: Column(
        children: [
          ListDetailHeader(listName: listName, config: config, onBack: goBack),
          if (isBusy) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadItems,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
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
