import 'package:flutter/widgets.dart';
import 'package:pesalistas/core/app_locale_controller.dart';

class S {
  const S._();

  static String get _languageCode {
    final forced = AppLocaleController.locale.value?.languageCode;
    if (forced == 'es' || forced == 'en') return forced!;
    final platform = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return platform == 'es' ? 'es' : 'en';
  }

  static String tr(String key) {
    final table = _localizedValues[_languageCode] ?? _localizedValues['en']!;
    return table[key] ?? _localizedValues['en']![key] ?? key;
  }

  static String get aSharedSpaceForListsRecipesChoresAndPlanning => tr('aSharedSpaceForListsRecipesChoresAndPlanning');
  static String get accept => tr('accept');
  static String get accountSectionTitle => tr('accountSectionTitle');
  static String get activities => tr('activities');
  static String get add => tr('add');
  static String get addAMovieToWatch => tr('addAMovieToWatch');
  static String get addAnItemQuantityAndUnit => tr('addAnItemQuantityAndUnit');
  static String get addDeadline => tr('addDeadline');
  static String get addIngredient => tr('addIngredient');
  static String get addIngredientsFromPlannedRecipeMeals => tr('addIngredientsFromPlannedRecipeMeals');
  static String get addItem => tr('addItem');
  static String get addMeal => tr('addMeal');
  static String get addMealPlan => tr('addMealPlan');
  static String get addOneIngredientForThisRecipe => tr('addOneIngredientForThisRecipe');
  static String get addRecipe => tr('addRecipe');
  static String get addShoppingItem => tr('addShoppingItem');
  static String get addSomethingFunToDo => tr('addSomethingFunToDo');
  static String get addThePreparationStepsForThisRecipe => tr('addThePreparationStepsForThisRecipe');
  static String get addYourFirstIdea => tr('addYourFirstIdea');
  static String get addYourFirstItem => tr('addYourFirstItem');
  static String get addYourFirstRecipe => tr('addYourFirstRecipe');
  static String get alreadyHaveAnAccountLogIn => tr('alreadyHaveAnAccountLogIn');
  static String get amountNotSet => tr('amountNotSet');
  static String get average => tr('average');
  static String get back => tr('back');
  static String get bought => tr('bought');
  static String get breakfast => tr('breakfast');
  static String get buyMilkWatchMovieCleanKitchen => tr('buyMilkWatchMovieCleanKitchen');
  static String get cancel => tr('cancel');
  static String get cancelInvitation => tr('cancelInvitation');
  static String get changeVote => tr('changeVote');
  static String get checkYourEmailToConfirmYourAccount => tr('checkYourEmailToConfirmYourAccount');
  static String get chooseHowOftenThisChoreRepeats => tr('chooseHowOftenThisChoreRepeats');
  static String get chores => tr('chores');
  static String get clearFilter => tr('clearFilter');
  static String get close => tr('close');
  static String get comingSoon => tr('comingSoon');
  static String get comingSoonMessage => tr('comingSoonMessage');
  static String get comment => tr('comment');
  static String get completeChore => tr('completeChore');
  static String get completeNow => tr('completeNow');
  static String get completeTask => tr('completeTask');
  static String get continueWithGoogle => tr('continueWithGoogle');
  static String get cook => tr('cook');
  static String get cookNotSet => tr('cookNotSet');
  static String get cookTime => tr('cookTime');
  static String get cookingInstructions => tr('cookingInstructions');
  static String get create => tr('create');
  static String get createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM => tr('createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM');
  static String get createAccount => tr('createAccount');
  static String get createGroup => tr('createGroup');
  static String get createList => tr('createList');
  static String get createYourFirstChore => tr('createYourFirstChore');
  static String get createYourFirstGroup => tr('createYourFirstGroup');
  static String get createYourFirstSharedListHere => tr('createYourFirstSharedListHere');
  static String get createYourFirstSharedSpace => tr('createYourFirstSharedSpace');
  static String get createYourFirstTask => tr('createYourFirstTask');
  static String get custom => tr('custom');
  static String get customMeal => tr('customMeal');
  static String get customMealWillNotGenerateShoppingItems => tr('customMealWillNotGenerateShoppingItems');
  static String get customRecurrenceMustBeAtLeast2Days => tr('customRecurrenceMustBeAtLeast2Days');
  static String get daily => tr('daily');
  static String get days => tr('days');
  static String get declineInvitationIsNotAvailableYet => tr('declineInvitationIsNotAvailableYet');
  static String get delete => tr('delete');
  static String get deleteChore => tr('deleteChore');
  static String get deleteIngredient => tr('deleteIngredient');
  static String get deleteIngredient2 => tr('deleteIngredient2');
  static String get deleteItem => tr('deleteItem');
  static String get deleteItem2 => tr('deleteItem2');
  static String get deleteMealPlan => tr('deleteMealPlan');
  static String get deleteMealPlan2 => tr('deleteMealPlan2');
  static String get deleteRecipe => tr('deleteRecipe');
  static String get deleteRecipe2 => tr('deleteRecipe2');
  static String get deleteShoppingItem => tr('deleteShoppingItem');
  static String get deleteTask => tr('deleteTask');
  static String get description => tr('description');
  static String get dinner => tr('dinner');
  static String get doesNotRepeat => tr('doesNotRepeat');
  static String get doesNotRepeat2 => tr('doesNotRepeat2');
  static String get done => tr('done');
  static String get edit => tr('edit');
  static String get editChore => tr('editChore');
  static String get editGroup => tr('editGroup');
  static String get editIngredient => tr('editIngredient');
  static String get editInstructions => tr('editInstructions');
  static String get editItem => tr('editItem');
  static String get editMealPlan => tr('editMealPlan');
  static String get editProfileDialogTitle => tr('editProfileDialogTitle');
  static String get editProfileDisplayNameLabel => tr('editProfileDisplayNameLabel');
  static String get editProfileDisplayNameRequired => tr('editProfileDisplayNameRequired');
  static String get editProfileDisplayNameSubtitle => tr('editProfileDisplayNameSubtitle');
  static String get editProfileDisplayNameTitle => tr('editProfileDisplayNameTitle');
  static String get editRecipeInfo => tr('editRecipeInfo');
  static String get editShoppingItem => tr('editShoppingItem');
  static String get editTask => tr('editTask');
  static String get email => tr('email');
  static String get emailAndPasswordAreRequired => tr('emailAndPasswordAreRequired');
  static String get everyNDays => tr('everyNDays');
  static String get everythingInThisListIsDone => tr('everythingInThisListIsDone');
  static String get failedToAcceptInvitation => tr('failedToAcceptInvitation');
  static String get failedToCompleteItem => tr('failedToCompleteItem');
  static String get failedToCreateGroup => tr('failedToCreateGroup');
  static String get failedToCreateItem => tr('failedToCreateItem');
  static String get failedToCreateList => tr('failedToCreateList');
  static String get failedToCreateMealPlan => tr('failedToCreateMealPlan');
  static String get failedToCreateRecipe => tr('failedToCreateRecipe');
  static String get failedToCreateShoppingItem => tr('failedToCreateShoppingItem');
  static String get failedToDeleteItem => tr('failedToDeleteItem');
  static String get failedToDeleteMealPlan => tr('failedToDeleteMealPlan');
  static String get failedToDeleteRecipe => tr('failedToDeleteRecipe');
  static String get failedToDeleteShoppingItem => tr('failedToDeleteShoppingItem');
  static String get failedToGenerateShoppingItems => tr('failedToGenerateShoppingItems');
  static String get failedToInviteMember => tr('failedToInviteMember');
  static String get failedToLoadHomeData => tr('failedToLoadHomeData');
  static String get failedToLoadInvitations => tr('failedToLoadInvitations');
  static String get failedToLoadItems => tr('failedToLoadItems');
  static String get failedToLoadLists => tr('failedToLoadLists');
  static String get failedToLoadMembers => tr('failedToLoadMembers');
  static String get failedToLoadRecipeDetails => tr('failedToLoadRecipeDetails');
  static String get failedToLoadRecipes => tr('failedToLoadRecipes');
  static String get failedToLoadVotes => tr('failedToLoadVotes');
  static String get failedToReopenItem => tr('failedToReopenItem');
  static String get failedToSaveVote => tr('failedToSaveVote');
  static String get failedToUpdateGroup => tr('failedToUpdateGroup');
  static String get failedToUpdateItem => tr('failedToUpdateItem');
  static String get failedToUpdateMealPlan => tr('failedToUpdateMealPlan');
  static String get failedToUpdateShoppingItem => tr('failedToUpdateShoppingItem');
  static String get friendExampleCom => tr('friendExampleCom');
  static String get fromMealPlan => tr('fromMealPlan');
  static String get fromMealPlans => tr('fromMealPlans');
  static String get generate => tr('generate');
  static String get generateShoppingList => tr('generateShoppingList');
  static String get genericList => tr('genericList');
  static String get googleLoginFailed => tr('googleLoginFailed');
  static String get groupCreated => tr('groupCreated');
  static String get groupInfo => tr('groupInfo');
  static String get groupInvitation => tr('groupInvitation');
  static String get groupInvitesWillAppearHere => tr('groupInvitesWillAppearHere');
  static String get groupName => tr('groupName');
  static String get groupNameIsRequired => tr('groupNameIsRequired');
  static String get groupUpdated => tr('groupUpdated');
  static String get high => tr('high');
  static String get highPriority => tr('highPriority');
  static String get ideas => tr('ideas');
  static String get ideasToCollectAndDiscuss => tr('ideasToCollectAndDiscuss');
  static String get individual => tr('individual');
  static String get info => tr('info');
  static String get ingredient => tr('ingredient');
  static String get ingredientAdded => tr('ingredientAdded');
  static String get ingredientNameIsRequired => tr('ingredientNameIsRequired');
  static String get ingredientUpdated => tr('ingredientUpdated');
  static String get ingredients => tr('ingredients');
  static String get ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde => tr('ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde');
  static String get instructions => tr('instructions');
  static String get instructionsAdded => tr('instructionsAdded');
  static String get instructionsUpdated => tr('instructionsUpdated');
  static String get invitationAccepted => tr('invitationAccepted');
  static String get invite => tr('invite');
  static String get inviteMember => tr('inviteMember');
  static String get inviteSomeoneToShareThisGroup => tr('inviteSomeoneToShareThisGroup');
  static String get itemCompleted => tr('itemCompleted');
  static String get itemCreated => tr('itemCreated');
  static String get itemDeleted => tr('itemDeleted');
  static String get itemNameIsRequired => tr('itemNameIsRequired');
  static String get itemReopened => tr('itemReopened');
  static String get itemUpdated => tr('itemUpdated');
  static String get languageDialogTitle => tr('languageDialogTitle');
  static String get languageEnglish => tr('languageEnglish');
  static String get languageSettingsFeature => tr('languageSettingsFeature');
  static String get languageSpanish => tr('languageSpanish');
  static String get languageSubtitle => tr('languageSubtitle');
  static String get languageSubtitleEnglish => tr('languageSubtitleEnglish');
  static String get languageSubtitleSpanish => tr('languageSubtitleSpanish');
  static String get languageSubtitleSystem => tr('languageSubtitleSystem');
  static String get languageSystem => tr('languageSystem');
  static String get languageTitle => tr('languageTitle');
  static String get list => tr('list');
  static String get listName => tr('listName');
  static String get listType => tr('listType');
  static String get loadingInvitations => tr('loadingInvitations');
  static String get logIn => tr('logIn');
  static String get logInToManageYourSharedListsPlansAndChores => tr('logInToManageYourSharedListsPlansAndChores');
  static String get low => tr('low');
  static String get lowPriority => tr('lowPriority');
  static String get lunch => tr('lunch');
  static String get markAsBought => tr('markAsBought');
  static String get markAsDone => tr('markAsDone');
  static String get markAsNotBought => tr('markAsNotBought');
  static String get markAsOpen => tr('markAsOpen');
  static String get markedAsBought => tr('markedAsBought');
  static String get markedAsNotBought => tr('markedAsNotBought');
  static String get meAndPartner => tr('meAndPartner');
  static String get mealPlan => tr('mealPlan');
  static String get mealPlanDeleted => tr('mealPlanDeleted');
  static String get mealPlanUpdated => tr('mealPlanUpdated');
  static String get mealPlanned => tr('mealPlanned');
  static String get mealPlanning => tr('mealPlanning');
  static String get mealType => tr('mealType');
  static String get mealsAndCookingIdeas => tr('mealsAndCookingIdeas');
  static String get medium => tr('medium');
  static String get mediumPriority => tr('mediumPriority');
  static String get member => tr('member');
  static String get minimum2Days => tr('minimum2Days');
  static String get missingGoogleIdToken => tr('missingGoogleIdToken');
  static String get monthly => tr('monthly');
  static String get movies => tr('movies');
  static String get moviesToWatch => tr('moviesToWatch');
  static String get moviesToWatchAndVoteOn => tr('moviesToWatchAndVoteOn');
  static String get myGroups => tr('myGroups');
  static String get name => tr('name');
  static String get needAnAccountSignUp => tr('needAnAccountSignUp');
  static String get newGroup => tr('newGroup');
  static String get newList => tr('newList');
  static String get noActivitiesYet => tr('noActivitiesYet');
  static String get noChoresYet => tr('noChoresYet');
  static String get noComment => tr('noComment');
  static String get noDate => tr('noDate');
  static String get noDeadline => tr('noDeadline');
  static String get noDoneItems => tr('noDoneItems');
  static String get noDueDate => tr('noDueDate');
  static String get noGroupsYet => tr('noGroupsYet');
  static String get noIdeasYet => tr('noIdeasYet');
  static String get noIngredientsYet => tr('noIngredientsYet');
  static String get noInstructions => tr('noInstructions');
  static String get noInstructionsYet => tr('noInstructionsYet');
  static String get noItemsYet => tr('noItemsYet');
  static String get noListsYet => tr('noListsYet');
  static String get noMealPlansYet => tr('noMealPlansYet');
  static String get noMealsThisWeek => tr('noMealsThisWeek');
  static String get noMembersLoaded => tr('noMembersLoaded');
  static String get noMoviesYet => tr('noMoviesYet');
  static String get noOpenItems => tr('noOpenItems');
  static String get noPastMeals => tr('noPastMeals');
  static String get noPendingInvitations => tr('noPendingInvitations');
  static String get noPeopleYet => tr('noPeopleYet');
  static String get noPriority => tr('noPriority');
  static String get noRecipeCustomMeal => tr('noRecipeCustomMeal');
  static String get noRecipesYet => tr('noRecipesYet');
  static String get noShoppingItemsYet => tr('noShoppingItemsYet');
  static String get noTasksYet => tr('noTasksYet');
  static String get noUpcomingMeals => tr('noUpcomingMeals');
  static String get noVotesYet => tr('noVotesYet');
  static String get noVotesYet2 => tr('noVotesYet2');
  static String get nonRecurringChoresCanStillBeCompletedManually => tr('nonRecurringChoresCanStillBeCompletedManually');
  static String get none => tr('none');
  static String get note => tr('note');
  static String get noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop => tr('noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop');
  static String get nothingHasBeenCompletedYet => tr('nothingHasBeenCompletedYet');
  static String get nothingPlannedForTheNext7Days => tr('nothingPlannedForTheNext7Days');
  static String get notificationSettingsFeature => tr('notificationSettingsFeature');
  static String get notificationsSubtitle => tr('notificationsSubtitle');
  static String get notificationsTitle => tr('notificationsTitle');
  static String get open => tr('open');
  static String get openRecipe => tr('openRecipe');
  static String get optional => tr('optional');
  static String get optional2 => tr('optional2');
  static String get optionalEGFamilyDinnerOrLeftovers => tr('optionalEGFamilyDinnerOrLeftovers');
  static String get optionalYouCanAlsoCreateACustomMealNote => tr('optionalYouCanAlsoCreateACustomMealNote');
  static String get organizeLifeTogether => tr('organizeLifeTogether');
  static String get overdue => tr('overdue');
  static String get password => tr('password');
  static String get pastMealsWillAppearHere => tr('pastMealsWillAppearHere');
  static String get pcsGMl => tr('pcsGMl');
  static String get pendingInvitations => tr('pendingInvitations');
  static String get pendingInvite => tr('pendingInvite');
  static String get pesaListas => tr('pesaListas');
  static String get pesalistas => tr('pesalistas');
  static String get planAMealForADateAndOptionallyChooseARecipe => tr('planAMealForADateAndOptionallyChooseARecipe');
  static String get planAMealForTodayOrLater => tr('planAMealForTodayOrLater');
  static String get planMealsByDay => tr('planMealsByDay');
  static String get planYourFirstMeal => tr('planYourFirstMeal');
  static String get preferencesSectionTitle => tr('preferencesSectionTitle');
  static String get prep => tr('prep');
  static String get prepNotSet => tr('prepNotSet');
  static String get prepTime => tr('prepTime');
  static String get priority => tr('priority');
  static String get profileEditDisplayNameSubtitle => tr('profileEditDisplayNameSubtitle');
  static String get profileEditDisplayNameTitle => tr('profileEditDisplayNameTitle');
  static String get profileEditTooltip => tr('profileEditTooltip');
  static String get profileLoadFailed => tr('profileLoadFailed');
  static String get profileLoading => tr('profileLoading');
  static String get profileNoEmail => tr('profileNoEmail');
  static String get profileSectionTitle => tr('profileSectionTitle');
  static String get profileSyncFailed => tr('profileSyncFailed');
  static String get profileSyncSubtitle => tr('profileSyncSubtitle');
  static String get profileSyncTitle => tr('profileSyncTitle');
  static String get profileSynced => tr('profileSynced');
  static String get profileUpdateFailed => tr('profileUpdateFailed');
  static String get profileUpdated => tr('profileUpdated');
  static String get quantity => tr('quantity');
  static String get quantityMustBeANumber => tr('quantityMustBeANumber');
  static String get recipe => tr('recipe');
  static String get recipeCreated => tr('recipeCreated');
  static String get recipeDeleted => tr('recipeDeleted');
  static String get recipeDetailsAndIngredients => tr('recipeDetailsAndIngredients');
  static String get recipeInfo => tr('recipeInfo');
  static String get recipeInfoUpdated => tr('recipeInfoUpdated');
  static String get recipeMealCanGenerateShoppingItems => tr('recipeMealCanGenerateShoppingItems');
  static String get recipeName => tr('recipeName');
  static String get recipeNameIsRequired => tr('recipeNameIsRequired');
  static String get recipes => tr('recipes');
  static String get recurrence => tr('recurrence');
  static String get recurringHouseholdWork => tr('recurringHouseholdWork');
  static String get removeDeadline => tr('removeDeadline');
  static String get removeNextDueDate => tr('removeNextDueDate');
  static String get removeVote => tr('removeVote');
  static String get repeatEvery => tr('repeatEvery');
  static String get repeatsAfterACustomNumberOfDays => tr('repeatsAfterACustomNumberOfDays');
  static String get repeatsEveryDay => tr('repeatsEveryDay');
  static String get repeatsEveryMonth => tr('repeatsEveryMonth');
  static String get repeatsEveryWeek => tr('repeatsEveryWeek');
  static String get save => tr('save');
  static String get saveMealsYouCanPlanAndShopFromLater => tr('saveMealsYouCanPlanAndShopFromLater');
  static String get servings => tr('servings');
  static String get servingsNotSet => tr('servingsNotSet');
  static String get setNextDueDate => tr('setNextDueDate');
  static String get settingsTitle => tr('settingsTitle');
  static String get sharedGroup => tr('sharedGroup');
  static String get sharedShoppingList => tr('sharedShoppingList');
  static String get sharedSpace => tr('sharedSpace');
  static String get sharedSpaceForListsAndPlanning => tr('sharedSpaceForListsAndPlanning');
  static String get shopping => tr('shopping');
  static String get shoppingItem => tr('shoppingItem');
  static String get shoppingItemCreated => tr('shoppingItemCreated');
  static String get shoppingItemDeleted => tr('shoppingItemDeleted');
  static String get shoppingItemReopened => tr('shoppingItemReopened');
  static String get shoppingItemUpdated => tr('shoppingItemUpdated');
  static String get shoppingItemsGeneratedOpenShoppingToReviewThem => tr('shoppingItemsGeneratedOpenShoppingToReviewThem');
  static String get signOutFailed => tr('signOutFailed');
  static String get signOutSubtitle => tr('signOutSubtitle');
  static String get signOutTitle => tr('signOutTitle');
  static String get simpleSharedListForAnything => tr('simpleSharedListForAnything');
  static String get snack => tr('snack');
  static String get spaghettiCarbonara => tr('spaghettiCarbonara');
  static String get taskReopened => tr('taskReopened');
  static String get tasks => tr('tasks');
  static String get text1ChopVegetables2CookPasta3MixEverything => tr('text1ChopVegetables2CookPasta3MixEverything');
  static String get themeSettingsFeature => tr('themeSettingsFeature');
  static String get themeSubtitle => tr('themeSubtitle');
  static String get themeTitle => tr('themeTitle');
  static String get thingsToDoTogether => tr('thingsToDoTogether');
  static String get thisListTypeIsNotSupportedByTheCurrentAppVersion => tr('thisListTypeIsNotSupportedByTheCurrentAppVersion');
  static String get thisWillPermanentlyDeleteTheItemFromThisList => tr('thisWillPermanentlyDeleteTheItemFromThisList');
  static String get thisWillPermanentlyDeleteThisRecipeAndItsIngredients => tr('thisWillPermanentlyDeleteThisRecipeAndItsIngredients');
  static String get thisWillRemoveThisItemFromYourShoppingList => tr('thisWillRemoveThisItemFromYourShoppingList');
  static String get thisWillRemoveThisMealFromYourPlan => tr('thisWillRemoveThisMealFromYourPlan');
  static String get title => tr('title');
  static String get titleIsRequired => tr('titleIsRequired');
  static String get toBuy => tr('toBuy');
  static String get toDateCannotBeBeforeFromDate => tr('toDateCannotBeBeforeFromDate');
  static String get today => tr('today');
  static String get tomatoes => tr('tomatoes');
  static String get tomorrow => tr('tomorrow');
  static String get total => tr('total');
  static String get trackOneTimeTasksAndToDos => tr('trackOneTimeTasksAndToDos');
  static String get unexpectedError => tr('unexpectedError');
  static String get unit => tr('unit');
  static String get unknownEmail => tr('unknownEmail');
  static String get unknownUser => tr('unknownUser');
  static String get unnamedIngredient => tr('unnamedIngredient');
  static String get unnamedItem => tr('unnamedItem');
  static String get unsupportedListType => tr('unsupportedListType');
  static String get untitledActivity => tr('untitledActivity');
  static String get untitledChore => tr('untitledChore');
  static String get untitledGroup => tr('untitledGroup');
  static String get untitledIdea => tr('untitledIdea');
  static String get untitledItem => tr('untitledItem');
  static String get untitledList => tr('untitledList');
  static String get untitledMovie => tr('untitledMovie');
  static String get untitledRecipe => tr('untitledRecipe');
  static String get untitledTask => tr('untitledTask');
  static String get upcoming => tr('upcoming');
  static String get updateDateMealTypeRecipeOrNote => tr('updateDateMealTypeRecipeOrNote');
  static String get updateNameDescriptionTimeAndServings => tr('updateNameDescriptionTimeAndServings');
  static String get updateTheSharedSpaceNameAndDescription => tr('updateTheSharedSpaceNameAndDescription');
  static String get updateThisRecipeIngredient => tr('updateThisRecipeIngredient');
  static String get user => tr('user');
  static String get vote => tr('vote');
  static String get voteRemoved => tr('voteRemoved');
  static String get voteSaved => tr('voteSaved');
  static String get votes => tr('votes');
  static String get weCanAddProperDeclineSupportInTheNextStep => tr('weCanAddProperDeclineSupportInTheNextStep');
  static String get weekly => tr('weekly');
  static String get welcomeBack => tr('welcomeBack');
  static String get whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate => tr('whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate');
  static String get yesterday => tr('yesterday');
  static String get you => tr('you');
  static String get yourPersonalSpaceForListsRecipesChoresAndPlanning => tr('yourPersonalSpaceForListsRecipesChoresAndPlanning');

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'aSharedSpaceForListsRecipesChoresAndPlanning': 'A shared space for lists, recipes, chores, and planning.',
      'accept': 'Accept',
      'accountSectionTitle': 'Account',
      'activities': 'Activities',
      'add': 'Add',
      'addAMovieToWatch': 'Add a movie to watch.',
      'addAnItemQuantityAndUnit': 'Add an item, quantity, and unit.',
      'addDeadline': 'Add deadline',
      'addIngredient': 'Add ingredient',
      'addIngredientsFromPlannedRecipeMeals': 'Add ingredients from planned recipe meals.',
      'addItem': 'Add item',
      'addMeal': 'Add meal',
      'addMealPlan': 'Add meal plan',
      'addOneIngredientForThisRecipe': 'Add one ingredient for this recipe.',
      'addRecipe': 'Add recipe',
      'addShoppingItem': 'Add shopping item',
      'addSomethingFunToDo': 'Add something fun to do.',
      'addThePreparationStepsForThisRecipe': 'Add the preparation steps for this recipe.',
      'addYourFirstIdea': 'Add your first idea.',
      'addYourFirstItem': 'Add your first item.',
      'addYourFirstRecipe': 'Add your first recipe.',
      'alreadyHaveAnAccountLogIn': 'Already have an account? Log in',
      'amountNotSet': 'Amount not set',
      'average': 'Average',
      'back': 'Back',
      'bought': 'Bought',
      'breakfast': 'Breakfast',
      'buyMilkWatchMovieCleanKitchen': 'Buy milk / Watch movie / Clean kitchen',
      'cancel': 'Cancel',
      'cancelInvitation': 'Cancel invitation',
      'changeVote': 'Change vote',
      'checkYourEmailToConfirmYourAccount': 'Check your email to confirm your account',
      'chooseHowOftenThisChoreRepeats': 'Choose how often this chore repeats.',
      'chores': 'Chores',
      'clearFilter': 'Clear filter',
      'close': 'Close',
      'comingSoon': 'Soon',
      'comingSoonMessage': '{feature} is coming soon',
      'comment': 'Comment',
      'completeChore': 'Complete chore',
      'completeNow': 'Complete now',
      'completeTask': 'Complete task',
      'continueWithGoogle': 'Continue with Google',
      'cook': 'Cook',
      'cookNotSet': 'Cook not set',
      'cookTime': 'Cook time',
      'cookingInstructions': 'Cooking instructions',
      'create': 'Create',
      'createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM': 'Create a space for your shared life: groups, lists, chores, ideas, meals, and more.',
      'createAccount': 'Create account',
      'createGroup': 'Create group',
      'createList': 'Create list',
      'createYourFirstChore': 'Create your first chore.',
      'createYourFirstGroup': 'Create your first group',
      'createYourFirstSharedListHere': 'Create your first shared list here.',
      'createYourFirstSharedSpace': 'Create your first shared space.',
      'createYourFirstTask': 'Create your first task.',
      'custom': 'Custom',
      'customMeal': 'Custom meal',
      'customMealWillNotGenerateShoppingItems': 'Custom meal • Will not generate shopping items',
      'customRecurrenceMustBeAtLeast2Days': 'Custom recurrence must be at least 2 days.',
      'daily': 'Daily',
      'days': 'days',
      'declineInvitationIsNotAvailableYet': 'Decline invitation is not available yet',
      'delete': 'Delete',
      'deleteChore': 'Delete chore',
      'deleteIngredient': 'Delete ingredient',
      'deleteIngredient2': 'Delete ingredient?',
      'deleteItem': 'Delete item',
      'deleteItem2': 'Delete item?',
      'deleteMealPlan': 'Delete meal plan',
      'deleteMealPlan2': 'Delete meal plan?',
      'deleteRecipe': 'Delete recipe',
      'deleteRecipe2': 'Delete recipe?',
      'deleteShoppingItem': 'Delete shopping item?',
      'deleteTask': 'Delete task',
      'description': 'Description',
      'dinner': 'Dinner',
      'doesNotRepeat': 'Does not repeat',
      'doesNotRepeat2': 'Does not repeat.',
      'done': 'Done',
      'edit': 'Edit',
      'editChore': 'Edit chore',
      'editGroup': 'Edit group',
      'editIngredient': 'Edit ingredient',
      'editInstructions': 'Edit instructions',
      'editItem': 'Edit item',
      'editMealPlan': 'Edit meal plan',
      'editProfileDialogTitle': 'Edit profile',
      'editProfileDisplayNameLabel': 'Display name',
      'editProfileDisplayNameRequired': 'Display name is required.',
      'editProfileDisplayNameSubtitle': 'This is how your name appears to other members.',
      'editProfileDisplayNameTitle': 'Display name',
      'editRecipeInfo': 'Edit recipe info',
      'editShoppingItem': 'Edit shopping item',
      'editTask': 'Edit task',
      'email': 'Email',
      'emailAndPasswordAreRequired': 'Email and password are required',
      'everyNDays': 'Every N days',
      'everythingInThisListIsDone': 'Everything in this list is done.',
      'failedToAcceptInvitation': 'Failed to accept invitation',
      'failedToCompleteItem': 'Failed to complete item',
      'failedToCreateGroup': 'Failed to create group',
      'failedToCreateItem': 'Failed to create item',
      'failedToCreateList': 'Failed to create list',
      'failedToCreateMealPlan': 'Failed to create meal plan',
      'failedToCreateRecipe': 'Failed to create recipe',
      'failedToCreateShoppingItem': 'Failed to create shopping item',
      'failedToDeleteItem': 'Failed to delete item',
      'failedToDeleteMealPlan': 'Failed to delete meal plan',
      'failedToDeleteRecipe': 'Failed to delete recipe',
      'failedToDeleteShoppingItem': 'Failed to delete shopping item',
      'failedToGenerateShoppingItems': 'Failed to generate shopping items',
      'failedToInviteMember': 'Failed to invite member',
      'failedToLoadHomeData': 'Failed to load home data',
      'failedToLoadInvitations': 'Failed to load invitations',
      'failedToLoadItems': 'Failed to load items',
      'failedToLoadLists': 'Failed to load lists',
      'failedToLoadMembers': 'Failed to load members',
      'failedToLoadRecipeDetails': 'Failed to load recipe details',
      'failedToLoadRecipes': 'Failed to load recipes',
      'failedToLoadVotes': 'Failed to load votes',
      'failedToReopenItem': 'Failed to reopen item',
      'failedToSaveVote': 'Failed to save vote',
      'failedToUpdateGroup': 'Failed to update group',
      'failedToUpdateItem': 'Failed to update item',
      'failedToUpdateMealPlan': 'Failed to update meal plan',
      'failedToUpdateShoppingItem': 'Failed to update shopping item',
      'friendExampleCom': 'friend@example.com',
      'fromMealPlan': 'From meal plan',
      'fromMealPlans': 'From meal plans',
      'generate': 'Generate',
      'generateShoppingList': 'Generate shopping list',
      'genericList': 'Generic list',
      'googleLoginFailed': 'Google login failed',
      'groupCreated': 'Group created',
      'groupInfo': 'Group info',
      'groupInvitation': 'Group invitation',
      'groupInvitesWillAppearHere': 'Group invites will appear here.',
      'groupName': 'Group name',
      'groupNameIsRequired': 'Group name is required.',
      'groupUpdated': 'Group updated',
      'high': 'High',
      'highPriority': 'High priority',
      'ideas': 'Ideas',
      'ideasToCollectAndDiscuss': 'Ideas to collect and discuss.',
      'individual': 'Individual',
      'info': 'Info',
      'ingredient': 'Ingredient',
      'ingredientAdded': 'Ingredient added',
      'ingredientNameIsRequired': 'Ingredient name is required.',
      'ingredientUpdated': 'Ingredient updated',
      'ingredients': 'Ingredients',
      'ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde': 'Ingredients from recipe-based meal plans in this date range will be added to shopping.',
      'instructions': 'Instructions',
      'instructionsAdded': 'Instructions added',
      'instructionsUpdated': 'Instructions updated',
      'invitationAccepted': 'Invitation accepted',
      'invite': 'Invite',
      'inviteMember': 'Invite member',
      'inviteSomeoneToShareThisGroup': 'Invite someone to share this group.',
      'itemCompleted': 'Item completed',
      'itemCreated': 'Item created',
      'itemDeleted': 'Item deleted',
      'itemNameIsRequired': 'Item name is required.',
      'itemReopened': 'Item reopened',
      'itemUpdated': 'Item updated',
      'languageDialogTitle': 'Choose language',
      'languageEnglish': 'English',
      'languageSettingsFeature': 'Language settings',
      'languageSpanish': 'Spanish',
      'languageSubtitle': 'English for now',
      'languageSubtitleEnglish': 'English',
      'languageSubtitleSpanish': 'Spanish',
      'languageSubtitleSystem': 'Using device language',
      'languageSystem': 'System default',
      'languageTitle': 'Language',
      'list': 'List',
      'listName': 'List name',
      'listType': 'List type',
      'loadingInvitations': 'Loading invitations...',
      'logIn': 'Log in',
      'logInToManageYourSharedListsPlansAndChores': 'Log in to manage your shared lists, plans, and chores.',
      'low': 'Low',
      'lowPriority': 'Low priority',
      'lunch': 'Lunch',
      'markAsBought': 'Mark as bought',
      'markAsDone': 'Mark as done',
      'markAsNotBought': 'Mark as not bought',
      'markAsOpen': 'Mark as open',
      'markedAsBought': 'Marked as bought',
      'markedAsNotBought': 'Marked as not bought',
      'meAndPartner': 'Me and Partner',
      'mealPlan': 'Meal plan',
      'mealPlanDeleted': 'Meal plan deleted',
      'mealPlanUpdated': 'Meal plan updated',
      'mealPlanned': 'Meal planned',
      'mealPlanning': 'Meal planning',
      'mealType': 'Meal type',
      'mealsAndCookingIdeas': 'Meals and cooking ideas.',
      'medium': 'Medium',
      'mediumPriority': 'Medium priority',
      'member': 'Member',
      'minimum2Days': 'Minimum 2 days.',
      'missingGoogleIdToken': 'Missing Google ID token',
      'monthly': 'Monthly',
      'movies': 'Movies',
      'moviesToWatch': 'Movies to watch',
      'moviesToWatchAndVoteOn': 'Movies to watch and vote on.',
      'myGroups': 'My groups',
      'name': 'Name',
      'needAnAccountSignUp': 'Need an account? Sign up',
      'newGroup': 'New group',
      'newList': 'New list',
      'noActivitiesYet': 'No activities yet',
      'noChoresYet': 'No chores yet',
      'noComment': 'No comment',
      'noDate': 'No date',
      'noDeadline': 'No deadline',
      'noDoneItems': 'No done items',
      'noDueDate': 'No due date',
      'noGroupsYet': 'No groups yet',
      'noIdeasYet': 'No ideas yet',
      'noIngredientsYet': 'No ingredients yet.',
      'noInstructions': 'No instructions',
      'noInstructionsYet': 'No instructions yet.',
      'noItemsYet': 'No items yet',
      'noListsYet': 'No lists yet',
      'noMealPlansYet': 'No meal plans yet',
      'noMealsThisWeek': 'No meals this week',
      'noMembersLoaded': 'No members loaded',
      'noMoviesYet': 'No movies yet',
      'noOpenItems': 'No open items',
      'noPastMeals': 'No past meals',
      'noPendingInvitations': 'No pending invitations',
      'noPeopleYet': 'No people yet',
      'noPriority': 'No priority',
      'noRecipeCustomMeal': 'No recipe / custom meal',
      'noRecipesYet': 'No recipes yet',
      'noShoppingItemsYet': 'No shopping items yet',
      'noTasksYet': 'No tasks yet',
      'noUpcomingMeals': 'No upcoming meals',
      'noVotesYet': 'No votes yet',
      'noVotesYet2': 'No votes yet.',
      'nonRecurringChoresCanStillBeCompletedManually': 'Non-recurring chores can still be completed manually.',
      'none': 'None',
      'note': 'Note',
      'noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop': 'Note: generating the same range more than once may create duplicate shopping items.',
      'nothingHasBeenCompletedYet': 'Nothing has been completed yet.',
      'nothingPlannedForTheNext7Days': 'Nothing planned for the next 7 days.',
      'notificationSettingsFeature': 'Notification settings',
      'notificationsSubtitle': 'Notification preferences later',
      'notificationsTitle': 'Notifications',
      'open': 'Open',
      'openRecipe': 'Open recipe',
      'optional': 'Optional',
      'optional2': 'Optional.',
      'optionalEGFamilyDinnerOrLeftovers': 'Optional, e.g. family dinner or leftovers',
      'optionalYouCanAlsoCreateACustomMealNote': 'Optional. You can also create a custom meal note.',
      'organizeLifeTogether': 'Organize life together',
      'overdue': 'Overdue',
      'password': 'Password',
      'pastMealsWillAppearHere': 'Past meals will appear here.',
      'pcsGMl': 'pcs / g / ml',
      'pendingInvitations': 'Pending invitations',
      'pendingInvite': 'Pending invite',
      'pesaListas': 'Pesa-Listas',
      'pesalistas': 'Pesalistas',
      'planAMealForADateAndOptionallyChooseARecipe': 'Plan a meal for a date and optionally choose a recipe.',
      'planAMealForTodayOrLater': 'Plan a meal for today or later.',
      'planMealsByDay': 'Plan meals by day.',
      'planYourFirstMeal': 'Plan your first meal.',
      'preferencesSectionTitle': 'Preferences',
      'prep': 'Prep',
      'prepNotSet': 'Prep not set',
      'prepTime': 'Prep time',
      'priority': 'Priority',
      'profileEditDisplayNameSubtitle': 'Change how your name appears to other members.',
      'profileEditDisplayNameTitle': 'Edit display name',
      'profileEditTooltip': 'Edit profile',
      'profileLoadFailed': 'Failed to load profile',
      'profileLoading': 'Loading profile...',
      'profileNoEmail': 'No email available',
      'profileSectionTitle': 'Profile',
      'profileSyncFailed': 'Failed to sync profile',
      'profileSyncSubtitle': 'Refresh display name and avatar from your auth account.',
      'profileSyncTitle': 'Sync profile from Google',
      'profileSynced': 'Profile synced',
      'profileUpdateFailed': 'Failed to update profile',
      'profileUpdated': 'Profile updated',
      'quantity': 'Quantity',
      'quantityMustBeANumber': 'Quantity must be a number.',
      'recipe': 'Recipe',
      'recipeCreated': 'Recipe created',
      'recipeDeleted': 'Recipe deleted',
      'recipeDetailsAndIngredients': 'Recipe details and ingredients',
      'recipeInfo': 'Recipe info',
      'recipeInfoUpdated': 'Recipe info updated',
      'recipeMealCanGenerateShoppingItems': 'Recipe meal • Can generate shopping items',
      'recipeName': 'Recipe name',
      'recipeNameIsRequired': 'Recipe name is required.',
      'recipes': 'Recipes',
      'recurrence': 'Recurrence',
      'recurringHouseholdWork': 'Recurring household work.',
      'removeDeadline': 'Remove deadline',
      'removeNextDueDate': 'Remove next due date',
      'removeVote': 'Remove vote',
      'repeatEvery': 'Repeat every',
      'repeatsAfterACustomNumberOfDays': 'Repeats after a custom number of days.',
      'repeatsEveryDay': 'Repeats every day.',
      'repeatsEveryMonth': 'Repeats every month.',
      'repeatsEveryWeek': 'Repeats every week.',
      'save': 'Save',
      'saveMealsYouCanPlanAndShopFromLater': 'Save meals you can plan and shop from later.',
      'servings': 'Servings',
      'servingsNotSet': 'Servings not set',
      'setNextDueDate': 'Set next due date',
      'settingsTitle': 'Settings',
      'sharedGroup': 'Shared group',
      'sharedShoppingList': 'Shared shopping list.',
      'sharedSpace': 'Shared space',
      'sharedSpaceForListsAndPlanning': 'Shared space for lists and planning.',
      'shopping': 'Shopping',
      'shoppingItem': 'Shopping item',
      'shoppingItemCreated': 'Shopping item created',
      'shoppingItemDeleted': 'Shopping item deleted',
      'shoppingItemReopened': 'Shopping item reopened',
      'shoppingItemUpdated': 'Shopping item updated',
      'shoppingItemsGeneratedOpenShoppingToReviewThem': 'Shopping items generated. Open Shopping to review them.',
      'signOutFailed': 'Failed to sign out',
      'signOutSubtitle': 'Return to the login screen.',
      'signOutTitle': 'Sign out',
      'simpleSharedListForAnything': 'Simple shared list for anything.',
      'snack': 'Snack',
      'spaghettiCarbonara': 'Spaghetti carbonara',
      'taskReopened': 'Task reopened',
      'tasks': 'Tasks',
      'text1ChopVegetables2CookPasta3MixEverything': '1. Chop vegetables\n2. Cook pasta\n3. Mix everything',
      'themeSettingsFeature': 'Theme settings',
      'themeSubtitle': 'System default for now',
      'themeTitle': 'Theme',
      'thingsToDoTogether': 'Things to do together.',
      'thisListTypeIsNotSupportedByTheCurrentAppVersion': 'This list type is not supported by the current app version.',
      'thisWillPermanentlyDeleteTheItemFromThisList': 'This will permanently delete the item from this list.',
      'thisWillPermanentlyDeleteThisRecipeAndItsIngredients': 'This will permanently delete this recipe and its ingredients.',
      'thisWillRemoveThisItemFromYourShoppingList': 'This will remove this item from your shopping list.',
      'thisWillRemoveThisMealFromYourPlan': 'This will remove this meal from your plan.',
      'title': 'Title',
      'titleIsRequired': 'Title is required.',
      'toBuy': 'To buy',
      'toDateCannotBeBeforeFromDate': 'To date cannot be before from date.',
      'today': 'Today',
      'tomatoes': 'Tomatoes',
      'tomorrow': 'Tomorrow',
      'total': 'Total',
      'trackOneTimeTasksAndToDos': 'Track one-time tasks and to-dos.',
      'unexpectedError': 'Unexpected error',
      'unit': 'Unit',
      'unknownEmail': 'Unknown email',
      'unknownUser': 'Unknown user',
      'unnamedIngredient': 'Unnamed ingredient',
      'unnamedItem': 'Unnamed item',
      'unsupportedListType': 'Unsupported list type',
      'untitledActivity': 'Untitled activity',
      'untitledChore': 'Untitled chore',
      'untitledGroup': 'Untitled group',
      'untitledIdea': 'Untitled idea',
      'untitledItem': 'Untitled item',
      'untitledList': 'Untitled list',
      'untitledMovie': 'Untitled movie',
      'untitledRecipe': 'Untitled recipe',
      'untitledTask': 'Untitled task',
      'upcoming': 'Upcoming',
      'updateDateMealTypeRecipeOrNote': 'Update date, meal type, recipe, or note.',
      'updateNameDescriptionTimeAndServings': 'Update name, description, time, and servings.',
      'updateTheSharedSpaceNameAndDescription': 'Update the shared space name and description.',
      'updateThisRecipeIngredient': 'Update this recipe ingredient.',
      'user': 'User',
      'vote': 'Vote',
      'voteRemoved': 'Vote removed',
      'voteSaved': 'Vote saved',
      'votes': 'Votes',
      'weCanAddProperDeclineSupportInTheNextStep': 'We can add proper decline support in the next step.',
      'weekly': 'Weekly',
      'welcomeBack': 'Welcome back',
      'whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate': 'When you complete this chore, the app will schedule the next due date.',
      'yesterday': 'Yesterday',
      'you': 'You',
      'yourPersonalSpaceForListsRecipesChoresAndPlanning': 'Your personal space for lists, recipes, chores, and planning.',
    },
    'es': {
      'aSharedSpaceForListsRecipesChoresAndPlanning': 'Un espacio compartido para listas, recetas, tareas y planificación.',
      'accept': 'Aceptar',
      'accountSectionTitle': 'Cuenta',
      'activities': 'Actividades',
      'add': 'Añadir',
      'addAMovieToWatch': 'Añade una película para ver.',
      'addAnItemQuantityAndUnit': 'Añade un artículo, cantidad y unidad.',
      'addDeadline': 'Añadir fecha límite',
      'addIngredient': 'Añadir ingrediente',
      'addIngredientsFromPlannedRecipeMeals': 'Añade ingredientes desde comidas planificadas con receta.',
      'addItem': 'Añadir elemento',
      'addMeal': 'Añadir comida',
      'addMealPlan': 'Añadir plan de comida',
      'addOneIngredientForThisRecipe': 'Añade un ingrediente para esta receta.',
      'addRecipe': 'Añadir receta',
      'addShoppingItem': 'Añadir artículo de compra',
      'addSomethingFunToDo': 'Añade algo divertido para hacer.',
      'addThePreparationStepsForThisRecipe': 'Añade los pasos de preparación de esta receta.',
      'addYourFirstIdea': 'Añade tu primera idea.',
      'addYourFirstItem': 'Añade tu primer artículo.',
      'addYourFirstRecipe': 'Añade tu primera receta.',
      'alreadyHaveAnAccountLogIn': '¿Ya tienes cuenta? Inicia sesión',
      'amountNotSet': 'Cantidad sin definir',
      'average': 'Media',
      'back': 'Atrás',
      'bought': 'Comprado',
      'breakfast': 'Desayuno',
      'buyMilkWatchMovieCleanKitchen': 'Comprar leche / Ver película / Limpiar cocina',
      'cancel': 'Cancelar',
      'cancelInvitation': 'Cancelar invitación',
      'changeVote': 'Cambiar voto',
      'checkYourEmailToConfirmYourAccount': 'Revisa tu email para confirmar tu cuenta',
      'chooseHowOftenThisChoreRepeats': 'Elige cada cuánto se repite esta tarea recurrente.',
      'chores': 'Tareas recurrentes',
      'clearFilter': 'Limpiar filtro',
      'close': 'Cerrar',
      'comingSoon': 'Pronto',
      'comingSoonMessage': '{feature} estará disponible pronto',
      'comment': 'Comentario',
      'completeChore': 'Completar tarea recurrente',
      'completeNow': 'Completar ahora',
      'completeTask': 'Completar tarea',
      'continueWithGoogle': 'Continuar con Google',
      'cook': 'Cocción',
      'cookNotSet': 'Cocción sin definir',
      'cookTime': 'Tiempo de cocción',
      'cookingInstructions': 'Instrucciones de cocina',
      'create': 'Crear',
      'createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM': 'Crea un espacio para vuestra vida compartida: grupos, listas, tareas, ideas, comidas y más.',
      'createAccount': 'Crear cuenta',
      'createGroup': 'Crear grupo',
      'createList': 'Crear lista',
      'createYourFirstChore': 'Crea tu primera tarea recurrente.',
      'createYourFirstGroup': 'Crea tu primer grupo',
      'createYourFirstSharedListHere': 'Crea aquí tu primera lista compartida.',
      'createYourFirstSharedSpace': 'Crea tu primer espacio compartido.',
      'createYourFirstTask': 'Crea tu primera tarea.',
      'custom': 'Personalizada',
      'customMeal': 'Comida personalizada',
      'customMealWillNotGenerateShoppingItems': 'Comida personalizada • No generará compra',
      'customRecurrenceMustBeAtLeast2Days': 'La recurrencia personalizada debe ser de al menos 2 días.',
      'daily': 'Diaria',
      'days': 'días',
      'declineInvitationIsNotAvailableYet': 'Rechazar invitaciones aún no está disponible',
      'delete': 'Eliminar',
      'deleteChore': 'Eliminar tarea recurrente',
      'deleteIngredient': 'Eliminar ingrediente',
      'deleteIngredient2': '¿Eliminar ingrediente?',
      'deleteItem': 'Eliminar elemento',
      'deleteItem2': '¿Eliminar elemento?',
      'deleteMealPlan': 'Eliminar plan de comida',
      'deleteMealPlan2': '¿Eliminar plan de comida?',
      'deleteRecipe': 'Eliminar receta',
      'deleteRecipe2': '¿Eliminar receta?',
      'deleteShoppingItem': '¿Eliminar artículo de compra?',
      'deleteTask': 'Eliminar tarea',
      'description': 'Descripción',
      'dinner': 'Cena',
      'doesNotRepeat': 'No se repite',
      'doesNotRepeat2': 'No se repite.',
      'done': 'Hecho',
      'edit': 'Editar',
      'editChore': 'Editar tarea recurrente',
      'editGroup': 'Editar grupo',
      'editIngredient': 'Editar ingrediente',
      'editInstructions': 'Editar instrucciones',
      'editItem': 'Editar elemento',
      'editMealPlan': 'Editar plan de comida',
      'editProfileDialogTitle': 'Editar perfil',
      'editProfileDisplayNameLabel': 'Nombre visible',
      'editProfileDisplayNameRequired': 'El nombre visible es obligatorio.',
      'editProfileDisplayNameSubtitle': 'Así aparecerá tu nombre para otros miembros.',
      'editProfileDisplayNameTitle': 'Nombre visible',
      'editRecipeInfo': 'Editar información de la receta',
      'editShoppingItem': 'Editar artículo de compra',
      'editTask': 'Editar tarea',
      'email': 'Email',
      'emailAndPasswordAreRequired': 'Email y contraseña son obligatorios',
      'everyNDays': 'Cada N días',
      'everythingInThisListIsDone': 'Todo en esta lista está hecho.',
      'failedToAcceptInvitation': 'No se pudo aceptar la invitación',
      'failedToCompleteItem': 'No se pudo completar el elemento',
      'failedToCreateGroup': 'No se pudo crear el grupo',
      'failedToCreateItem': 'No se pudo crear el elemento',
      'failedToCreateList': 'No se pudo crear la lista',
      'failedToCreateMealPlan': 'No se pudo crear el plan de comida',
      'failedToCreateRecipe': 'No se pudo crear la receta',
      'failedToCreateShoppingItem': 'No se pudo crear el artículo de compra',
      'failedToDeleteItem': 'No se pudo eliminar el elemento',
      'failedToDeleteMealPlan': 'No se pudo eliminar el plan de comida',
      'failedToDeleteRecipe': 'No se pudo eliminar la receta',
      'failedToDeleteShoppingItem': 'No se pudo eliminar el artículo de compra',
      'failedToGenerateShoppingItems': 'No se pudieron generar artículos de compra',
      'failedToInviteMember': 'No se pudo invitar al miembro',
      'failedToLoadHomeData': 'No se pudieron cargar los datos de inicio',
      'failedToLoadInvitations': 'No se pudieron cargar las invitaciones',
      'failedToLoadItems': 'No se pudieron cargar los elementos',
      'failedToLoadLists': 'No se pudieron cargar las listas',
      'failedToLoadMembers': 'No se pudieron cargar los miembros',
      'failedToLoadRecipeDetails': 'No se pudieron cargar los detalles de la receta',
      'failedToLoadRecipes': 'No se pudieron cargar las recetas',
      'failedToLoadVotes': 'No se pudieron cargar los votos',
      'failedToReopenItem': 'No se pudo reabrir el elemento',
      'failedToSaveVote': 'No se pudo guardar el voto',
      'failedToUpdateGroup': 'No se pudo actualizar el grupo',
      'failedToUpdateItem': 'No se pudo actualizar el elemento',
      'failedToUpdateMealPlan': 'No se pudo actualizar el plan de comida',
      'failedToUpdateShoppingItem': 'No se pudo actualizar el artículo de compra',
      'friendExampleCom': 'amigo@ejemplo.com',
      'fromMealPlan': 'Desde plan de comida',
      'fromMealPlans': 'Desde planes de comida',
      'generate': 'Generar',
      'generateShoppingList': 'Generar lista de la compra',
      'genericList': 'Lista genérica',
      'googleLoginFailed': 'Error al iniciar sesión con Google',
      'groupCreated': 'Grupo creado',
      'groupInfo': 'Información del grupo',
      'groupInvitation': 'Invitación de grupo',
      'groupInvitesWillAppearHere': 'Las invitaciones de grupo aparecerán aquí.',
      'groupName': 'Nombre del grupo',
      'groupNameIsRequired': 'El nombre del grupo es obligatorio.',
      'groupUpdated': 'Grupo actualizado',
      'high': 'Alta',
      'highPriority': 'Prioridad alta',
      'ideas': 'Ideas',
      'ideasToCollectAndDiscuss': 'Ideas para guardar y comentar.',
      'individual': 'Individual',
      'info': 'Información',
      'ingredient': 'Ingrediente',
      'ingredientAdded': 'Ingrediente añadido',
      'ingredientNameIsRequired': 'El nombre del ingrediente es obligatorio.',
      'ingredientUpdated': 'Ingrediente actualizado',
      'ingredients': 'Ingredientes',
      'ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde': 'Los ingredientes de planes con receta en este rango se añadirán a la compra.',
      'instructions': 'Instrucciones',
      'instructionsAdded': 'Instrucciones añadidas',
      'instructionsUpdated': 'Instrucciones actualizadas',
      'invitationAccepted': 'Invitación aceptada',
      'invite': 'Invitar',
      'inviteMember': 'Invitar miembro',
      'inviteSomeoneToShareThisGroup': 'Invita a alguien para compartir este grupo.',
      'itemCompleted': 'Elemento completado',
      'itemCreated': 'Elemento creado',
      'itemDeleted': 'Elemento eliminado',
      'itemNameIsRequired': 'El nombre del artículo es obligatorio.',
      'itemReopened': 'Elemento reabierto',
      'itemUpdated': 'Elemento actualizado',
      'languageDialogTitle': 'Elegir idioma',
      'languageEnglish': 'Inglés',
      'languageSettingsFeature': 'Ajustes de idioma',
      'languageSpanish': 'Español',
      'languageSubtitle': 'Español por ahora',
      'languageSubtitleEnglish': 'Inglés',
      'languageSubtitleSpanish': 'Español',
      'languageSubtitleSystem': 'Usando el idioma del dispositivo',
      'languageSystem': 'Predeterminado del sistema',
      'languageTitle': 'Idioma',
      'list': 'Lista',
      'listName': 'Nombre de la lista',
      'listType': 'Tipo de lista',
      'loadingInvitations': 'Cargando invitaciones...',
      'logIn': 'Iniciar sesión',
      'logInToManageYourSharedListsPlansAndChores': 'Inicia sesión para gestionar tus listas, planes y tareas compartidas.',
      'low': 'Baja',
      'lowPriority': 'Prioridad baja',
      'lunch': 'Comida',
      'markAsBought': 'Marcar como comprado',
      'markAsDone': 'Marcar como hecho',
      'markAsNotBought': 'Marcar como no comprado',
      'markAsOpen': 'Marcar como abierto',
      'markedAsBought': 'Marcado como comprado',
      'markedAsNotBought': 'Marcado como no comprado',
      'meAndPartner': 'Yo y mi pareja',
      'mealPlan': 'Plan de comida',
      'mealPlanDeleted': 'Plan de comida eliminado',
      'mealPlanUpdated': 'Plan de comida actualizado',
      'mealPlanned': 'Comida planificada',
      'mealPlanning': 'Planificación de comidas',
      'mealType': 'Tipo de comida',
      'mealsAndCookingIdeas': 'Comidas e ideas de cocina.',
      'medium': 'Media',
      'mediumPriority': 'Prioridad media',
      'member': 'Miembro',
      'minimum2Days': 'Mínimo 2 días.',
      'missingGoogleIdToken': 'Falta el token ID de Google',
      'monthly': 'Mensual',
      'movies': 'Películas',
      'moviesToWatch': 'Películas para ver',
      'moviesToWatchAndVoteOn': 'Películas para ver y votar.',
      'myGroups': 'Mis grupos',
      'name': 'Nombre',
      'needAnAccountSignUp': '¿Necesitas una cuenta? Regístrate',
      'newGroup': 'Nuevo grupo',
      'newList': 'Nueva lista',
      'noActivitiesYet': 'Todavía no hay actividades',
      'noChoresYet': 'Todavía no hay tareas recurrentes',
      'noComment': 'Sin comentario',
      'noDate': 'Sin fecha',
      'noDeadline': 'Sin fecha límite',
      'noDoneItems': 'No hay elementos hechos',
      'noDueDate': 'Sin fecha límite',
      'noGroupsYet': 'Todavía no hay grupos',
      'noIdeasYet': 'Todavía no hay ideas',
      'noIngredientsYet': 'Todavía no hay ingredientes.',
      'noInstructions': 'Sin instrucciones',
      'noInstructionsYet': 'Todavía no hay instrucciones.',
      'noItemsYet': 'Todavía no hay elementos',
      'noListsYet': 'Todavía no hay listas',
      'noMealPlansYet': 'Todavía no hay planes de comida',
      'noMealsThisWeek': 'No hay comidas esta semana',
      'noMembersLoaded': 'No se han cargado miembros',
      'noMoviesYet': 'Todavía no hay películas',
      'noOpenItems': 'No hay elementos abiertos',
      'noPastMeals': 'No hay comidas pasadas',
      'noPendingInvitations': 'No hay invitaciones pendientes',
      'noPeopleYet': 'Todavía no hay personas',
      'noPriority': 'Sin prioridad',
      'noRecipeCustomMeal': 'Sin receta / comida personalizada',
      'noRecipesYet': 'Todavía no hay recetas',
      'noShoppingItemsYet': 'Todavía no hay artículos de compra',
      'noTasksYet': 'Todavía no hay tareas',
      'noUpcomingMeals': 'No hay comidas próximas',
      'noVotesYet': 'Todavía no hay votos',
      'noVotesYet2': 'Todavía no hay votos.',
      'nonRecurringChoresCanStillBeCompletedManually': 'Las tareas no recurrentes también se pueden completar manualmente.',
      'none': 'Ninguna',
      'note': 'Nota',
      'noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop': 'Nota: generar el mismo rango más de una vez puede crear artículos duplicados.',
      'nothingHasBeenCompletedYet': 'Todavía no se ha completado nada.',
      'nothingPlannedForTheNext7Days': 'No hay nada planificado para los próximos 7 días.',
      'notificationSettingsFeature': 'Ajustes de notificaciones',
      'notificationsSubtitle': 'Preferencias de notificaciones más adelante',
      'notificationsTitle': 'Notificaciones',
      'open': 'Abrir',
      'openRecipe': 'Abrir receta',
      'optional': 'Opcional',
      'optional2': 'Opcional.',
      'optionalEGFamilyDinnerOrLeftovers': 'Opcional, por ejemplo cena familiar o sobras',
      'optionalYouCanAlsoCreateACustomMealNote': 'Opcional. También puedes crear una nota de comida personalizada.',
      'organizeLifeTogether': 'Organiza la vida en común',
      'overdue': 'Vencido',
      'password': 'Contraseña',
      'pastMealsWillAppearHere': 'Las comidas pasadas aparecerán aquí.',
      'pcsGMl': 'uds / g / ml',
      'pendingInvitations': 'Invitaciones pendientes',
      'pendingInvite': 'Invitación pendiente',
      'pesaListas': 'Pesa-Listas',
      'pesalistas': 'Pesalistas',
      'planAMealForADateAndOptionallyChooseARecipe': 'Planifica una comida para una fecha y, opcionalmente, elige una receta.',
      'planAMealForTodayOrLater': 'Planifica una comida para hoy o más adelante.',
      'planMealsByDay': 'Planifica comidas por día.',
      'planYourFirstMeal': 'Planifica tu primera comida.',
      'preferencesSectionTitle': 'Preferencias',
      'prep': 'Preparación',
      'prepNotSet': 'Preparación sin definir',
      'prepTime': 'Tiempo de preparación',
      'priority': 'Prioridad',
      'profileEditDisplayNameSubtitle': 'Cambia cómo aparece tu nombre para otros miembros.',
      'profileEditDisplayNameTitle': 'Editar nombre visible',
      'profileEditTooltip': 'Editar perfil',
      'profileLoadFailed': 'No se pudo cargar el perfil',
      'profileLoading': 'Cargando perfil...',
      'profileNoEmail': 'No hay email disponible',
      'profileSectionTitle': 'Perfil',
      'profileSyncFailed': 'No se pudo sincronizar el perfil',
      'profileSyncSubtitle': 'Actualiza tu nombre y avatar desde tu cuenta de autenticación.',
      'profileSyncTitle': 'Sincronizar perfil desde Google',
      'profileSynced': 'Perfil sincronizado',
      'profileUpdateFailed': 'No se pudo actualizar el perfil',
      'profileUpdated': 'Perfil actualizado',
      'quantity': 'Cantidad',
      'quantityMustBeANumber': 'La cantidad debe ser un número.',
      'recipe': 'Receta',
      'recipeCreated': 'Receta creada',
      'recipeDeleted': 'Receta eliminada',
      'recipeDetailsAndIngredients': 'Detalles e ingredientes de la receta',
      'recipeInfo': 'Información de receta',
      'recipeInfoUpdated': 'Información de receta actualizada',
      'recipeMealCanGenerateShoppingItems': 'Comida con receta • Puede generar compra',
      'recipeName': 'Nombre de la receta',
      'recipeNameIsRequired': 'El nombre de la receta es obligatorio.',
      'recipes': 'Recetas',
      'recurrence': 'Recurrencia',
      'recurringHouseholdWork': 'Trabajo recurrente del hogar.',
      'removeDeadline': 'Quitar fecha límite',
      'removeNextDueDate': 'Quitar próxima fecha',
      'removeVote': 'Quitar voto',
      'repeatEvery': 'Repetir cada',
      'repeatsAfterACustomNumberOfDays': 'Se repite después de un número personalizado de días.',
      'repeatsEveryDay': 'Se repite cada día.',
      'repeatsEveryMonth': 'Se repite cada mes.',
      'repeatsEveryWeek': 'Se repite cada semana.',
      'save': 'Guardar',
      'saveMealsYouCanPlanAndShopFromLater': 'Guarda comidas que podrás planificar y convertir en compra más adelante.',
      'servings': 'Raciones',
      'servingsNotSet': 'Raciones sin definir',
      'setNextDueDate': 'Establecer próxima fecha',
      'settingsTitle': 'Ajustes',
      'sharedGroup': 'Grupo compartido',
      'sharedShoppingList': 'Lista de compra compartida.',
      'sharedSpace': 'Espacio compartido',
      'sharedSpaceForListsAndPlanning': 'Espacio compartido para listas y planificación.',
      'shopping': 'Compra',
      'shoppingItem': 'Artículo de compra',
      'shoppingItemCreated': 'Artículo de compra creado',
      'shoppingItemDeleted': 'Artículo de compra eliminado',
      'shoppingItemReopened': 'Artículo de compra reabierto',
      'shoppingItemUpdated': 'Artículo de compra actualizado',
      'shoppingItemsGeneratedOpenShoppingToReviewThem': 'Artículos de compra generados. Abre Compra para revisarlos.',
      'signOutFailed': 'No se pudo cerrar sesión',
      'signOutSubtitle': 'Volver a la pantalla de inicio de sesión.',
      'signOutTitle': 'Cerrar sesión',
      'simpleSharedListForAnything': 'Lista compartida simple para cualquier cosa.',
      'snack': 'Snack',
      'spaghettiCarbonara': 'Espaguetis carbonara',
      'taskReopened': 'Tarea reabierta',
      'tasks': 'Tareas',
      'text1ChopVegetables2CookPasta3MixEverything': '1. Corta las verduras\n2. Cocina la pasta\n3. Mezcla todo',
      'themeSettingsFeature': 'Ajustes de tema',
      'themeSubtitle': 'Predeterminado del sistema por ahora',
      'themeTitle': 'Tema',
      'thingsToDoTogether': 'Cosas para hacer juntos.',
      'thisListTypeIsNotSupportedByTheCurrentAppVersion': 'Este tipo de lista no es compatible con la versión actual de la app.',
      'thisWillPermanentlyDeleteTheItemFromThisList': 'Esto eliminará permanentemente el elemento de esta lista.',
      'thisWillPermanentlyDeleteThisRecipeAndItsIngredients': 'Esto eliminará permanentemente esta receta y sus ingredientes.',
      'thisWillRemoveThisItemFromYourShoppingList': 'Esto quitará este artículo de tu lista de compra.',
      'thisWillRemoveThisMealFromYourPlan': 'Esto quitará esta comida de tu plan.',
      'title': 'Título',
      'titleIsRequired': 'El título es obligatorio.',
      'toBuy': 'Por comprar',
      'toDateCannotBeBeforeFromDate': 'La fecha final no puede ser anterior a la inicial.',
      'today': 'Hoy',
      'tomatoes': 'Tomates',
      'tomorrow': 'Mañana',
      'total': 'Total',
      'trackOneTimeTasksAndToDos': 'Controla tareas puntuales y pendientes.',
      'unexpectedError': 'Error inesperado',
      'unit': 'Unidad',
      'unknownEmail': 'Email desconocido',
      'unknownUser': 'Usuario desconocido',
      'unnamedIngredient': 'Ingrediente sin nombre',
      'unnamedItem': 'Elemento sin nombre',
      'unsupportedListType': 'Tipo de lista no compatible',
      'untitledActivity': 'Actividad sin título',
      'untitledChore': 'Tarea recurrente sin título',
      'untitledGroup': 'Grupo sin título',
      'untitledIdea': 'Idea sin título',
      'untitledItem': 'Elemento sin título',
      'untitledList': 'Lista sin título',
      'untitledMovie': 'Película sin título',
      'untitledRecipe': 'Receta sin título',
      'untitledTask': 'Tarea sin título',
      'upcoming': 'Próximo',
      'updateDateMealTypeRecipeOrNote': 'Actualiza fecha, tipo de comida, receta o nota.',
      'updateNameDescriptionTimeAndServings': 'Actualiza nombre, descripción, tiempo y raciones.',
      'updateTheSharedSpaceNameAndDescription': 'Actualiza el nombre y la descripción del espacio compartido.',
      'updateThisRecipeIngredient': 'Actualiza este ingrediente de la receta.',
      'user': 'Usuario',
      'vote': 'Votar',
      'voteRemoved': 'Voto eliminado',
      'voteSaved': 'Voto guardado',
      'votes': 'Votos',
      'weCanAddProperDeclineSupportInTheNextStep': 'Podemos añadir soporte para rechazar en el siguiente paso.',
      'weekly': 'Semanal',
      'welcomeBack': 'Bienvenido de nuevo',
      'whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate': 'Cuando completes esta tarea, la app programará la próxima fecha.',
      'yesterday': 'Ayer',
      'you': 'Tú',
      'yourPersonalSpaceForListsRecipesChoresAndPlanning': 'Tu espacio personal para listas, recetas, tareas y planificación.',
    },
  };
}
