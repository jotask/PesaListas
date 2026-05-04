// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get languageDialogTitle => 'Elegir idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageSubtitleSystem => 'Usando el idioma del dispositivo';

  @override
  String get languageSubtitleEnglish => 'Inglés';

  @override
  String get languageSubtitleSpanish => 'Español';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get profileSectionTitle => 'Perfil';

  @override
  String get profileEditDisplayNameTitle => 'Editar nombre visible';

  @override
  String get profileEditDisplayNameSubtitle =>
      'Cambia cómo aparece tu nombre para otros miembros.';

  @override
  String get profileSyncTitle => 'Sincronizar perfil desde Google';

  @override
  String get profileSyncSubtitle =>
      'Actualiza tu nombre y avatar desde tu cuenta de autenticación.';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get profileSynced => 'Perfil sincronizado';

  @override
  String get profileLoadFailed => 'No se pudo cargar el perfil';

  @override
  String get profileUpdateFailed => 'No se pudo actualizar el perfil';

  @override
  String get profileSyncFailed => 'No se pudo sincronizar el perfil';

  @override
  String get profileLoading => 'Cargando perfil...';

  @override
  String get profileNoEmail => 'No hay email disponible';

  @override
  String get profileEditTooltip => 'Editar perfil';

  @override
  String get preferencesSectionTitle => 'Preferencias';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Español por ahora';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSubtitle => 'Predeterminado del sistema por ahora';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle =>
      'Preferencias de notificaciones más adelante';

  @override
  String get comingSoon => 'Pronto';

  @override
  String comingSoonMessage(Object feature) {
    return '$feature estará disponible pronto';
  }

  @override
  String get languageSettingsFeature => 'Ajustes de idioma';

  @override
  String get themeSettingsFeature => 'Ajustes de tema';

  @override
  String get notificationSettingsFeature => 'Ajustes de notificaciones';

  @override
  String get accountSectionTitle => 'Cuenta';

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutSubtitle => 'Volver a la pantalla de inicio de sesión.';

  @override
  String get signOutFailed => 'No se pudo cerrar sesión';

  @override
  String get editProfileDialogTitle => 'Editar perfil';

  @override
  String get editProfileDisplayNameTitle => 'Nombre visible';

  @override
  String get editProfileDisplayNameSubtitle =>
      'Así aparecerá tu nombre para otros miembros.';

  @override
  String get editProfileDisplayNameLabel => 'Nombre visible';

  @override
  String get editProfileDisplayNameRequired =>
      'El nombre visible es obligatorio.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get pesalistas => 'Pesalistas';

  @override
  String get pesaListas => 'Pesa-Listas';

  @override
  String get organizeLifeTogether => 'Organiza la vida en común';

  @override
  String get loadingInvitations => 'Cargando invitaciones...';

  @override
  String get noGroupsYet => 'Todavía no hay grupos';

  @override
  String get createYourFirstSharedSpace => 'Crea tu primer espacio compartido.';

  @override
  String get sharedSpace => 'Espacio compartido';

  @override
  String get aSharedSpaceForListsRecipesChoresAndPlanning =>
      'Un espacio compartido para listas, recetas, tareas y planificación.';

  @override
  String get yourPersonalSpaceForListsRecipesChoresAndPlanning =>
      'Tu espacio personal para listas, recetas, tareas y planificación.';

  @override
  String get sharedGroup => 'Grupo compartido';

  @override
  String get individual => 'Individual';

  @override
  String get noMembersLoaded => 'No se han cargado miembros';

  @override
  String get open => 'Abrir';

  @override
  String get member => 'Miembro';

  @override
  String get noPeopleYet => 'Todavía no hay personas';

  @override
  String get inviteSomeoneToShareThisGroup =>
      'Invita a alguien para compartir este grupo.';

  @override
  String get inviteMember => 'Invitar miembro';

  @override
  String get unknownUser => 'Usuario desconocido';

  @override
  String get unknownEmail => 'Email desconocido';

  @override
  String get cancelInvitation => 'Cancelar invitación';

  @override
  String get back => 'Atrás';

  @override
  String get editGroup => 'Editar grupo';

  @override
  String get invite => 'Invitar';

  @override
  String get sharedSpaceForListsAndPlanning =>
      'Espacio compartido para listas y planificación.';

  @override
  String get pendingInvite => 'Invitación pendiente';

  @override
  String get noListsYet => 'Todavía no hay listas';

  @override
  String get createYourFirstSharedListHere =>
      'Crea aquí tu primera lista compartida.';

  @override
  String get noVotesYet => 'Todavía no hay votos';

  @override
  String get vote => 'Votar';

  @override
  String get changeVote => 'Cambiar voto';

  @override
  String get votes => 'Votos';

  @override
  String get editItem => 'Editar elemento';

  @override
  String get deleteItem => 'Eliminar elemento';

  @override
  String get noMealPlansYet => 'Todavía no hay planes de comida';

  @override
  String get noUpcomingMeals => 'No hay comidas próximas';

  @override
  String get noMealsThisWeek => 'No hay comidas esta semana';

  @override
  String get noPastMeals => 'No hay comidas pasadas';

  @override
  String get planYourFirstMeal => 'Planifica tu primera comida.';

  @override
  String get planAMealForTodayOrLater =>
      'Planifica una comida para hoy o más adelante.';

  @override
  String get nothingPlannedForTheNext7Days =>
      'No hay nada planificado para los próximos 7 días.';

  @override
  String get pastMealsWillAppearHere => 'Las comidas pasadas aparecerán aquí.';

  @override
  String get generateShoppingList => 'Generar lista de la compra';

  @override
  String get addIngredientsFromPlannedRecipeMeals =>
      'Añade ingredientes desde comidas planificadas con receta.';

  @override
  String get generate => 'Generar';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get yesterday => 'Ayer';

  @override
  String get customMeal => 'Comida personalizada';

  @override
  String get recipeMealCanGenerateShoppingItems =>
      'Comida con receta • Puede generar compra';

  @override
  String get customMealWillNotGenerateShoppingItems =>
      'Comida personalizada • No generará compra';

  @override
  String get edit => 'Editar';

  @override
  String get deleteMealPlan => 'Eliminar plan de comida';

  @override
  String get recipe => 'Receta';

  @override
  String get custom => 'Personalizada';

  @override
  String get noShoppingItemsYet => 'Todavía no hay artículos de compra';

  @override
  String get addYourFirstItem => 'Añade tu primer artículo.';

  @override
  String get toBuy => 'Por comprar';

  @override
  String get bought => 'Comprado';

  @override
  String get unnamedItem => 'Elemento sin nombre';

  @override
  String get fromMealPlan => 'Desde plan de comida';

  @override
  String get markAsNotBought => 'Marcar como no comprado';

  @override
  String get markAsBought => 'Marcar como comprado';

  @override
  String get noDueDate => 'Sin fecha límite';

  @override
  String get deleteChore => 'Eliminar tarea recurrente';

  @override
  String get doesNotRepeat => 'No se repite';

  @override
  String get completeNow => 'Completar ahora';

  @override
  String get completeChore => 'Completar tarea recurrente';

  @override
  String get editChore => 'Editar tarea recurrente';

  @override
  String get overdue => 'Vencido';

  @override
  String get upcoming => 'Próximo';

  @override
  String get noItemsYet => 'Todavía no hay elementos';

  @override
  String get noOpenItems => 'No hay elementos abiertos';

  @override
  String get noDoneItems => 'No hay elementos hechos';

  @override
  String get everythingInThisListIsDone => 'Todo en esta lista está hecho.';

  @override
  String get nothingHasBeenCompletedYet => 'Todavía no se ha completado nada.';

  @override
  String get clearFilter => 'Limpiar filtro';

  @override
  String get delete => 'Eliminar';

  @override
  String get noActivitiesYet => 'Todavía no hay actividades';

  @override
  String get addSomethingFunToDo => 'Añade algo divertido para hacer.';

  @override
  String get untitledActivity => 'Actividad sin título';

  @override
  String get noRecipesYet => 'Todavía no hay recetas';

  @override
  String get addYourFirstRecipe => 'Añade tu primera receta.';

  @override
  String get untitledRecipe => 'Receta sin título';

  @override
  String get recipeDetailsAndIngredients =>
      'Detalles e ingredientes de la receta';

  @override
  String get deleteRecipe => 'Eliminar receta';

  @override
  String get instructionsAdded => 'Instrucciones añadidas';

  @override
  String get noInstructions => 'Sin instrucciones';

  @override
  String get openRecipe => 'Abrir receta';

  @override
  String get unsupportedListType => 'Tipo de lista no compatible';

  @override
  String get thisListTypeIsNotSupportedByTheCurrentAppVersion =>
      'Este tipo de lista no es compatible con la versión actual de la app.';

  @override
  String get untitledTask => 'Tarea sin título';

  @override
  String get noDeadline => 'Sin fecha límite';

  @override
  String get deleteTask => 'Eliminar tarea';

  @override
  String get noPriority => 'Sin prioridad';

  @override
  String get markAsOpen => 'Marcar como abierto';

  @override
  String get completeTask => 'Completar tarea';

  @override
  String get editTask => 'Editar tarea';

  @override
  String get done => 'Hecho';

  @override
  String get noMoviesYet => 'Todavía no hay películas';

  @override
  String get addAMovieToWatch => 'Añade una película para ver.';

  @override
  String get untitledMovie => 'Película sin título';

  @override
  String get noTasksYet => 'Todavía no hay tareas';

  @override
  String get createYourFirstTask => 'Crea tu primera tarea.';

  @override
  String get untitledItem => 'Elemento sin título';

  @override
  String get markAsDone => 'Marcar como hecho';

  @override
  String get noChoresYet => 'Todavía no hay tareas recurrentes';

  @override
  String get createYourFirstChore => 'Crea tu primera tarea recurrente.';

  @override
  String get noIdeasYet => 'Todavía no hay ideas';

  @override
  String get addYourFirstIdea => 'Añade tu primera idea.';

  @override
  String get untitledIdea => 'Idea sin título';

  @override
  String get groupInvitation => 'Invitación de grupo';

  @override
  String get accept => 'Aceptar';

  @override
  String get myGroups => 'Mis grupos';

  @override
  String get createYourFirstGroup => 'Crea tu primer grupo';

  @override
  String get untitledGroup => 'Grupo sin título';

  @override
  String get noPendingInvitations => 'No hay invitaciones pendientes';

  @override
  String get groupInvitesWillAppearHere =>
      'Las invitaciones de grupo aparecerán aquí.';

  @override
  String get pendingInvitations => 'Invitaciones pendientes';

  @override
  String get addMealPlan => 'Añadir plan de comida';

  @override
  String get mealPlan => 'Plan de comida';

  @override
  String get planAMealForADateAndOptionallyChooseARecipe =>
      'Planifica una comida para una fecha y, opcionalmente, elige una receta.';

  @override
  String get mealType => 'Tipo de comida';

  @override
  String get optionalYouCanAlsoCreateACustomMealNote =>
      'Opcional. También puedes crear una nota de comida personalizada.';

  @override
  String get noRecipeCustomMeal => 'Sin receta / comida personalizada';

  @override
  String get note => 'Nota';

  @override
  String get optionalEGFamilyDinnerOrLeftovers =>
      'Opcional, por ejemplo cena familiar o sobras';

  @override
  String get add => 'Añadir';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Comida';

  @override
  String get dinner => 'Cena';

  @override
  String get snack => 'Snack';

  @override
  String get ingredientNameIsRequired =>
      'El nombre del ingrediente es obligatorio.';

  @override
  String get quantityMustBeANumber => 'La cantidad debe ser un número.';

  @override
  String get addIngredient => 'Añadir ingrediente';

  @override
  String get ingredient => 'Ingrediente';

  @override
  String get addOneIngredientForThisRecipe =>
      'Añade un ingrediente para esta receta.';

  @override
  String get name => 'Nombre';

  @override
  String get tomatoes => 'Tomates';

  @override
  String get quantity => 'Cantidad';

  @override
  String get unit => 'Unidad';

  @override
  String get pcsGMl => 'uds / g / ml';

  @override
  String get optional => 'Opcional';

  @override
  String get editInstructions => 'Editar instrucciones';

  @override
  String get cookingInstructions => 'Instrucciones de cocina';

  @override
  String get addThePreparationStepsForThisRecipe =>
      'Añade los pasos de preparación de esta receta.';

  @override
  String get instructions => 'Instrucciones';

  @override
  String get text1ChopVegetables2CookPasta3MixEverything =>
      '1. Corta las verduras\n2. Cocina la pasta\n3. Mezcla todo';

  @override
  String get createList => 'Crear lista';

  @override
  String get listName => 'Nombre de la lista';

  @override
  String get moviesToWatch => 'Películas para ver';

  @override
  String get listType => 'Tipo de lista';

  @override
  String get prepNotSet => 'Preparación sin definir';

  @override
  String get cookNotSet => 'Cocción sin definir';

  @override
  String get servingsNotSet => 'Raciones sin definir';

  @override
  String get noInstructionsYet => 'Todavía no hay instrucciones.';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get noIngredientsYet => 'Todavía no hay ingredientes.';

  @override
  String get info => 'Información';

  @override
  String get close => 'Cerrar';

  @override
  String get unnamedIngredient => 'Ingrediente sin nombre';

  @override
  String get amountNotSet => 'Cantidad sin definir';

  @override
  String get editIngredient => 'Editar ingrediente';

  @override
  String get deleteIngredient => 'Eliminar ingrediente';

  @override
  String get itemNameIsRequired => 'El nombre del artículo es obligatorio.';

  @override
  String get editShoppingItem => 'Editar artículo de compra';

  @override
  String get addShoppingItem => 'Añadir artículo de compra';

  @override
  String get shoppingItem => 'Artículo de compra';

  @override
  String get addAnItemQuantityAndUnit =>
      'Añade un artículo, cantidad y unidad.';

  @override
  String get titleIsRequired => 'El título es obligatorio.';

  @override
  String get customRecurrenceMustBeAtLeast2Days =>
      'La recurrencia personalizada debe ser de al menos 2 días.';

  @override
  String get priority => 'Prioridad';

  @override
  String get addDeadline => 'Añadir fecha límite';

  @override
  String get removeDeadline => 'Quitar fecha límite';

  @override
  String get recurrence => 'Recurrencia';

  @override
  String get chooseHowOftenThisChoreRepeats =>
      'Elige cada cuánto se repite esta tarea recurrente.';

  @override
  String get repeatEvery => 'Repetir cada';

  @override
  String get minimum2Days => 'Mínimo 2 días.';

  @override
  String get setNextDueDate => 'Establecer próxima fecha';

  @override
  String get removeNextDueDate => 'Quitar próxima fecha';

  @override
  String get whenYouCompleteThisChoreTheAppWillScheduleTheNextDueDate =>
      'Cuando completes esta tarea, la app programará la próxima fecha.';

  @override
  String get nonRecurringChoresCanStillBeCompletedManually =>
      'Las tareas no recurrentes también se pueden completar manualmente.';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descripción';

  @override
  String get email => 'Email';

  @override
  String get friendExampleCom => 'amigo@ejemplo.com';

  @override
  String get toDateCannotBeBeforeFromDate =>
      'La fecha final no puede ser anterior a la inicial.';

  @override
  String get fromMealPlans => 'Desde planes de comida';

  @override
  String get ingredientsFromRecipeBasedMealPlansInThisDateRangeWillBeAdde =>
      'Los ingredientes de planes con receta en este rango se añadirán a la compra.';

  @override
  String get noteGeneratingTheSameRangeMoreThanOnceMayCreateDuplicateShop =>
      'Nota: generar el mismo rango más de una vez puede crear artículos duplicados.';

  @override
  String get editMealPlan => 'Editar plan de comida';

  @override
  String get updateDateMealTypeRecipeOrNote =>
      'Actualiza fecha, tipo de comida, receta o nota.';

  @override
  String get noVotesYet2 => 'Todavía no hay votos.';

  @override
  String get average => 'Media';

  @override
  String get total => 'Total';

  @override
  String get you => 'Tú';

  @override
  String get noComment => 'Sin comentario';

  @override
  String get updateThisRecipeIngredient =>
      'Actualiza este ingrediente de la receta.';

  @override
  String get buyMilkWatchMovieCleanKitchen =>
      'Comprar leche / Ver película / Limpiar cocina';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get meAndPartner => 'Yo y mi pareja';

  @override
  String get recipeNameIsRequired => 'El nombre de la receta es obligatorio.';

  @override
  String get addRecipe => 'Añadir receta';

  @override
  String get saveMealsYouCanPlanAndShopFromLater =>
      'Guarda comidas que podrás planificar y convertir en compra más adelante.';

  @override
  String get recipeName => 'Nombre de la receta';

  @override
  String get spaghettiCarbonara => 'Espaguetis carbonara';

  @override
  String get comment => 'Comentario';

  @override
  String get removeVote => 'Quitar voto';

  @override
  String get groupNameIsRequired => 'El nombre del grupo es obligatorio.';

  @override
  String get groupInfo => 'Información del grupo';

  @override
  String get updateTheSharedSpaceNameAndDescription =>
      'Actualiza el nombre y la descripción del espacio compartido.';

  @override
  String get prepTime => 'Tiempo de preparación';

  @override
  String get cookTime => 'Tiempo de cocción';

  @override
  String get servings => 'Raciones';

  @override
  String get editRecipeInfo => 'Editar información de la receta';

  @override
  String get recipeInfo => 'Información de receta';

  @override
  String get updateNameDescriptionTimeAndServings =>
      'Actualiza nombre, descripción, tiempo y raciones.';

  @override
  String get prep => 'Preparación';

  @override
  String get cook => 'Cocción';

  @override
  String get missingGoogleIdToken => 'Falta el token ID de Google';

  @override
  String get failedToLoadMembers => 'No se pudieron cargar los miembros';

  @override
  String get failedToLoadInvitations =>
      'No se pudieron cargar las invitaciones';

  @override
  String get failedToLoadLists => 'No se pudieron cargar las listas';

  @override
  String get groupUpdated => 'Grupo actualizado';

  @override
  String get failedToUpdateGroup => 'No se pudo actualizar el grupo';

  @override
  String get failedToInviteMember => 'No se pudo invitar al miembro';

  @override
  String get failedToCreateList => 'No se pudo crear la lista';

  @override
  String get newList => 'Nueva lista';

  @override
  String get googleLoginFailed => 'Error al iniciar sesión con Google';

  @override
  String get emailAndPasswordAreRequired =>
      'Email y contraseña son obligatorios';

  @override
  String get checkYourEmailToConfirmYourAccount =>
      'Revisa tu email para confirmar tu cuenta';

  @override
  String get unexpectedError => 'Error inesperado';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get logInToManageYourSharedListsPlansAndChores =>
      'Inicia sesión para gestionar tus listas, planes y tareas compartidas.';

  @override
  String get createASpaceForYourSharedLifeGroupsListsChoresIdeasMealsAndM =>
      'Crea un espacio para vuestra vida compartida: grupos, listas, tareas, ideas, comidas y más.';

  @override
  String get password => 'Contraseña';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get needAnAccountSignUp => '¿Necesitas una cuenta? Regístrate';

  @override
  String get alreadyHaveAnAccountLogIn => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get user => 'Usuario';

  @override
  String get failedToLoadHomeData =>
      'No se pudieron cargar los datos de inicio';

  @override
  String get invitationAccepted => 'Invitación aceptada';

  @override
  String get failedToAcceptInvitation => 'No se pudo aceptar la invitación';

  @override
  String get declineInvitationIsNotAvailableYet =>
      'Rechazar invitaciones aún no está disponible';

  @override
  String get weCanAddProperDeclineSupportInTheNextStep =>
      'Podemos añadir soporte para rechazar en el siguiente paso.';

  @override
  String get groupCreated => 'Grupo creado';

  @override
  String get failedToCreateGroup => 'No se pudo crear el grupo';

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get list => 'Lista';

  @override
  String get failedToLoadItems => 'No se pudieron cargar los elementos';

  @override
  String get shoppingItemsGeneratedOpenShoppingToReviewThem =>
      'Artículos de compra generados. Abre Compra para revisarlos.';

  @override
  String get failedToGenerateShoppingItems =>
      'No se pudieron generar artículos de compra';

  @override
  String get itemCreated => 'Elemento creado';

  @override
  String get failedToCreateItem => 'No se pudo crear el elemento';

  @override
  String get shoppingItemCreated => 'Artículo de compra creado';

  @override
  String get failedToCreateShoppingItem =>
      'No se pudo crear el artículo de compra';

  @override
  String get failedToLoadRecipes => 'No se pudieron cargar las recetas';

  @override
  String get mealPlanned => 'Comida planificada';

  @override
  String get failedToCreateMealPlan => 'No se pudo crear el plan de comida';

  @override
  String get recipeCreated => 'Receta creada';

  @override
  String get failedToCreateRecipe => 'No se pudo crear la receta';

  @override
  String get itemUpdated => 'Elemento actualizado';

  @override
  String get failedToUpdateItem => 'No se pudo actualizar el elemento';

  @override
  String get shoppingItemUpdated => 'Artículo de compra actualizado';

  @override
  String get failedToUpdateShoppingItem =>
      'No se pudo actualizar el artículo de compra';

  @override
  String get mealPlanUpdated => 'Plan de comida actualizado';

  @override
  String get failedToUpdateMealPlan =>
      'No se pudo actualizar el plan de comida';

  @override
  String get itemCompleted => 'Elemento completado';

  @override
  String get failedToCompleteItem => 'No se pudo completar el elemento';

  @override
  String get shoppingItemReopened => 'Artículo de compra reabierto';

  @override
  String get itemReopened => 'Elemento reabierto';

  @override
  String get taskReopened => 'Tarea reabierta';

  @override
  String get failedToReopenItem => 'No se pudo reabrir el elemento';

  @override
  String get markedAsBought => 'Marcado como comprado';

  @override
  String get markedAsNotBought => 'Marcado como no comprado';

  @override
  String get deleteItem2 => '¿Eliminar elemento?';

  @override
  String get thisWillPermanentlyDeleteTheItemFromThisList =>
      'Esto eliminará permanentemente el elemento de esta lista.';

  @override
  String get itemDeleted => 'Elemento eliminado';

  @override
  String get failedToDeleteItem => 'No se pudo eliminar el elemento';

  @override
  String get deleteShoppingItem => '¿Eliminar artículo de compra?';

  @override
  String get thisWillRemoveThisItemFromYourShoppingList =>
      'Esto quitará este artículo de tu lista de compra.';

  @override
  String get shoppingItemDeleted => 'Artículo de compra eliminado';

  @override
  String get failedToDeleteShoppingItem =>
      'No se pudo eliminar el artículo de compra';

  @override
  String get deleteMealPlan2 => '¿Eliminar plan de comida?';

  @override
  String get thisWillRemoveThisMealFromYourPlan =>
      'Esto quitará esta comida de tu plan.';

  @override
  String get mealPlanDeleted => 'Plan de comida eliminado';

  @override
  String get failedToDeleteMealPlan => 'No se pudo eliminar el plan de comida';

  @override
  String get deleteRecipe2 => '¿Eliminar receta?';

  @override
  String get thisWillPermanentlyDeleteThisRecipeAndItsIngredients =>
      'Esto eliminará permanentemente esta receta y sus ingredientes.';

  @override
  String get recipeDeleted => 'Receta eliminada';

  @override
  String get failedToDeleteRecipe => 'No se pudo eliminar la receta';

  @override
  String get voteRemoved => 'Voto eliminado';

  @override
  String get voteSaved => 'Voto guardado';

  @override
  String get failedToSaveVote => 'No se pudo guardar el voto';

  @override
  String get failedToLoadVotes => 'No se pudieron cargar los votos';

  @override
  String get recipeInfoUpdated => 'Información de receta actualizada';

  @override
  String get instructionsUpdated => 'Instrucciones actualizadas';

  @override
  String get ingredientAdded => 'Ingrediente añadido';

  @override
  String get ingredientUpdated => 'Ingrediente actualizado';

  @override
  String get deleteIngredient2 => '¿Eliminar ingrediente?';

  @override
  String get failedToLoadRecipeDetails =>
      'No se pudieron cargar los detalles de la receta';

  @override
  String get addMeal => 'Añadir comida';

  @override
  String get create => 'Crear';

  @override
  String get noDate => 'Sin fecha';

  @override
  String get untitledChore => 'Tarea recurrente sin título';

  @override
  String get untitledList => 'Lista sin título';

  @override
  String get addItem => 'Añadir elemento';

  @override
  String get optional2 => 'Opcional.';

  @override
  String get genericList => 'Lista genérica';

  @override
  String get simpleSharedListForAnything =>
      'Lista compartida simple para cualquier cosa.';

  @override
  String get tasks => 'Tareas';

  @override
  String get trackOneTimeTasksAndToDos =>
      'Controla tareas puntuales y pendientes.';

  @override
  String get chores => 'Tareas recurrentes';

  @override
  String get recurringHouseholdWork => 'Trabajo recurrente del hogar.';

  @override
  String get movies => 'Películas';

  @override
  String get moviesToWatchAndVoteOn => 'Películas para ver y votar.';

  @override
  String get ideas => 'Ideas';

  @override
  String get ideasToCollectAndDiscuss => 'Ideas para guardar y comentar.';

  @override
  String get activities => 'Actividades';

  @override
  String get thingsToDoTogether => 'Cosas para hacer juntos.';

  @override
  String get recipes => 'Recetas';

  @override
  String get mealsAndCookingIdeas => 'Comidas e ideas de cocina.';

  @override
  String get shopping => 'Compra';

  @override
  String get sharedShoppingList => 'Lista de compra compartida.';

  @override
  String get mealPlanning => 'Planificación de comidas';

  @override
  String get planMealsByDay => 'Planifica comidas por día.';

  @override
  String get none => 'Ninguna';

  @override
  String get low => 'Baja';

  @override
  String get lowPriority => 'Prioridad baja';

  @override
  String get medium => 'Media';

  @override
  String get mediumPriority => 'Prioridad media';

  @override
  String get high => 'Alta';

  @override
  String get highPriority => 'Prioridad alta';

  @override
  String get daily => 'Diaria';

  @override
  String get repeatsEveryDay => 'Se repite cada día.';

  @override
  String get weekly => 'Semanal';

  @override
  String get repeatsEveryWeek => 'Se repite cada semana.';

  @override
  String get monthly => 'Mensual';

  @override
  String get repeatsEveryMonth => 'Se repite cada mes.';

  @override
  String get everyNDays => 'Cada N días';

  @override
  String get repeatsAfterACustomNumberOfDays =>
      'Se repite después de un número personalizado de días.';

  @override
  String get doesNotRepeat2 => 'No se repite.';

  @override
  String get days => 'días';

  @override
  String get themeDialogTitle => 'Elegir tema';

  @override
  String get themeSystem => 'Predeterminado del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSubtitleSystem => 'Usando el tema del dispositivo';

  @override
  String get themeSubtitleLight => 'Claro';

  @override
  String get themeSubtitleDark => 'Oscuro';
}
