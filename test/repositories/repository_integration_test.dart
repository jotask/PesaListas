import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/app_config.dart';
import 'package:pesalistas/core/app_tables.dart';
import 'package:pesalistas/core/fields/catalog_item_fields.dart';
import 'package:pesalistas/core/fields/group_fields.dart';
import 'package:pesalistas/core/fields/item_fields.dart';
import 'package:pesalistas/core/fields/list_fields.dart';
import 'package:pesalistas/core/fields/meal_plan_fields.dart';
import 'package:pesalistas/core/fields/product_fields.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/fields/vote_fields.dart';
import 'package:pesalistas/core/item_assignee_fields.dart';
import 'package:pesalistas/core/item_assignment_scope.dart';
import 'package:pesalistas/core/item_status.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/core/meal_types.dart';
import 'package:pesalistas/core/member_fields.dart';
import 'package:pesalistas/core/product_price_fields.dart';
import 'package:pesalistas/core/recipe_ingredient_fields.dart';
import 'package:pesalistas/core/recurrence_types.dart';
import 'package:pesalistas/core/shopping_item_fields.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
import 'package:pesalistas/repositories/auth_repository.dart';
import 'package:pesalistas/repositories/catalog_item_repository.dart';
import 'package:pesalistas/repositories/group_repository.dart';
import 'package:pesalistas/repositories/item_repository.dart';
import 'package:pesalistas/repositories/list_repository.dart';
import 'package:pesalistas/repositories/meal_plan_repository.dart';
import 'package:pesalistas/repositories/member_repository.dart';
import 'package:pesalistas/repositories/product_repository.dart';
import 'package:pesalistas/repositories/recipe_ingredient_repository.dart';
import 'package:pesalistas/repositories/recipe_repository.dart';
import 'package:pesalistas/repositories/shopping_repository.dart';
import 'package:pesalistas/repositories/vote_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const testSupabaseUrl =
    AppConfig.supabaseUrl; //String.fromEnvironment('TEST_SUPABASE_URL');
const testSupabaseAnonKey = AppConfig
    .supabaseAnonKey; //String.fromEnvironment('TEST_SUPABASE_ANON_KEY');
const testUserEmail =
    "test@test.com"; // String.fromEnvironment('TEST_USER_EMAIL');
const testUserPassword =
    "tester"; //String.fromEnvironment('TEST_USER_PASSWORD');

const hasIntegrationConfig =
    testSupabaseUrl != '' &&
    testSupabaseAnonKey != '' &&
    testUserEmail != '' &&
    testUserPassword != '';

void main() {
  group(
    'PesaListas repository integration tests',
    skip: hasIntegrationConfig
        ? false
        : 'Missing TEST_SUPABASE_URL, TEST_SUPABASE_ANON_KEY, TEST_USER_EMAIL, or TEST_USER_PASSWORD.',
    () {
      late SupabaseClient client;
      late AuthRepository authRepository;
      late GroupRepository groupRepository;
      late ListRepository listRepository;
      late ItemRepository itemRepository;
      late ShoppingRepository shoppingRepository;
      late RecipeRepository recipeRepository;
      late RecipeIngredientRepository recipeIngredientRepository;
      late MealPlanRepository mealPlanRepository;
      late CatalogItemRepository catalogItemRepository;
      late ProductRepository productRepository;
      late VoteRepository voteRepository;
      late MemberRepository memberRepository;

      setUpAll(() async {
        client = SupabaseClient(testSupabaseUrl, testSupabaseAnonKey);

        authRepository = AuthRepository(client);
        groupRepository = GroupRepository(client);
        listRepository = ListRepository(client);
        itemRepository = ItemRepository(client);
        shoppingRepository = ShoppingRepository(client);
        recipeRepository = RecipeRepository(client);
        recipeIngredientRepository = RecipeIngredientRepository(client);
        mealPlanRepository = MealPlanRepository(client);
        catalogItemRepository = CatalogItemRepository(client);
        productRepository = ProductRepository(
          client,
          useStaging: AppConfig.useOpenFoodFactsStaging,
        );
        voteRepository = VoteRepository(client);
        memberRepository = MemberRepository(client);
      });

      setUp(() async {
        await client.auth.signOut();
      });

      test(
        'AuthRepository signs in and signs out with email/password',
        () async {
          expect(authRepository.currentUser, isNull);
          expect(authRepository.currentSession, isNull);

          await authRepository.signInWithPassword(
            email: testUserEmail,
            password: testUserPassword,
          );

          expect(authRepository.currentUser, isNotNull);
          expect(authRepository.currentUser!.email, testUserEmail);
          expect(authRepository.currentSession, isNotNull);

          await authRepository.signOut();

          expect(authRepository.currentUser, isNull);
          expect(authRepository.currentSession, isNull);
        },
      );

      test('creates, edits, reads, and cleans up groups/lists/content', () async {
        await authRepository.signInWithPassword(
          email: testUserEmail,
          password: testUserPassword,
        );

        final currentUser = authRepository.currentUser;
        expect(currentUser, isNotNull);
        final currentUserId = currentUser!.id;

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final groupName = 'TEST Repository Group $timestamp';
        final editedGroupName = '$groupName edited';
        String? groupId;

        try {
          // GROUP REPOSITORY: create, read, update.
          await groupRepository.createGroup(
            name: groupName,
            description: 'Created by repository integration test',
          );

          var group = await findGroupByName(groupRepository, groupName);
          groupId = group[AppGroupFields.id].toString();

          expect(group[AppGroupFields.name], groupName);
          expect(group[AppGroupFields.createdBy], currentUserId);

          await groupRepository.updateGroup(
            groupId: groupId,
            name: editedGroupName,
            description: 'Updated by repository integration test',
          );

          group = await findGroupByName(groupRepository, editedGroupName);
          expect(group[AppGroupFields.id], groupId);
          expect(
            group[AppGroupFields.description],
            'Updated by repository integration test',
          );

          final members = await memberRepository.getGroupMembers(groupId);
          expect(
            members.any(
              (member) => member[AppMemberFields.userId] == currentUserId,
            ),
            isTrue,
            reason: 'Creator should be a member of the test group.',
          );

          // LIST REPOSITORY: create, edit, archive, restore, delete every type.
          for (final listType in AppListTypes.all) {
            final listName = 'TEST ${listType.value} list $timestamp';
            final editedListName = '$listName edited';

            await listRepository.createList(
              groupId: groupId,
              name: listName,
              listType: listType.value,
            );

            var list = await findActiveListByName(
              listRepository,
              groupId,
              listName,
            );

            expect(list[AppListFields.listType], listType.value);
            expect(list[AppListFields.createdBy], currentUserId);

            final listId = list[AppListFields.id].toString();

            await listRepository.updateListInfo(
              listId: listId,
              name: editedListName,
              description: 'Edited ${listType.value} list',
            );

            list = await findActiveListByName(
              listRepository,
              groupId,
              editedListName,
            );
            expect(
              list[AppListFields.description],
              'Edited ${listType.value} list',
            );

            await listRepository.archiveList(listId);
            final archivedLists = await listRepository.getArchivedListsForGroup(
              groupId,
            );
            expect(
              archivedLists.any((row) => row[AppListFields.id] == listId),
              isTrue,
            );

            await listRepository.restoreList(listId);
            final restoredLists = await listRepository.getListsForGroup(
              groupId,
            );
            expect(
              restoredLists.any((row) => row[AppListFields.id] == listId),
              isTrue,
            );

            await listRepository.deleteList(listId);
            final listsAfterDelete = await listRepository.getListsForGroup(
              groupId,
            );
            expect(
              listsAfterDelete.any((row) => row[AppListFields.id] == listId),
              isFalse,
            );
          }

          // Create active lists for content repository flows.
          final genericList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST generic content list $timestamp',
            listType: AppListTypes.generic.value,
          );
          final tasksList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST tasks content list $timestamp',
            listType: AppListTypes.tasks.value,
          );
          final choresList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST chores content list $timestamp',
            listType: AppListTypes.chores.value,
          );
          final moviesList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST movies content list $timestamp',
            listType: AppListTypes.movies.value,
          );
          final ideasList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST ideas content list $timestamp',
            listType: AppListTypes.ideas.value,
          );
          final activitiesList = await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST activities content list $timestamp',
            listType: AppListTypes.activities.value,
          );
          await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST recipes content list $timestamp',
            listType: AppListTypes.recipes.value,
          );
          await createListAndReturn(
            listRepository,
            groupId: groupId,
            name: 'TEST meal plan content list $timestamp',
            listType: AppListTypes.mealPlan.value,
          );

          final shoppingList = await listRepository.ensureShoppingListForGroup(
            groupId: groupId,
          );
          expect(
            shoppingList[AppListFields.listType],
            AppListTypes.shopping.value,
          );

          // ITEM REPOSITORY: generic item.
          final genericItem = await itemRepository.createItem(
            listId: genericList[AppListFields.id].toString(),
            title: 'TEST generic item $timestamp',
            description: 'generic description',
          );
          expect(
            genericItem[AppItemFields.title],
            'TEST generic item $timestamp',
          );

          await itemRepository.updateItem(
            itemId: genericItem[AppItemFields.id].toString(),
            title: 'TEST generic item $timestamp edited',
            description: 'generic description edited',
          );

          var genericItems = await itemRepository.getItemsForList(
            genericList[AppListFields.id].toString(),
          );
          expect(
            genericItems.any(
              (item) =>
                  item[AppItemFields.title] ==
                  'TEST generic item $timestamp edited',
            ),
            isTrue,
          );

          await itemRepository.deleteItem(
            genericItem[AppItemFields.id].toString(),
          );
          genericItems = await itemRepository.getItemsForList(
            genericList[AppListFields.id].toString(),
          );
          expect(
            genericItems.any(
              (item) => item[AppItemFields.id] == genericItem[AppItemFields.id],
            ),
            isFalse,
          );

          // ITEM REPOSITORY: task item with assignment + complete/reopen.
          final taskItem = await itemRepository.createItem(
            listId: tasksList[AppListFields.id].toString(),
            title: 'TEST task item $timestamp',
            description: 'task description',
            priority: 1,
            deadlineAt: DateTime.now().add(const Duration(days: 2)),
            assignmentScope: AppItemAssignmentScopes.specific,
            assigneeUserIds: [currentUserId],
          );
          final taskItemId = taskItem[AppItemFields.id].toString();
          expect(
            taskItem[AppItemFields.assignmentScope],
            AppItemAssignmentScopes.specific,
          );

          var taskAssignees = await itemRepository.getAssigneesForItem(
            taskItemId,
          );
          expect(taskAssignees.length, 1);
          expect(
            taskAssignees.first[AppItemAssigneeFields.userId],
            currentUserId,
          );

          await itemRepository.updateItem(
            itemId: taskItemId,
            title: 'TEST task item $timestamp edited',
            description: 'task description edited',
            updateTaskFields: true,
            priority: 3,
            deadlineAt: DateTime.now().add(const Duration(days: 3)),
            assignmentScope: AppItemAssignmentScopes.all,
            assigneeUserIds: const [],
          );

          var loadedTask = await getItemById(client, taskItemId);
          expect(
            loadedTask[AppItemFields.title],
            'TEST task item $timestamp edited',
          );
          expect(loadedTask[AppItemFields.priority], 3);
          expect(
            loadedTask[AppItemFields.assignmentScope],
            AppItemAssignmentScopes.all,
          );

          taskAssignees = await itemRepository.getAssigneesForItem(taskItemId);
          expect(taskAssignees, isEmpty);

          await itemRepository.completeItem(taskItemId);
          loadedTask = await getItemById(client, taskItemId);
          expect(loadedTask[AppItemFields.status], AppItemStatus.done);

          await itemRepository.reopenItem(taskItemId);
          loadedTask = await getItemById(client, taskItemId);
          expect(loadedTask[AppItemFields.status], AppItemStatus.open);

          // ITEM REPOSITORY: chore item.
          final choreItem = await itemRepository.createItem(
            listId: choresList[AppListFields.id].toString(),
            title: 'TEST chore item $timestamp',
            description: 'chore description',
            recurrenceType: AppRecurrenceTypes.everyNDays.value,
            recurrenceInterval: 3,
            nextDueAt: DateTime.now().add(const Duration(days: 1)),
            assignmentScope: AppItemAssignmentScopes.specific,
            assigneeUserIds: [currentUserId],
          );
          final choreItemId = choreItem[AppItemFields.id].toString();

          await itemRepository.updateItem(
            itemId: choreItemId,
            title: 'TEST chore item $timestamp edited',
            description: 'chore description edited',
            updateChoreFields: true,
            recurrenceType: AppRecurrenceTypes.weekly.value,
            recurrenceInterval: null,
            nextDueAt: DateTime.now().add(const Duration(days: 7)),
            assignmentScope: AppItemAssignmentScopes.none,
            assigneeUserIds: const [],
          );

          final loadedChore = await getItemById(client, choreItemId);
          expect(
            loadedChore[AppItemFields.title],
            'TEST chore item $timestamp edited',
          );
          expect(
            loadedChore[AppItemFields.recurrenceType],
            AppRecurrenceTypes.weekly.value,
          );
          expect(
            loadedChore[AppItemFields.assignmentScope],
            AppItemAssignmentScopes.none,
          );

          // VOTABLE ITEMS + VOTE REPOSITORY.
          for (final entry in [
            MapEntry(moviesList, 'movie'),
            MapEntry(ideasList, 'idea'),
            MapEntry(activitiesList, 'activity'),
          ]) {
            final item = await itemRepository.createItem(
              listId: entry.key[AppListFields.id].toString(),
              title: 'TEST ${entry.value} item $timestamp',
              description: '${entry.value} description',
            );
            final itemId = item[AppItemFields.id].toString();

            await voteRepository.upsertVote(
              itemId: itemId,
              points: 7,
              comment: 'Repository test vote',
            );

            final myVote = await voteRepository.getMyVote(itemId);
            expect(myVote, isNotNull);
            expect(myVote![AppVoteFields.points], 7);

            final votes = await voteRepository.getVotesForItem(itemId);
            expect(votes.length, 1);

            final summaries = await voteRepository.getVoteSummariesForItems([
              itemId,
            ]);
            expect(summaries[itemId]![AppVoteSummaryFields.totalPoints], 7);
            expect(summaries[itemId]![AppVoteSummaryFields.voteCount], 1);
            expect(summaries[itemId]![AppVoteSummaryFields.myPoints], 7);

            await voteRepository.deleteMyVote(itemId);
            final deletedVote = await voteRepository.getMyVote(itemId);
            expect(deletedVote, isNull);
          }

          // CATALOG ITEM + PRODUCT PRICE REPOSITORY.
          final catalogItemName = 'TEST Tomatoes $timestamp';
          final catalogItem = await catalogItemRepository.createCatalogItem(
            name: catalogItemName,
            category: 'vegetables',
            defaultUnit: 'g',
            iconName: 'tomato',
          );
          final catalogItemId = catalogItem[AppCatalogItemFields.id].toString();
          expect(catalogItem[AppCatalogItemFields.name], catalogItemName);

          final searchResults = await catalogItemRepository.searchCatalogItems(
            catalogItemName,
          );
          expect(
            searchResults.any(
              (item) => item[AppCatalogItemFields.id] == catalogItemId,
            ),
            isTrue,
          );

          final catalogPrice = await productRepository.saveCatalogItemPrice(
            groupId: groupId,
            catalogItemId: catalogItemId,
            price: 2.30,
            priceQuantity: 1000,
            priceUnit: 'g',
            storeName: 'Repository Test Store',
            note: 'Generic item price test',
          );
          expect(
            catalogPrice[AppProductPriceFields.catalogItemId],
            catalogItemId,
          );

          final latestCatalogPrice = await productRepository
              .getLatestCatalogItemPrice(
                groupId: groupId,
                catalogItemId: catalogItemId,
              );
          expect(latestCatalogPrice, isNotNull);
          expect(latestCatalogPrice![AppProductPriceFields.priceUnit], 'g');

          final testBarcode = 'TEST-BARCODE-$timestamp';

          await client.from(ProductRepository.productsTable).upsert({
            AppProductFields.barcode: testBarcode,
            AppProductFields.name: 'TEST product $timestamp',
            AppProductFields.brand: 'Repository Test Brand',
            AppProductFields.quantity: '1 pcs',
            AppProductFields.imageUrl: null,
            AppProductFields.categories: 'test',
            AppProductFields.nutriscore: null,
            AppProductFields.novaGroup: null,
            AppProductFields.ecoscore: null,
            AppProductFields.rawJson: {
              'source': 'repository_integration_test',
              'timestamp': timestamp,
            },
            AppProductFields.source: 'repository_test',
            AppProductFields.status: AppProductStatus.found,
            AppProductFields.fetchedAt: DateTime.now()
                .toUtc()
                .toIso8601String(),
            AppProductFields.updatedAt: DateTime.now()
                .toUtc()
                .toIso8601String(),
          }, onConflict: AppProductFields.barcode);

          final productPrice = await productRepository.savePrice(
            groupId: groupId,
            barcode: testBarcode,
            price: 1.99,
            priceQuantity: 1,
            priceUnit: 'pcs',
            storeName: 'Repository Test Store',
          );
          expect(productPrice[AppProductPriceFields.barcode], testBarcode);

          final latestBarcodePrice = await productRepository.getLatestPrice(
            groupId: groupId,
            barcode: testBarcode,
          );
          expect(latestBarcodePrice, isNotNull);
          expect(latestBarcodePrice![AppProductPriceFields.priceUnit], 'pcs');

          // SHOPPING REPOSITORY.
          await shoppingRepository.createShoppingItem(
            groupId: groupId,
            name: 'TEST shopping item $timestamp',
            quantity: 2,
            unit: 'pcs',
            estimatedUnitPrice: 1.50,
            priceCurrency: AppConfig.defaultCurrency,
            catalogItemId: catalogItemId,
            productName: catalogItemName,
          );

          var shoppingItems = await shoppingRepository.getShoppingItemsForGroup(
            groupId,
          );
          var shoppingItem = shoppingItems.firstWhere(
            (item) =>
                item[AppShoppingItemFields.name] ==
                'TEST shopping item $timestamp',
          );
          final shoppingItemId = shoppingItem[AppShoppingItemFields.id]
              .toString();
          expect(shoppingItem[AppShoppingItemFields.estimatedTotalPrice], 3.0);

          await shoppingRepository.updateShoppingItem(
            shoppingItemId: shoppingItemId,
            name: 'TEST shopping item $timestamp edited',
            quantity: 3,
            unit: 'pcs',
            estimatedUnitPrice: 2.00,
            priceCurrency: AppConfig.defaultCurrency,
            catalogItemId: catalogItemId,
            productName: catalogItemName,
          );

          await shoppingRepository.setShoppingItemChecked(
            shoppingItemId: shoppingItemId,
            checked: true,
          );

          shoppingItems = await shoppingRepository.getShoppingItemsForGroup(
            groupId,
          );
          shoppingItem = shoppingItems.firstWhere(
            (item) =>
                item[AppShoppingItemFields.id].toString() == shoppingItemId,
          );
          expect(
            shoppingItem[AppShoppingItemFields.name],
            'TEST shopping item $timestamp edited',
          );
          expect(shoppingItem[AppShoppingItemFields.checked], true);
          expect(shoppingItem[AppShoppingItemFields.estimatedTotalPrice], 6.0);

          await shoppingRepository.clearBoughtItems(groupId);
          shoppingItems = await shoppingRepository.getShoppingItemsForGroup(
            groupId,
          );
          expect(
            shoppingItems.any(
              (item) =>
                  item[AppShoppingItemFields.id].toString() == shoppingItemId,
            ),
            isFalse,
          );

          final shoppingFromProduct = await shoppingRepository
              .createShoppingItemFromProduct(
                groupId: groupId,
                name: 'TEST product shopping item $timestamp',
                quantity: 1,
                unit: 'pcs',
                barcode: testBarcode,
                productName: 'Test Product',
                estimatedUnitPrice: 4.20,
                priceCurrency: AppConfig.defaultCurrency,
              );
          expect(
            shoppingFromProduct[AppShoppingItemFields.barcode],
            testBarcode,
          );
          await shoppingRepository.deleteShoppingItem(
            shoppingFromProduct[AppShoppingItemFields.id].toString(),
          );

          // RECIPE + INGREDIENT REPOSITORIES.
          final recipe = await recipeRepository.createRecipe(
            groupId: groupId,
            name: 'TEST recipe $timestamp',
            description: 'Repository recipe test',
          );
          final recipeId = recipe[AppRecipeFields.id].toString();
          expect(recipe[AppRecipeFields.name], 'TEST recipe $timestamp');

          await recipeRepository.updateRecipeInfo(
            recipeId: recipeId,
            name: 'TEST recipe $timestamp edited',
            description: 'Repository recipe test edited',
            prepTimeMinutes: 10,
            cookTimeMinutes: 20,
            servings: 2,
          );

          await recipeRepository.updateRecipeInstructions(
            recipeId: recipeId,
            instructions: 'Cook and serve.',
          );

          var loadedRecipe = await recipeRepository.getRecipe(recipeId);
          expect(loadedRecipe, isNotNull);
          expect(
            loadedRecipe![AppRecipeFields.name],
            'TEST recipe $timestamp edited',
          );
          expect(loadedRecipe[AppRecipeFields.instructions], 'Cook and serve.');
          expect(loadedRecipe[AppRecipeFields.servings], 2);

          await recipeIngredientRepository.createIngredient(
            recipeId: recipeId,
            name: 'TEST ingredient $timestamp',
            quantity: 500,
            unit: 'g',
            note: 'ingredient note',
            estimatedUnitPrice: 0.0023,
            priceCurrency: AppConfig.defaultCurrency,
            catalogItemId: catalogItemId,
            productName: catalogItemName,
          );

          var ingredients = await recipeIngredientRepository
              .getIngredientsForRecipe(recipeId);
          var ingredient = ingredients.firstWhere(
            (row) =>
                row[AppRecipeIngredientFields.name] ==
                'TEST ingredient $timestamp',
          );
          final ingredientId = ingredient[AppRecipeIngredientFields.id]
              .toString();
          expect(
            ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
            closeTo(1.15, 0.000001),
          );

          await recipeIngredientRepository.updateIngredient(
            ingredientId: ingredientId,
            name: 'TEST ingredient $timestamp edited',
            quantity: 1000,
            unit: 'g',
            note: 'ingredient note edited',
            estimatedUnitPrice: 0.002,
            priceCurrency: AppConfig.defaultCurrency,
            catalogItemId: catalogItemId,
            productName: catalogItemName,
          );

          ingredients = await recipeIngredientRepository
              .getIngredientsForRecipe(recipeId);
          ingredient = ingredients.firstWhere(
            (row) =>
                row[AppRecipeIngredientFields.id].toString() == ingredientId,
          );
          expect(
            ingredient[AppRecipeIngredientFields.name],
            'TEST ingredient $timestamp edited',
          );
          expect(
            ingredient[AppRecipeIngredientFields.estimatedTotalPrice],
            2.0,
          );

          // MEAL PLAN REPOSITORY.
          final plannedFor = DateTime.now().add(const Duration(days: 1));
          await mealPlanRepository.createMealPlan(
            groupId: groupId,
            plannedFor: plannedFor,
            mealType: AppMealTypes.dinner,
            recipeId: recipeId,
            note: 'TEST meal plan $timestamp',
          );

          var mealPlans = await mealPlanRepository.getMealPlansForGroup(
            groupId,
          );
          var mealPlan = mealPlans.firstWhere(
            (row) => row[AppMealPlanFields.note] == 'TEST meal plan $timestamp',
          );
          final mealPlanId = mealPlan[AppMealPlanFields.id].toString();
          expect(mealPlan[AppMealPlanFields.recipeId], recipeId);

          await mealPlanRepository.updateMealPlan(
            mealPlanId: mealPlanId,
            plannedFor: plannedFor.add(const Duration(days: 1)),
            mealType: AppMealTypes.lunch,
            recipeId: recipeId,
            note: 'TEST meal plan $timestamp edited',
          );

          mealPlans = await mealPlanRepository.getMealPlansForGroup(groupId);
          mealPlan = mealPlans.firstWhere(
            (row) => row[AppMealPlanFields.id].toString() == mealPlanId,
          );
          expect(mealPlan[AppMealPlanFields.mealType], AppMealTypes.lunch);
          expect(
            mealPlan[AppMealPlanFields.note],
            'TEST meal plan $timestamp edited',
          );

          final generatedCount = await mealPlanRepository
              .generateShoppingFromMealPlans(
                groupId: groupId,
                fromDate: plannedFor,
                toDate: plannedFor.add(const Duration(days: 2)),
              );
          expect(generatedCount, greaterThanOrEqualTo(1));

          final generatedCountAgain = await mealPlanRepository
              .generateShoppingFromMealPlans(
                groupId: groupId,
                fromDate: plannedFor,
                toDate: plannedFor.add(const Duration(days: 2)),
              );
          expect(generatedCountAgain, 0);

          shoppingItems = await shoppingRepository.getShoppingItemsForGroup(
            groupId,
          );
          expect(
            shoppingItems.any(
              (item) =>
                  item[AppShoppingItemFields.sourceMealPlanId] == mealPlanId,
            ),
            isTrue,
          );

          await mealPlanRepository.deleteMealPlan(mealPlanId);
          await recipeIngredientRepository.deleteIngredient(ingredientId);
          await recipeRepository.deleteRecipe(recipeId);

          // GROUP DELETE/CLEANUP.
          await cleanupTestGroup(client, groupId);
          final deletedGroupRows = await client
              .from(AppTables.groups)
              .select()
              .eq(AppGroupFields.id, groupId);
          expect(deletedGroupRows, isEmpty);
          groupId = null;
        } finally {
          if (groupId != null) {
            await cleanupTestGroupBestEffort(client, groupId);
          }
          await authRepository.signOut();
        }
      });
    },
  );
}

Future<Map<String, dynamic>> findGroupByName(
  GroupRepository repository,
  String name,
) async {
  final groups = await repository.getMyGroups();

  return groups.firstWhere(
    (group) => group[AppGroupFields.name] == name,
    orElse: () => throw StateError('Group not found: $name'),
  );
}

Future<Map<String, dynamic>> findActiveListByName(
  ListRepository repository,
  String groupId,
  String name,
) async {
  final lists = await repository.getListsForGroup(groupId);

  return lists.firstWhere(
    (list) => list[AppListFields.name] == name,
    orElse: () => throw StateError('List not found: $name'),
  );
}

Future<Map<String, dynamic>> createListAndReturn(
  ListRepository repository, {
  required String groupId,
  required String name,
  required String listType,
}) async {
  await repository.createList(groupId: groupId, name: name, listType: listType);

  return findActiveListByName(repository, groupId, name);
}

Future<Map<String, dynamic>> getItemById(
  SupabaseClient client,
  String itemId,
) async {
  final item = await client
      .from(AppTables.items)
      .select()
      .eq(AppItemFields.id, itemId)
      .single();

  return Map<String, dynamic>.from(item);
}

Future<void> cleanupTestGroupBestEffort(
  SupabaseClient client,
  String groupId,
) async {
  try {
    await cleanupTestGroup(client, groupId);
  } catch (_) {
    // Do not hide the original test failure with a cleanup failure.
  }
}

Future<void> cleanupTestGroup(SupabaseClient client, String groupId) async {
  final listsResponse = await client
      .from(AppTables.lists)
      .select(AppListFields.id)
      .eq(AppListFields.groupId, groupId);
  final listIds = List<Map<String, dynamic>>.from(listsResponse)
      .map((row) => row[AppListFields.id]?.toString())
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toList();

  if (listIds.isNotEmpty) {
    final itemsResponse = await client
        .from(AppTables.items)
        .select(AppItemFields.id)
        .inFilter(AppItemFields.listId, listIds);
    final itemIds = List<Map<String, dynamic>>.from(itemsResponse)
        .map((row) => row[AppItemFields.id]?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();

    if (itemIds.isNotEmpty) {
      await client
          .from(AppTables.itemAssignees)
          .delete()
          .inFilter(AppItemAssigneeFields.itemId, itemIds);
      await client
          .from(AppTables.itemVotes)
          .delete()
          .inFilter(AppVoteFields.itemId, itemIds);
      await client
          .from(AppTables.itemCompletions)
          .delete()
          .inFilter('item_id', itemIds);
      await client
          .from(AppTables.items)
          .delete()
          .inFilter(AppItemFields.id, itemIds);
    }
  }

  await client
      .from(AppTables.shoppingListItems)
      .delete()
      .eq(AppShoppingItemFields.groupId, groupId);

  await client
      .from(ProductRepository.productPricesTable)
      .delete()
      .eq(AppProductPriceFields.groupId, groupId);

  await client
      .from(AppTables.mealPlans)
      .delete()
      .eq(AppMealPlanFields.groupId, groupId);

  final recipesResponse = await client
      .from(AppTables.recipes)
      .select(AppRecipeFields.id)
      .eq(AppRecipeFields.groupId, groupId);
  final recipeIds = List<Map<String, dynamic>>.from(recipesResponse)
      .map((row) => row[AppRecipeFields.id]?.toString())
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toList();

  if (recipeIds.isNotEmpty) {
    await client
        .from(AppTables.recipeIngredients)
        .delete()
        .inFilter(AppRecipeIngredientFields.recipeId, recipeIds);
    await client
        .from(AppTables.recipes)
        .delete()
        .inFilter(AppRecipeFields.id, recipeIds);
  }

  if (listIds.isNotEmpty) {
    await client
        .from(AppTables.lists)
        .delete()
        .inFilter(AppListFields.id, listIds);
  }

  await client
      .from(AppTables.groupInvitations)
      .delete()
      .eq('group_id', groupId);
  await client
      .from(AppTables.groupMembers)
      .delete()
      .eq(AppMemberFields.groupId, groupId);
  await client.from(AppTables.groups).delete().eq(AppGroupFields.id, groupId);
}
