import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageDialogTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageSubtitleSystem.
  ///
  /// In en, this message translates to:
  /// **'Using device language'**
  String get languageSubtitleSystem;

  /// No description provided for @languageSubtitleEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageSubtitleEnglish;

  /// No description provided for @languageSubtitleSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSubtitleSpanish;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSectionTitle;

  /// No description provided for @profileEditDisplayNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get profileEditDisplayNameTitle;

  /// No description provided for @profileEditDisplayNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change how your name appears to other members.'**
  String get profileEditDisplayNameSubtitle;

  /// No description provided for @profileSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync profile from Google'**
  String get profileSyncTitle;

  /// No description provided for @profileSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh display name and avatar from your auth account.'**
  String get profileSyncSubtitle;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileSynced.
  ///
  /// In en, this message translates to:
  /// **'Profile synced'**
  String get profileSynced;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadFailed;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// No description provided for @profileSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync profile'**
  String get profileSyncFailed;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email available'**
  String get profileNoEmail;

  /// No description provided for @profileEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTooltip;

  /// No description provided for @preferencesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSectionTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English for now'**
  String get languageSubtitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System default for now'**
  String get themeSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences later'**
  String get notificationsSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon'**
  String comingSoonMessage(Object feature);

  /// No description provided for @languageSettingsFeature.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get languageSettingsFeature;

  /// No description provided for @themeSettingsFeature.
  ///
  /// In en, this message translates to:
  /// **'Theme settings'**
  String get themeSettingsFeature;

  /// No description provided for @notificationSettingsFeature.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettingsFeature;

  /// No description provided for @accountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutTitle;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to the login screen.'**
  String get signOutSubtitle;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out'**
  String get signOutFailed;

  /// No description provided for @editProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileDialogTitle;

  /// No description provided for @editProfileDisplayNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editProfileDisplayNameTitle;

  /// No description provided for @editProfileDisplayNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how your name appears to other members.'**
  String get editProfileDisplayNameSubtitle;

  /// No description provided for @editProfileDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editProfileDisplayNameLabel;

  /// No description provided for @editProfileDisplayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required.'**
  String get editProfileDisplayNameRequired;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pesalistas.
  ///
  /// In en, this message translates to:
  /// **'Pesalistas'**
  String get pesalistas;

  /// No description provided for @pesaListas.
  ///
  /// In en, this message translates to:
  /// **'Pesa-Listas'**
  String get pesaListas;

  /// No description provided for @organizeLifeTogether.
  ///
  /// In en, this message translates to:
  /// **'Organize life together'**
  String get organizeLifeTogether;

  /// No description provided for @loadingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Loading invitations...'**
  String get loadingInvitations;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @createYourFirstSharedSpace.
  ///
  /// In en, this message translates to:
  /// **'Create your first shared space.'**
  String get createYourFirstSharedSpace;

  /// No description provided for @sharedSpace.
  ///
  /// In en, this message translates to:
  /// **'Shared space'**
  String get sharedSpace;

  /// No description provided for @aSharedSpaceForListsRecipesChoresAndPlanning.
  ///
  /// In en, this message translates to:
  /// **'A shared space for lists, recipes, chores, and planning.'**
  String get aSharedSpaceForListsRecipesChoresAndPlanning;

  /// No description provided for @yourPersonalSpaceForListsRecipesChoresAndPlanning.
  ///
  /// In en, this message translates to:
  /// **'Your personal space for lists, recipes, chores, and planning.'**
  String get yourPersonalSpaceForListsRecipesChoresAndPlanning;

  /// No description provided for @sharedGroup.
  ///
  /// In en, this message translates to:
  /// **'Shared group'**
  String get sharedGroup;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @noMembersLoaded.
  ///
  /// In en, this message translates to:
  /// **'No members loaded'**
  String get noMembersLoaded;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @noPeopleYet.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get noPeopleYet;

  /// No description provided for @inviteSomeoneToShareThisGroup.
  ///
  /// In en, this message translates to:
  /// **'Invite someone to share this group.'**
  String get inviteSomeoneToShareThisGroup;

  /// No description provided for @inviteMember.
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get inviteMember;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// No description provided for @unknownEmail.
  ///
  /// In en, this message translates to:
  /// **'Unknown email'**
  String get unknownEmail;

  /// No description provided for @cancelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation'**
  String get cancelInvitation;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @sharedSpaceForListsAndPlanning.
  ///
  /// In en, this message translates to:
  /// **'Shared space for lists and planning.'**
  String get sharedSpaceForListsAndPlanning;

  /// No description provided for @pendingInvite.
  ///
  /// In en, this message translates to:
  /// **'Pending invite'**
  String get pendingInvite;

  /// No description provided for @noListsYet.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get noListsYet;

  /// No description provided for @createYourFirstSharedListHere.
  ///
  /// In en, this message translates to:
  /// **'Create your first shared list here.'**
  String get createYourFirstSharedListHere;

  /// No description provided for @noVotesYet.
  ///
  /// In en, this message translates to:
  /// **'No votes yet'**
  String get noVotesYet;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @changeVote.
  ///
  /// In en, this message translates to:
  /// **'Change vote'**
  String get changeVote;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votes;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItem;

  /// No description provided for @noMealPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No meal plans yet'**
  String get noMealPlansYet;

  /// No description provided for @noUpcomingMeals.
  ///
  /// In en, this message translates to:
  /// **'No upcoming meals'**
  String get noUpcomingMeals;

  /// No description provided for @noMealsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No meals this week'**
  String get noMealsThisWeek;

  /// No description provided for @noPastMeals.
  ///
  /// In en, this message translates to:
  /// **'No past meals'**
  String get noPastMeals;

  /// No description provided for @planYourFirstMeal.
  ///
  /// In en, this message translates to:
  /// **'Plan your first meal.'**
  String get planYourFirstMeal;

  /// No description provided for @planAMealForTodayOrLater.
  ///
  /// In en, this message translates to:
  /// **'Plan a meal for today or later.'**
  String get planAMealForTodayOrLater;

  /// No description provided for @nothingPlannedForTheNext7Days.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for the next 7 days.'**
  String get nothingPlannedForTheNext7Days;

  /// No description provided for @pastMealsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Past meals will appear here.'**
  String get pastMealsWillAppearHere;

  /// No description provided for @generateShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Generate shopping list'**
  String get generateShoppingList;

  /// No description provided for @addIngredientsFromPlannedRecipeMeals.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients from planned recipe meals.'**
  String get addIngredientsFromPlannedRecipeMeals;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @customMeal.
  ///
  /// In en, this message translates to:
  /// **'Custom meal'**
  String get customMeal;

  /// No description provided for @recipeMealCanGenerateShoppingItems.
  ///
  /// In en, this message translates to:
  /// **'Recipe meal • Can generate shopping items'**
  String get recipeMealCanGenerateShoppingItems;

  /// No description provided for @customMealWillNotGenerateShoppingItems.
  ///
  /// In en, this message translates to:
  /// **'Custom meal • Will not generate shopping items'**
  String get customMealWillNotGenerateShoppingItems;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Delete meal plan'**
  String get deleteMealPlan;

  /// No description provided for @recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @noShoppingItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No shopping items yet'**
  String get noShoppingItemsYet;

  /// No description provided for @addYourFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add your first item.'**
  String get addYourFirstItem;

  /// No description provided for @toBuy.
  ///
  /// In en, this message translates to:
  /// **'To buy'**
  String get toBuy;

  /// No description provided for @bought.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get bought;

  /// No description provided for @unnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get unnamedItem;

  /// No description provided for @fromMealPlan.
  ///
  /// In en, this message translates to:
  /// **'From meal plan'**
  String get fromMealPlan;

  /// No description provided for @markAsNotBought.
  ///
  /// In en, this message translates to:
  /// **'Mark as not bought'**
  String get markAsNotBought;

  /// No description provided for @markAsBought.
  ///
  /// In en, this message translates to:
  /// **'Mark as bought'**
  String get markAsBought;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @deleteChore.
  ///
  /// In en, this message translates to:
  /// **'Delete chore'**
  String get deleteChore;

  /// No description provided for @doesNotRepeat.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get doesNotRepeat;

  /// No description provided for @completeNow.
  ///
  /// In en, this message translates to:
  /// **'Complete now'**
  String get completeNow;

  /// No description provided for @completeChore.
  ///
  /// In en, this message translates to:
  /// **'Complete chore'**
  String get completeChore;

  /// No description provided for @editChore.
  ///
  /// In en, this message translates to:
  /// **'Edit chore'**
  String get editChore;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @noOpenItems.
  ///
  /// In en, this message translates to:
  /// **'No open items'**
  String get noOpenItems;

  /// No description provided for @noDoneItems.
  ///
  /// In en, this message translates to:
  /// **'No done items'**
  String get noDoneItems;

  /// No description provided for @everythingInThisListIsDone.
  ///
  /// In en, this message translates to:
  /// **'Everything in this list is done.'**
  String get everythingInThisListIsDone;

  /// No description provided for @nothingHasBeenCompletedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been completed yet.'**
  String get nothingHasBeenCompletedYet;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivitiesYet;

  /// No description provided for @addSomethingFunToDo.
  ///
  /// In en, this message translates to:
  /// **'Add something fun to do.'**
  String get addSomethingFunToDo;

  /// No description provided for @untitledActivity.
  ///
  /// In en, this message translates to:
  /// **'Untitled activity'**
  String get untitledActivity;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @addYourFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add your first recipe.'**
  String get addYourFirstRecipe;

  /// No description provided for @untitledRecipe.
  ///
  /// In en, this message translates to:
  /// **'Untitled recipe'**
  String get untitledRecipe;

  /// No description provided for @recipeDetailsAndIngredients.
  ///
  /// In en, this message translates to:
  /// **'Recipe details and ingredients'**
  String get recipeDetailsAndIngredients;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipe;

  /// No description provided for @instructionsAdded.
  ///
  /// In en, this message translates to:
  /// **'Instructions added'**
  String get instructionsAdded;

  /// No description provided for @noInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions'**
  String get noInstructions;

  /// No description provided for @openRecipe.
  ///
  /// In en, this message translates to:
  /// **'Open recipe'**
  String get openRecipe;

  /// No description provided for @unsupportedListType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported list type'**
  String get unsupportedListType;

  /// No description provided for @thisListTypeIsNotSupportedByTheCurrentAppVersion.
  ///
  /// In en, this message translates to:
  /// **'This list type is not supported by the current app version.'**
  String get thisListTypeIsNotSupportedByTheCurrentAppVersion;

  /// No description provided for @untitledTask.
  ///
  /// In en, this message translates to:
  /// **'Untitled task'**
  String get untitledTask;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get noDeadline;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @noPriority.
  ///
  /// In en, this message translates to:
  /// **'No priority'**
  String get noPriority;

  /// No description provided for @markAsOpen.
  ///
  /// In en, this message translates to:
  /// **'Mark as open'**
  String get markAsOpen;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get completeTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @noMoviesYet.
  ///
  /// In en, this message translates to:
  /// **'No movies yet'**
  String get noMoviesYet;

  /// No description provided for @addAMovieToWatch.
  ///
  /// In en, this message translates to:
  /// **'Add a movie to watch.'**
  String get addAMovieToWatch;

  /// No description provided for @untitledMovie.
  ///
  /// In en, this message translates to:
  /// **'Untitled movie'**
  String get untitledMovie;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @createYourFirstTask.
  ///
  /// In en, this message translates to:
  /// **'Create your first task.'**
  String get createYourFirstTask;

  /// No description provided for @untitledItem.
  ///
  /// In en, this message translates to:
  /// **'Untitled item'**
  String get untitledItem;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markAsDone;

  /// No description provided for @noChoresYet.
  ///
  /// In en, this message translates to:
  /// **'No chores yet'**
  String get noChoresYet;

  /// No description provided for @createYourFirstChore.
  ///
  /// In en, this message translates to:
  /// **'Create your first chore.'**
  String get createYourFirstChore;

  /// No description provided for @noIdeasYet.
  ///
  /// In en, this message translates to:
  /// **'No ideas yet'**
  String get noIdeasYet;

  /// No description provided for @addYourFirstIdea.
  ///
  /// In en, this message translates to:
  /// **'Add your first idea.'**
  String get addYourFirstIdea;

  /// No description provided for @untitledIdea.
  ///
  /// In en, this message translates to:
  /// **'Untitled idea'**
  String get untitledIdea;

  /// No description provided for @groupInvitation.
  ///
  /// In en, this message translates to:
  /// **'Group invitation'**
  String get groupInvitation;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get myGroups;

  /// No description provided for @createYourFirstGroup.
  ///
  /// In en, this message translates to:
  /// **'Create your first group'**
  String get createYourFirstGroup;

  /// No description provided for @untitledGroup.
  ///
  /// In en, this message translates to:
  /// **'Untitled group'**
  String get untitledGroup;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @groupInvitesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Group invites will appear here.'**
  String get groupInvitesWillAppearHere;

  /// No description provided for @pendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'Pending invitations'**
  String get pendingInvitations;

  /// No description provided for @addMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Add meal plan'**
  String get addMealPlan;

  /// No description provided for @mealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal plan'**
  String get mealPlan;

  /// No description provided for @planAMealForADateAndOptionallyChooseARecipe.
  ///
  /// In en, this message translates to:
  /// **'Plan a meal for a date and optionally choose a recipe.'**
  String get planAMealForADateAndOptionallyChooseARecipe;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get mealType;

  /// No description provided for @optionalYouCanAlsoCreateACustomMealNote.
  ///
  /// In en, this message translates to:
  /// **'Optional. You can also create a custom meal note.'**
  String get optionalYouCanAlsoCreateACustomMealNote;

  /// No description provided for @noRecipeCustomMeal.
  ///
  /// In en, this message translates to:
  /// **'No recipe / custom meal'**
  String get noRecipeCustomMeal;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @optionalEGFamilyDinnerOrLeftovers.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. family dinner or leftovers'**
  String get optionalEGFamilyDinnerOrLeftovers;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @ingredientNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name is required.'**
  String get ingredientNameIsRequired;

  /// No description provided for @quantityMustBeANumber.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be a number.'**
  String get quantityMustBeANumber;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @ingredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredient;

  /// No description provided for @addOneIngredientForThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add one ingredient for this recipe.'**
  String get addOneIngredientForThisRecipe;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @tomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get tomatoes;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @pcsGMl.
  ///
  /// In en, this message translates to:
  /// **'pcs / g / ml'**
  String get pcsGMl;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @editInstructions.
  ///
  /// In en, this message translates to:
  /// **'Edit instructions'**
  String get editInstructions;

  /// No description provided for @cookingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Cooking instructions'**
  String get cookingInstructions;

  /// No description provided for @addThePreparationStepsForThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add the preparation steps for this recipe.'**
  String get addThePreparationStepsForThisRecipe;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @text1ChopVegetables2CookPasta3MixEverything.
  ///
  /// In en, this message translates to:
  /// **'1. Chop vegetables\n2. Cook pasta\n3. Mix everything'**
  String get text1ChopVegetables2CookPasta3MixEverything;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create list'**
  String get createList;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @moviesToWatch.
  ///
  /// In en, this message translates to:
  /// **'Movies to watch'**
  String get moviesToWatch;

  /// No description provided for @listType.
  ///
  /// In en, this message translates to:
  /// **'List type'**
  String get listType;

  /// No description provided for @prepNotSet.
  ///
  /// In en, this message translates to:
  /// **'Prep not set'**
  String get prepNotSet;

  /// No description provided for @cookNotSet.
  ///
  /// In en, this message translates to:
  /// **'Cook not set'**
  String get cookNotSet;

  /// No description provided for @servingsNotSet.
  ///
  /// In en, this message translates to:
  /// **'Servings not set'**
  String get servingsNotSet;

  /// No description provided for @noInstructionsYet.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet.'**
  String get noInstructionsYet;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet.'**
  String get noIngredientsYet;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unnamedIngredient.
  ///
  /// In en, this message translates to:
  /// **'Unnamed ingredient'**
  String get unnamedIngredient;

  /// No description provided for @amountNotSet.
  ///
  /// In en, this message translates to:
  /// **'Amount not set'**
  String get amountNotSet;

  /// No description provided for @editIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit ingredient'**
  String get editIngredient;

  /// No description provided for @deleteIngredient.
  ///
  /// In en, this message translates to:
  /// **'Delete ingredient'**
  String get deleteIngredient;

  /// No description provided for @itemNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required.'**
  String get itemNameIsRequired;

  /// No description provided for @editShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Edit shopping item'**
  String get editShoppingItem;

  /// No description provided for @addShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Add shopping item'**
  String get addShoppingItem;

  /// No description provided for @shoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Shopping item'**
  String get shoppingItem;

  /// No description provided for @addAnItemQuantityAndUnit.
  ///
  /// In en, this message translates to:
  /// **'Add an item, quantity, and unit.'**
  String get addAnItemQuantityAndUnit;

  /// No description provided for @titleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleIsRequired;

  /// No description provided for @customRecurrenceMustBeAtLeast2Days.
  ///
  /// In en, this message translates to:
  /// **'Custom recurrence must be at least 2 days.'**
  String get customRecurrenceMustBeAtLeast2Days;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @addDeadline.
  ///
  /// In en, this message translates to:
  /// **'Add deadline'**
  String get addDeadline;

  /// No description provided for @removeDeadline.
  ///
  /// In en, this message translates to:
  /// **'Remove deadline'**
  String get removeDeadline;

  /// No description provided for @recurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get recurrence;

  /// No description provided for @chooseHowOftenThisChoreRepeats.
  ///
  /// In en, this message translates to:
  /// **'Choose how often this chore repeats.'**
  String get chooseHowOftenThisChoreRepeats;

  /// No description provided for @repeatEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every'**
  String get repeatEvery;

  /// No description provided for @minimum2Days.
  ///
  /// In en, this message translates to:
  /// **'Minimum 2 days.'**
  String get minimum2Days;

  /// No description provided for @setNextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Set next due date'**
  String get setNextDueDate;

  /// No description provided for @removeNextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Remove next due date'**
  String get removeNextDueDate;

  /// No description provided for @whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate.
  ///
  /// In en, this message translates to:
  /// **'When you complete this chore, the app will schedule the next due date.'**
  String get whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate;

  /// No description provided for @nonRecurringChoresCanStillBeCompletedManually.
  ///
  /// In en, this message translates to:
  /// **'Non-recurring chores can still be completed manually.'**
  String get nonRecurringChoresCanStillBeCompletedManually;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @friendExampleCom.
  ///
  /// In en, this message translates to:
  /// **'friend@example.com'**
  String get friendExampleCom;

  /// No description provided for @toDateCannotBeBeforeFromDate.
  ///
  /// In en, this message translates to:
  /// **'To date cannot be before from date.'**
  String get toDateCannotBeBeforeFromDate;

  /// No description provided for @fromMealPlans.
  ///
  /// In en, this message translates to:
  /// **'From meal plans'**
  String get fromMealPlans;

  /// No description provided for @ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde.
  ///
  /// In en, this message translates to:
  /// **'Ingredients from recipe-based meal plans in this date range will be added to shopping.'**
  String get ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde;

  /// No description provided for @noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop.
  ///
  /// In en, this message translates to:
  /// **'Note: generating the same range more than once may create duplicate shopping items.'**
  String get noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop;

  /// No description provided for @editMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit meal plan'**
  String get editMealPlan;

  /// No description provided for @updateDateMealTypeRecipeOrNote.
  ///
  /// In en, this message translates to:
  /// **'Update date, meal type, recipe, or note.'**
  String get updateDateMealTypeRecipeOrNote;

  /// No description provided for @noVotesYet2.
  ///
  /// In en, this message translates to:
  /// **'No votes yet.'**
  String get noVotesYet2;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @noComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get noComment;

  /// No description provided for @updateThisRecipeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Update this recipe ingredient.'**
  String get updateThisRecipeIngredient;

  /// No description provided for @buyMilkWatchMovieCleanKitchen.
  ///
  /// In en, this message translates to:
  /// **'Buy milk / Watch movie / Clean kitchen'**
  String get buyMilkWatchMovieCleanKitchen;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @meAndPartner.
  ///
  /// In en, this message translates to:
  /// **'Me and Partner'**
  String get meAndPartner;

  /// No description provided for @recipeNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Recipe name is required.'**
  String get recipeNameIsRequired;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get addRecipe;

  /// No description provided for @saveMealsYouCanPlanAndShopFromLater.
  ///
  /// In en, this message translates to:
  /// **'Save meals you can plan and shop from later.'**
  String get saveMealsYouCanPlanAndShopFromLater;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get recipeName;

  /// No description provided for @spaghettiCarbonara.
  ///
  /// In en, this message translates to:
  /// **'Spaghetti carbonara'**
  String get spaghettiCarbonara;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @removeVote.
  ///
  /// In en, this message translates to:
  /// **'Remove vote'**
  String get removeVote;

  /// No description provided for @groupNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Group name is required.'**
  String get groupNameIsRequired;

  /// No description provided for @groupInfo.
  ///
  /// In en, this message translates to:
  /// **'Group info'**
  String get groupInfo;

  /// No description provided for @updateTheSharedSpaceNameAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the shared space name and description.'**
  String get updateTheSharedSpaceNameAndDescription;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep time'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook time'**
  String get cookTime;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @editRecipeInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe info'**
  String get editRecipeInfo;

  /// No description provided for @recipeInfo.
  ///
  /// In en, this message translates to:
  /// **'Recipe info'**
  String get recipeInfo;

  /// No description provided for @updateNameDescriptionTimeAndServings.
  ///
  /// In en, this message translates to:
  /// **'Update name, description, time, and servings.'**
  String get updateNameDescriptionTimeAndServings;

  /// No description provided for @prep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get prep;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @missingGoogleIdToken.
  ///
  /// In en, this message translates to:
  /// **'Missing Google ID token'**
  String get missingGoogleIdToken;

  /// No description provided for @failedToLoadMembers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load members'**
  String get failedToLoadMembers;

  /// No description provided for @failedToLoadInvitations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load invitations'**
  String get failedToLoadInvitations;

  /// No description provided for @failedToLoadLists.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lists'**
  String get failedToLoadLists;

  /// No description provided for @groupUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group updated'**
  String get groupUpdated;

  /// No description provided for @failedToUpdateGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to update group'**
  String get failedToUpdateGroup;

  /// No description provided for @failedToInviteMember.
  ///
  /// In en, this message translates to:
  /// **'Failed to invite member'**
  String get failedToInviteMember;

  /// No description provided for @failedToCreateList.
  ///
  /// In en, this message translates to:
  /// **'Failed to create list'**
  String get failedToCreateList;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get newList;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get googleLoginFailed;

  /// No description provided for @emailAndPasswordAreRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required'**
  String get emailAndPasswordAreRequired;

  /// No description provided for @checkYourEmailToConfirmYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account'**
  String get checkYourEmailToConfirmYourAccount;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get unexpectedError;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @logInToManageYourSharedListsPlansAndChores.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your shared lists, plans, and chores.'**
  String get logInToManageYourSharedListsPlansAndChores;

  /// No description provided for @createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM.
  ///
  /// In en, this message translates to:
  /// **'Create a space for your shared life: groups, lists, chores, ideas, meals, and more.'**
  String get createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @needAnAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get needAnAccountSignUp;

  /// No description provided for @alreadyHaveAnAccountLogIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAnAccountLogIn;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @failedToLoadHomeData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load home data'**
  String get failedToLoadHomeData;

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted'**
  String get invitationAccepted;

  /// No description provided for @failedToAcceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept invitation'**
  String get failedToAcceptInvitation;

  /// No description provided for @declineInvitationIsNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Decline invitation is not available yet'**
  String get declineInvitationIsNotAvailableYet;

  /// No description provided for @weCanAddProperDeclineSupportInTheNextStep.
  ///
  /// In en, this message translates to:
  /// **'We can add proper decline support in the next step.'**
  String get weCanAddProperDeclineSupportInTheNextStep;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group created'**
  String get groupCreated;

  /// No description provided for @failedToCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group'**
  String get failedToCreateGroup;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @failedToLoadItems.
  ///
  /// In en, this message translates to:
  /// **'Failed to load items'**
  String get failedToLoadItems;

  /// No description provided for @shoppingItemsGeneratedOpenShoppingToReviewThem.
  ///
  /// In en, this message translates to:
  /// **'Shopping items generated. Open Shopping to review them.'**
  String get shoppingItemsGeneratedOpenShoppingToReviewThem;

  /// No description provided for @failedToGenerateShoppingItems.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate shopping items'**
  String get failedToGenerateShoppingItems;

  /// No description provided for @itemCreated.
  ///
  /// In en, this message translates to:
  /// **'Item created'**
  String get itemCreated;

  /// No description provided for @failedToCreateItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to create item'**
  String get failedToCreateItem;

  /// No description provided for @shoppingItemCreated.
  ///
  /// In en, this message translates to:
  /// **'Shopping item created'**
  String get shoppingItemCreated;

  /// No description provided for @failedToCreateShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to create shopping item'**
  String get failedToCreateShoppingItem;

  /// No description provided for @failedToLoadRecipes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipes'**
  String get failedToLoadRecipes;

  /// No description provided for @mealPlanned.
  ///
  /// In en, this message translates to:
  /// **'Meal planned'**
  String get mealPlanned;

  /// No description provided for @failedToCreateMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to create meal plan'**
  String get failedToCreateMealPlan;

  /// No description provided for @recipeCreated.
  ///
  /// In en, this message translates to:
  /// **'Recipe created'**
  String get recipeCreated;

  /// No description provided for @failedToCreateRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to create recipe'**
  String get failedToCreateRecipe;

  /// No description provided for @itemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get itemUpdated;

  /// No description provided for @failedToUpdateItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get failedToUpdateItem;

  /// No description provided for @shoppingItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shopping item updated'**
  String get shoppingItemUpdated;

  /// No description provided for @failedToUpdateShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to update shopping item'**
  String get failedToUpdateShoppingItem;

  /// No description provided for @mealPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal plan updated'**
  String get mealPlanUpdated;

  /// No description provided for @failedToUpdateMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to update meal plan'**
  String get failedToUpdateMealPlan;

  /// No description provided for @itemCompleted.
  ///
  /// In en, this message translates to:
  /// **'Item completed'**
  String get itemCompleted;

  /// No description provided for @failedToCompleteItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete item'**
  String get failedToCompleteItem;

  /// No description provided for @shoppingItemReopened.
  ///
  /// In en, this message translates to:
  /// **'Shopping item reopened'**
  String get shoppingItemReopened;

  /// No description provided for @itemReopened.
  ///
  /// In en, this message translates to:
  /// **'Item reopened'**
  String get itemReopened;

  /// No description provided for @taskReopened.
  ///
  /// In en, this message translates to:
  /// **'Task reopened'**
  String get taskReopened;

  /// No description provided for @failedToReopenItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to reopen item'**
  String get failedToReopenItem;

  /// No description provided for @markedAsBought.
  ///
  /// In en, this message translates to:
  /// **'Marked as bought'**
  String get markedAsBought;

  /// No description provided for @markedAsNotBought.
  ///
  /// In en, this message translates to:
  /// **'Marked as not bought'**
  String get markedAsNotBought;

  /// No description provided for @deleteItem2.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteItem2;

  /// No description provided for @thisWillPermanentlyDeleteTheItemFromThisList.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the item from this list.'**
  String get thisWillPermanentlyDeleteTheItemFromThisList;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @failedToDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem;

  /// No description provided for @deleteShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Delete shopping item?'**
  String get deleteShoppingItem;

  /// No description provided for @thisWillRemoveThisItemFromYourShoppingList.
  ///
  /// In en, this message translates to:
  /// **'This will remove this item from your shopping list.'**
  String get thisWillRemoveThisItemFromYourShoppingList;

  /// No description provided for @shoppingItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shopping item deleted'**
  String get shoppingItemDeleted;

  /// No description provided for @failedToDeleteShoppingItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete shopping item'**
  String get failedToDeleteShoppingItem;

  /// No description provided for @deleteMealPlan2.
  ///
  /// In en, this message translates to:
  /// **'Delete meal plan?'**
  String get deleteMealPlan2;

  /// No description provided for @thisWillRemoveThisMealFromYourPlan.
  ///
  /// In en, this message translates to:
  /// **'This will remove this meal from your plan.'**
  String get thisWillRemoveThisMealFromYourPlan;

  /// No description provided for @mealPlanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal plan deleted'**
  String get mealPlanDeleted;

  /// No description provided for @failedToDeleteMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal plan'**
  String get failedToDeleteMealPlan;

  /// No description provided for @deleteRecipe2.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe?'**
  String get deleteRecipe2;

  /// No description provided for @thisWillPermanentlyDeleteThisRecipeAndItsIngredients.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this recipe and its ingredients.'**
  String get thisWillPermanentlyDeleteThisRecipeAndItsIngredients;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get recipeDeleted;

  /// No description provided for @failedToDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete recipe'**
  String get failedToDeleteRecipe;

  /// No description provided for @voteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Vote removed'**
  String get voteRemoved;

  /// No description provided for @voteSaved.
  ///
  /// In en, this message translates to:
  /// **'Vote saved'**
  String get voteSaved;

  /// No description provided for @failedToSaveVote.
  ///
  /// In en, this message translates to:
  /// **'Failed to save vote'**
  String get failedToSaveVote;

  /// No description provided for @failedToLoadVotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load votes'**
  String get failedToLoadVotes;

  /// No description provided for @recipeInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe info updated'**
  String get recipeInfoUpdated;

  /// No description provided for @instructionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Instructions updated'**
  String get instructionsUpdated;

  /// No description provided for @ingredientAdded.
  ///
  /// In en, this message translates to:
  /// **'Ingredient added'**
  String get ingredientAdded;

  /// No description provided for @ingredientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Ingredient updated'**
  String get ingredientUpdated;

  /// No description provided for @deleteIngredient2.
  ///
  /// In en, this message translates to:
  /// **'Delete ingredient?'**
  String get deleteIngredient2;

  /// No description provided for @failedToLoadRecipeDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipe details'**
  String get failedToLoadRecipeDetails;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// No description provided for @untitledChore.
  ///
  /// In en, this message translates to:
  /// **'Untitled chore'**
  String get untitledChore;

  /// No description provided for @untitledList.
  ///
  /// In en, this message translates to:
  /// **'Untitled list'**
  String get untitledList;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @optional2.
  ///
  /// In en, this message translates to:
  /// **'Optional.'**
  String get optional2;

  /// No description provided for @genericList.
  ///
  /// In en, this message translates to:
  /// **'Generic list'**
  String get genericList;

  /// No description provided for @simpleSharedListForAnything.
  ///
  /// In en, this message translates to:
  /// **'Simple shared list for anything.'**
  String get simpleSharedListForAnything;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @trackOneTimeTasksAndToDos.
  ///
  /// In en, this message translates to:
  /// **'Track one-time tasks and to-dos.'**
  String get trackOneTimeTasksAndToDos;

  /// No description provided for @chores.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get chores;

  /// No description provided for @recurringHouseholdWork.
  ///
  /// In en, this message translates to:
  /// **'Recurring household work.'**
  String get recurringHouseholdWork;

  /// No description provided for @movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// No description provided for @moviesToWatchAndVoteOn.
  ///
  /// In en, this message translates to:
  /// **'Movies to watch and vote on.'**
  String get moviesToWatchAndVoteOn;

  /// No description provided for @ideas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get ideas;

  /// No description provided for @ideasToCollectAndDiscuss.
  ///
  /// In en, this message translates to:
  /// **'Ideas to collect and discuss.'**
  String get ideasToCollectAndDiscuss;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @thingsToDoTogether.
  ///
  /// In en, this message translates to:
  /// **'Things to do together.'**
  String get thingsToDoTogether;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @mealsAndCookingIdeas.
  ///
  /// In en, this message translates to:
  /// **'Meals and cooking ideas.'**
  String get mealsAndCookingIdeas;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @sharedShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shared shopping list.'**
  String get sharedShoppingList;

  /// No description provided for @mealPlanning.
  ///
  /// In en, this message translates to:
  /// **'Meal planning'**
  String get mealPlanning;

  /// No description provided for @planMealsByDay.
  ///
  /// In en, this message translates to:
  /// **'Plan meals by day.'**
  String get planMealsByDay;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @lowPriority.
  ///
  /// In en, this message translates to:
  /// **'Low priority'**
  String get lowPriority;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @mediumPriority.
  ///
  /// In en, this message translates to:
  /// **'Medium priority'**
  String get mediumPriority;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @highPriority.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get highPriority;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @repeatsEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Repeats every day.'**
  String get repeatsEveryDay;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @repeatsEveryWeek.
  ///
  /// In en, this message translates to:
  /// **'Repeats every week.'**
  String get repeatsEveryWeek;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @repeatsEveryMonth.
  ///
  /// In en, this message translates to:
  /// **'Repeats every month.'**
  String get repeatsEveryMonth;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get everyNDays;

  /// No description provided for @repeatsAfterACustomNumberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Repeats after a custom number of days.'**
  String get repeatsAfterACustomNumberOfDays;

  /// No description provided for @doesNotRepeat2.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat.'**
  String get doesNotRepeat2;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @themeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get themeDialogTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSubtitleSystem.
  ///
  /// In en, this message translates to:
  /// **'Using device theme'**
  String get themeSubtitleSystem;

  /// No description provided for @themeSubtitleLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeSubtitleLight;

  /// No description provided for @themeSubtitleDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeSubtitleDark;

  /// No description provided for @declineInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline invitation?'**
  String get declineInvitationTitle;

  /// No description provided for @declineInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'This invitation will be removed from your pending invitations.'**
  String get declineInvitationMessage;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @failedToDeclineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline invitation'**
  String get failedToDeclineInvitation;

  /// No description provided for @cancelInvitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel invitation?'**
  String get cancelInvitationTitle;

  /// No description provided for @cancelInvitationMessage.
  ///
  /// In en, this message translates to:
  /// **'This pending invitation will be cancelled.'**
  String get cancelInvitationMessage;

  /// No description provided for @invitationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Invitation cancelled'**
  String get invitationCancelled;

  /// No description provided for @failedToCancelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel invitation'**
  String get failedToCancelInvitation;

  /// No description provided for @editList.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editList;

  /// No description provided for @editListInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit list info'**
  String get editListInfo;

  /// No description provided for @updateListNameAndDescription.
  ///
  /// In en, this message translates to:
  /// **'Update the list name and description.'**
  String get updateListNameAndDescription;

  /// No description provided for @listNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'List name is required.'**
  String get listNameIsRequired;

  /// No description provided for @listUpdated.
  ///
  /// In en, this message translates to:
  /// **'List updated'**
  String get listUpdated;

  /// No description provided for @failedToUpdateList.
  ///
  /// In en, this message translates to:
  /// **'Failed to update list'**
  String get failedToUpdateList;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @archiveList.
  ///
  /// In en, this message translates to:
  /// **'Archive list'**
  String get archiveList;

  /// No description provided for @archiveListTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive list?'**
  String get archiveListTitle;

  /// No description provided for @archiveListMessage.
  ///
  /// In en, this message translates to:
  /// **'This list will be hidden from the group, but its data will remain in the database.'**
  String get archiveListMessage;

  /// No description provided for @listArchived.
  ///
  /// In en, this message translates to:
  /// **'List archived'**
  String get listArchived;

  /// No description provided for @failedToArchiveList.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive list'**
  String get failedToArchiveList;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteList;

  /// No description provided for @deleteListTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete list?'**
  String get deleteListTitle;

  /// No description provided for @deleteListMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this list. This cannot be undone.'**
  String get deleteListMessage;

  /// No description provided for @listDeleted.
  ///
  /// In en, this message translates to:
  /// **'List deleted'**
  String get listDeleted;

  /// No description provided for @failedToDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list'**
  String get failedToDeleteList;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// No description provided for @listTypeCannotBeChangedYet.
  ///
  /// In en, this message translates to:
  /// **'List type cannot be changed yet'**
  String get listTypeCannotBeChangedYet;

  /// No description provided for @addListTypeItem.
  ///
  /// In en, this message translates to:
  /// **'Add {listType} item'**
  String addListTypeItem(Object listType);

  /// No description provided for @archivedLists.
  ///
  /// In en, this message translates to:
  /// **'Archived lists'**
  String get archivedLists;

  /// No description provided for @archivedListsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore archived lists or permanently delete them.'**
  String get archivedListsSubtitle;

  /// No description provided for @noArchivedListsYet.
  ///
  /// In en, this message translates to:
  /// **'No archived lists yet'**
  String get noArchivedListsYet;

  /// No description provided for @noArchivedListsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Archived lists will appear here.'**
  String get noArchivedListsSubtitle;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreList.
  ///
  /// In en, this message translates to:
  /// **'Restore list'**
  String get restoreList;

  /// No description provided for @restoreListTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore list?'**
  String get restoreListTitle;

  /// No description provided for @restoreListMessage.
  ///
  /// In en, this message translates to:
  /// **'This list will appear again in the group.'**
  String get restoreListMessage;

  /// No description provided for @listRestored.
  ///
  /// In en, this message translates to:
  /// **'List restored'**
  String get listRestored;

  /// No description provided for @failedToLoadArchivedLists.
  ///
  /// In en, this message translates to:
  /// **'Failed to load archived lists'**
  String get failedToLoadArchivedLists;

  /// No description provided for @failedToRestoreList.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore list'**
  String get failedToRestoreList;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove member?'**
  String get removeMemberTitle;

  /// No description provided for @removeMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove {memberName} from this group?'**
  String removeMemberMessage(Object memberName);

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get memberRemoved;

  /// No description provided for @failedToRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove member'**
  String get failedToRemoveMember;

  /// No description provided for @cannotRemoveYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove yourself'**
  String get cannotRemoveYourself;

  /// No description provided for @ownersCannotBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Owners cannot be removed'**
  String get ownersCannotBeRemoved;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(Object role);

  /// No description provided for @manageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get manageMembers;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get makeAdmin;

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make member'**
  String get makeMember;

  /// No description provided for @changeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change role?'**
  String get changeRoleTitle;

  /// No description provided for @changeRoleToAdminMessage.
  ///
  /// In en, this message translates to:
  /// **'Make {memberName} an admin of this group?'**
  String changeRoleToAdminMessage(Object memberName);

  /// No description provided for @changeRoleToMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'Change {memberName} back to member?'**
  String changeRoleToMemberMessage(Object memberName);

  /// No description provided for @memberRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member role updated'**
  String get memberRoleUpdated;

  /// No description provided for @failedToUpdateMemberRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to update member role'**
  String get failedToUpdateMemberRole;

  /// No description provided for @onlyOwnersCanChangeRoles.
  ///
  /// In en, this message translates to:
  /// **'Only owners can change member roles'**
  String get onlyOwnersCanChangeRoles;

  /// No description provided for @ownerRoleCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Owner role cannot be changed'**
  String get ownerRoleCannotBeChanged;

  /// No description provided for @deadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {date}'**
  String deadlineDate(Object date);

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next due: {date}'**
  String nextDueDate(Object date);

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String fromDateLabel(Object date);

  /// No description provided for @toDateLabel.
  ///
  /// In en, this message translates to:
  /// **'To {date}'**
  String toDateLabel(Object date);

  /// No description provided for @invitationSentTo.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent to {email}'**
  String invitationSentTo(Object email);

  /// No description provided for @listCreatedWithName.
  ///
  /// In en, this message translates to:
  /// **'List \"{name}\" created'**
  String listCreatedWithName(Object name);

  /// No description provided for @thisIngredient.
  ///
  /// In en, this message translates to:
  /// **'this ingredient'**
  String get thisIngredient;

  /// No description provided for @deleteIngredientMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{name}\" from the recipe.'**
  String deleteIngredientMessage(Object name);

  /// No description provided for @ingredientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Ingredient deleted'**
  String get ingredientDeleted;

  /// No description provided for @invitedAsRole.
  ///
  /// In en, this message translates to:
  /// **'Invited as {role}'**
  String invitedAsRole(Object role);

  /// No description provided for @allCount.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String allCount(Object count);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'Open {count}'**
  String openCount(Object count);

  /// No description provided for @doneCount.
  ///
  /// In en, this message translates to:
  /// **'Done {count}'**
  String doneCount(Object count);

  /// No description provided for @upcomingCount.
  ///
  /// In en, this message translates to:
  /// **'Upcoming {count}'**
  String upcomingCount(Object count);

  /// No description provided for @thisWeekCount.
  ///
  /// In en, this message translates to:
  /// **'This week {count}'**
  String thisWeekCount(Object count);

  /// No description provided for @pastCount.
  ///
  /// In en, this message translates to:
  /// **'Past {count}'**
  String pastCount(Object count);

  /// No description provided for @thisWeekSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} this week'**
  String thisWeekSummary(Object count);

  /// No description provided for @upcomingSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming'**
  String upcomingSummary(Object count);

  /// No description provided for @withRecipesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} with recipes'**
  String withRecipesSummary(Object count);

  /// No description provided for @totalCountSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCountSummary(Object count);

  /// No description provided for @pastSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} past'**
  String pastSummary(Object count);

  /// No description provided for @toBuySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} to buy'**
  String toBuySummary(Object count);

  /// No description provided for @boughtSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} bought'**
  String boughtSummary(Object count);

  /// No description provided for @generatedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} generated'**
  String generatedSummary(Object count);

  /// No description provided for @sectionCount.
  ///
  /// In en, this message translates to:
  /// **'{title} ({count})'**
  String sectionCount(Object title, Object count);

  /// No description provided for @recipeSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {name}'**
  String recipeSourceLabel(Object name);

  /// No description provided for @minutesTotal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min total'**
  String minutesTotal(Object minutes);

  /// No description provided for @prepMinutes.
  ///
  /// In en, this message translates to:
  /// **'Prep {minutes} min'**
  String prepMinutes(Object minutes);

  /// No description provided for @cookMinutes.
  ///
  /// In en, this message translates to:
  /// **'Cook {minutes} min'**
  String cookMinutes(Object minutes);

  /// No description provided for @servingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String servingsCount(Object count);

  /// No description provided for @voteCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 vote'**
  String get voteCountOne;

  /// No description provided for @voteCountMany.
  ///
  /// In en, this message translates to:
  /// **'{count} votes'**
  String voteCountMany(Object count);

  /// No description provided for @totalPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total {points}'**
  String totalPointsLabel(Object points);

  /// No description provided for @yourVoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Your vote {points}'**
  String yourVoteLabel(Object points);

  /// No description provided for @averageShort.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get averageShort;

  /// No description provided for @ingredientCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 ingredient'**
  String get ingredientCountOne;

  /// No description provided for @ingredientCountMany.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String ingredientCountMany(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
