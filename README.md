# PesaListas

PesaListas is a Flutter app for shared household planning. It helps groups manage shared lists, recipes, meal plans, shopping items, chores, tasks, ideas, movies, and activities.

The app uses Supabase for authentication, database storage, row-level security, and shared group data.

## Current status

The app currently supports:

- Google/Supabase authentication
- User profiles with display names and avatars
- Shared groups and individual groups
- Group invitations
- Group member previews
- Editable group name and description
- Multiple list types
- Tasks and chores
- Votable lists for ideas, movies, and activities
- Recipes with ingredients
- Meal planning linked to recipes
- Shopping lists backed by a dedicated `shopping_list_items` table
- Shopping generation from meal plans
- Duplicate prevention for generated shopping items
- Settings/profile screen
- English and Spanish localization foundation
- In-app language selector with persistence

## Main flows

### Groups

Users can create shared spaces called groups. Groups can be used individually or shared with other members.

Supported group features:

- Create groups
- View groups as cards
- See whether a group is individual or shared
- See member avatars
- Edit group name and description
- Invite members
- View pending invitations
- Accept invitations

### Lists

Groups can contain different types of lists. Each list type has its own UI behavior.

Supported list types include:

- Generic lists
- Tasks
- Chores
- Shopping
- Recipes
- Meal planning
- Movies
- Ideas
- Activities

### Tasks and chores

Task-like list types support completion and reopening.

Chore lists support recurring task behavior.

### Voting

Some list types support voting, such as:

- Movies
- Ideas
- Activities

Users can vote on items, update their vote, remove their vote, and view vote summaries.

### Recipes

Recipes are stored in the dedicated `recipes` table and ingredients are stored in `recipe_ingredients`.

Supported recipe features:

- Create recipes
- Edit recipe info
- Edit recipe instructions separately
- Delete recipes
- Add recipe ingredients
- Edit recipe ingredients
- Delete recipe ingredients
- View recipe detail dialogs
- Recipe cards with useful metadata

### Meal planning

Meal plans are stored in the dedicated `meal_plans` table.

Supported meal planning features:

- Create meal plans
- Edit meal plans
- Delete meal plans
- Link meal plans to recipes
- Create custom meals without recipes
- Filter meals by all, upcoming, this week, and past
- Group meals by date
- Show recipe/custom meal context

### Shopping

Shopping lists are stored in the dedicated `shopping_list_items` table.

Supported shopping features:

- Create shopping items
- Edit shopping items
- Delete shopping items
- Mark items as bought
- Mark items as not bought
- Group shopping items into To buy and Bought
- Show generated source context
- Show recipe and meal-plan source information for generated items

### Shopping generation

Meal planning can generate shopping items from planned recipe meals.

This uses the Supabase RPC:

```sql
generate_shopping_from_meal_plans(target_group_id, from_date, to_date)
```

Generated items include:

- Ingredient name
- Quantity
- Unit
- Source recipe
- Source meal plan

Duplicate generated shopping items are prevented at the database level.

## Settings and localization

The Settings page currently supports:

- Profile preview
- Display name editing
- Profile sync from Google/Auth metadata
- Sign out
- Preferences section
- Language selector
- English and Spanish localization
- Persisted language choice

The localization setup uses Flutter `gen-l10n` with ARB files.

Localization files:

```text
lib/l10n/app_en.arb
lib/l10n/app_es.arb
```

Generated localization files:

```text
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_es.dart
```

## Tech stack

- Flutter
- Dart
- Supabase
- Supabase Auth
- Supabase Postgres
- Row Level Security
- Google Sign-In
- Flutter localization
- Shared preferences for persisted language choice

## Project setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate localization files

```bash
flutter gen-l10n
```

### 3. Analyze the project

```bash
flutter analyze
```

### 4. Run the app

```bash
flutter run
```

## Required Flutter configuration

The project uses generated localization files. Make sure `pubspec.yaml` includes:

```yaml
flutter:
  generate: true
  uses-material-design: true
```

The project also requires:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  shared_preferences: ^2.5.5
  supabase_flutter: ^2.12.4
  google_sign_in: ^7.2.0
```

## Localization configuration

The project expects a root-level `l10n.yaml` file similar to:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n
synthetic-package: false
nullable-getter: false
```

After editing ARB files, regenerate localization files:

```bash
flutter gen-l10n
```

## Supabase setup

The app assumes a Supabase project with tables similar to:

- `profiles`
- `groups`
- `group_members`
- `group_invitations`
- `lists`
- `items`
- `item_votes`
- `item_completions`
- `recipes`
- `recipe_ingredients`
- `meal_plans`
- `shopping_list_items`

The app also expects row-level security policies and helper functions that allow group members to access shared group data.

Important RPC functions include:

- `sync_my_profile_from_auth`
- `invite_group_member`
- `accept_group_invitation`
- `complete_item`
- `generate_shopping_from_meal_plans`

## Database notes

Shopping generation depends on `shopping_list_items` having source columns:

```text
source_recipe_id
source_meal_plan_id
```

Generated shopping duplicate prevention is handled by a unique generated-items index and an updated RPC that avoids inserting duplicate generated items for the same meal plan, recipe, name, and unit.

## Development workflow

Recommended workflow before each commit:

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

If localization strings were changed, always run:

```bash
flutter gen-l10n
```

## Current recommended next work

Suggested next development areas:

1. Continue replacing remaining user-facing hardcoded strings with localization keys.
2. Add actual theme preference behavior.
3. Add notification preferences.
4. Persist more user app preferences.
5. Improve invitation management, including decline/cancel flows.
6. Add optional shopping deduplication and merging by ingredient.
7. Add more robust onboarding for first-time users.

## Notes for contributors

When adding new UI text:

- Add the English string to `lib/l10n/app_en.arb`
- Add the Spanish string to `lib/l10n/app_es.arb`
- Run `flutter gen-l10n`
- Use `context.l10n.someKey` or the existing localization helper pattern

Avoid localizing:

- Supabase table names
- Supabase column names
- RPC names
- Enum/storage values
- Debug labels
- Internal constants
