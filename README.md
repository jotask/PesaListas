# PesaListas

PesaListas is a shared household planning app built with Flutter and Supabase. It helps people organize groups, lists, chores, tasks, recipes, meal plans, shopping, ideas, movies, and activities in one shared space.

The project is designed around collaborative living: families, couples, roommates, and small groups can plan together, vote on ideas, manage recurring work, and keep shared household information organized.

## Overview

PesaListas provides shared spaces where members can create and manage different kinds of lists. Each list type is tailored to a specific use case, such as tasks, chores, recipes, shopping, or voting-based decisions.

The app currently supports English and Spanish, light and dark themes, persistent user preferences, and group-based collaboration.

## Current features

### Authentication and profiles

- Google sign-in
- Supabase authentication
- User profile creation
- Display name editing
- Avatar sync from authentication metadata
- Settings screen
- Persistent language preference
- Persistent theme preference

### Groups

- Create groups
- Edit group name and description
- Use groups individually or as shared spaces
- View member avatars
- Invite members by email
- Accept invitations
- Decline invitations
- Cancel pending invitations

### Lists

- Create lists inside groups
- Edit list name and description
- Archive lists
- Delete lists
- Dedicated layouts for different list types

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

- Create, edit, and delete items
- Complete and reopen items
- Add deadlines to task-style items
- Add priorities
- Support recurring chores
- Track next due dates

### Voting lists

Voting is available for list types where a group may want to choose together, such as movies, ideas, or activities.

Supported voting features:

- Add a vote
- Update a vote
- Remove a vote
- View vote summaries
- View vote details

### Recipes

- Create recipes
- Edit recipe information
- Edit cooking instructions separately
- Add ingredients
- Edit ingredients
- Delete ingredients
- Delete recipes
- View recipe details in a dedicated dialog

### Meal planning

- Create meal plans
- Link meals to recipes
- Create custom meals without recipes
- Edit meal plans
- Delete meal plans
- Filter meals by all, upcoming, this week, and past
- Group meal plans by date
- Show whether a meal can generate shopping items

### Shopping

- Create shopping items
- Edit shopping items
- Delete shopping items
- Mark items as bought
- Mark items as not bought
- Group shopping items into “To buy” and “Bought”
- Generate shopping items from recipe-based meal plans
- Show recipe and meal-plan source information for generated items
- Prevent duplicate generated shopping items

### Localization and appearance

- English interface
- Spanish interface
- In-app language selector
- System, light, and dark theme options
- Persisted language and theme choices

## Tech stack

- Flutter
- Dart
- Supabase Auth
- Supabase Postgres
- Supabase Row Level Security
- Google Sign-In
- Flutter localization
- Shared preferences

## Roadmap

### Short term

- Add an archived lists screen
- Restore archived lists
- Improve archived list management
- Continue polishing list settings
- Improve long-text handling across small screens
- Complete a full smoke-test pass across all major flows

### Group management

- Remove members from groups
- Change member roles
- Improve owner and admin controls
- Show clearer group permissions
- Improve invitation history and pending invitation management

### Shopping and meal planning

- Merge duplicate shopping ingredients across different meals
- Group shopping items by recipe or source
- Clear bought shopping items
- Add a weekly meal planning view
- Add faster meal duplication and meal moving

### Recipes

- Add recipe search
- Add recipe filters
- Add favorite recipes
- Add recipe categories or tags
- Add recipe duplication

### Settings and preferences

- Add app version information
- Add notification preferences
- Add reminder preferences for chores, meals, and shopping
- Improve profile customization

### Quality and maintainability

- Add automated tests for core flows
- Add widget tests for important screens and dialogs
- Improve data parsing and validation
- Continue simplifying repository and UI structure
- Keep localization coverage complete as new features are added

## Project goals

PesaListas aims to be:

- Simple enough for everyday household use
- Flexible enough for many kinds of shared lists
- Collaborative by default
- Friendly for multilingual households
- Useful for planning, deciding, cooking, shopping, and keeping track of shared responsibilities
