# My Yami Recipes

Flutter app for storing recipes (Android-first; desktop platform folders also exist).
UI is localized: **Russian** when the device language is Russian, **English** otherwise.

## Conventions

- **Code comments must be in English.**
  (Older code still has some Russian comments — translate them when touching that code.)
- **No hardcoded UI strings.** Add every user-facing string to both `lib/l10n/app_en.arb` (template, with
  `@key` placeholder metadata) and `lib/l10n/app_ru.arb`, then use `context.l10n.key`
  (`import '.../l10n/l10n_helpers.dart'`). `flutter pub get` / build regenerates `app_localizations*.dart`.
  Avoid ARB keys that clash with helper methods in `l10n_helpers.dart`.
- Follow the existing color scheme: `ColorScheme.fromSeed(seedColor: Colors.deepOrange)`, Material 3.
  - AppBar: `backgroundColor: Theme.of(context).colorScheme.inversePrimary`
  - Section headers: `primaryContainer` / `onPrimaryContainer`; accents: `primary`
  - Calorie icon: `Icons.local_fire_department`, `Colors.deepOrange`
  - Search fields: `OutlineInputBorder(borderRadius: 12)`, `filled: true`, `fillColor: colorScheme.surface`, `prefixIcon: Icon(Icons.search)`
  - List items: `Card` with `margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8)` + `ListTile`; leading = category SVG via `AppStrings.getSvgAssetForCategory`
- Guard `BuildContext` usage after `await` with `if (!mounted) return;`.
- Run `flutter analyze <paths>` after changes; keep changed files free of issues.

## Architecture

Feature-first, loosely clean-architecture, under `lib/feature/<feature>/{data,domain,presentation}`.

### recipes (`lib/feature/recipes`)
- `domain/entities/recipe.dart` — `Recipe` (id, title, description, imageUrl, cookingTimeMinutes, category, calories, ingredients, steps) and `IngredientEntity` (`name` = product only, `amount` as written e.g. "400"/"1,5"/"1/2"/"2-3"/"по вкусу", normalized `unit` e.g. "г"/"ст. л."/"шт."; getters `quantityLabel`, `displayText` = "Name — amount unit").
- `domain/ingredient_parser.dart` — `IngredientParser.parse(line)` splits a free-form line into name/amount/unit (forms: "Name — qty", "Name: qty", "Name qty", "qty Name", "Name (qty)", "Name по вкусу"); used by the clipboard parser, the add/edit form (one `displayText` per line, parsed back on save) and legacy-data migration. Tests: `test/ingredient_parser_test.dart`.
- `data/models/recipe_model.dart` — JSON model, `toEntity()` / `fromEntity()`. `IngredientModel.toEntity()` migrates legacy ingredients (whole line in `name`, empty amount/unit) via `IngredientParser`. `fromJson` reads `cookingTimeMinutes` (local) or `prepTimeMinutes` (remote/LLM); `toJson` writes `calories`.
- `domain/repositories/recipes_repository_impl.dart` — **singleton** with in-memory cache, persisted via `lib/services/recipe_local_storage.dart` (SharedPreferences key `saved_recipes_list`).
- `presentation/bloc/` — `RecipesBloc` (events: Load/Add/Delete/Restore/Update/Filter; `_applyCurrentFilters()` re-applies state filters after delete/restore; state holds `allRecipes`, `filteredRecipes`, search/category/maxCalories filters).
- `presentation/screen/recipes_screen.dart` — main screen. AppBar actions: weekly menu, special menu, OCR scan, add recipe (`Icons.add_box`: prefilled from clipboard text via `LocalRecipeParserService` if present, otherwise an empty `AddRecipeBottomSheet`). Body: search, calorie slider, category chips, swipe-to-delete list (SnackBar «Отменить» for 5 s → `RestoreRecipeEvent` puts the recipe back at its old index; note `persist: false` is required, SnackBars with an action persist by default in this Flutter version), long-press to edit. The FAB is currently commented out (replaced by the `add_box` action).
- `presentation/screen/recipe_detail_screen.dart`, `presentation/widget/add_recipe_bottom_sheet.dart`.

### menu (`lib/feature/menu`) — weekly meal plan + special-occasion menu
Both menus are opened from the main AppBar with `_recipesBloc.state.allRecipes`, store **recipe ids only**
in SharedPreferences (resolved against current recipes on load; deleted recipes disappear / become empty slots)
and save immediately on every change.

Shared code:
- `domain/shopping_list.dart` — `ShoppingItem` (`key`, `amountLabel`), `shoppingKey()`, `buildShoppingList(Iterable<Recipe>)`: first converts кг/мг → г and л → мл via `toBaseUnit()` (numbers, fractions, ranges), then groups by lowercase name+unit, sums numeric amounts incl. `0,5` and `1/2`; non-numeric amounts are joined with ` + `.
- `presentation/widget/recipe_picker_sheet.dart` — `RecipePickerSheet.pickOne()` (single choice, optional «Без блюда», returns `RecipePickResult`) and `.pickMany()` (checkbox multi-select + «Готово (N)», returns the full `Set<String>` of selected ids). Both have title search and lift above the keyboard.
- `presentation/widget/shopping_list_view.dart` — `ShoppingListView`: «Куплено N из M» + progress; unchecked items on top, checked ones move to the «Куплено (N)» section at the bottom (with «Сбросить»).
- `presentation/widget/summary_bar.dart` — `SummaryBar`.

Weekly menu (AppBar icon `restaurant_menu`):
- `domain/weekly_menu.dart`
  - `MealType` (breakfast/lunch/dinner) with `title` and `preferredCategories`:
    breakfast → Завтраки, Выпечка; lunch → Супы, Основные блюда; dinner → Основные блюда, Салаты.
    Fallback when no recipes match: all except Напитки/Десерты.
  - `weekDays` (Mon–Sun, Russian), `DayMenu` (map MealType → Recipe?), `List<DayMenu>.allRecipes` extension.
  - `WeeklyMenuGenerator.generate()` (shuffled queue per meal → minimal repeats), `randomFor()`.
- `data/weekly_menu_storage.dart` — key `weekly_menu`. `clear()` exists but is not wired into the UI.
- `presentation/screen/weekly_menu_screen.dart` — tabs «Меню» (day cards; per meal: random replace / `pickOne` / tap to open detail) and «Продукты». AppBar `_RegenerateButton` (🎲 «Новое меню (удерживать)») regenerates the whole week on **long press only**; a tap just shows a hint SnackBar (protection against accidental reset).

Special-occasion menus (AppBar icon `celebration`, «Праздничные меню») — **up to 3 saved menus**:
- `domain/special_menu.dart` — `SpecialMenu` model (`id`, `name`, ordered `recipeIds`, `checkedProducts`; `isEmpty`, `displayName`, `resolveRecipes()`, JSON) and `dishCountLabel()` (Russian plural).
- `data/special_menu_storage.dart` — key `special_menus` (JSON list). `SpecialMenuStorage.maxMenus = 3`; `save()` upserts and returns false when adding would exceed the limit; `delete(id)`. Migrates the old single-menu key `special_menu` on first load.
- `presentation/screen/special_menu_list_screen.dart` — entry screen: «Сохранено N из 3», menu cards (name, dish count, kcal, dish titles; tap → editor; 🗑 → confirm + delete). FAB «Новое меню»; when the limit is reached it is muted, a hint card is shown and a tap explains that one menu must be deleted first.
- `presentation/screen/special_menu_screen.dart` — editor of one menu, tabs «Блюда» and «Продукты». Editable name; dishes from **any** category are added via `pickMany` over all recipes (sorted by title) from an extended FAB «Добавить блюда» (dishes tab only). Dishes are grouped by category in `AppStrings.recipeCategories` order, with remove button and tap → detail. A new menu (`isNew`) is not persisted until it gets a name or a dish, so leaving it empty doesn't take a slot. AppBar 🗑 deletes after `confirmDeleteSpecialMenu()` and pops with `true`.

Known quirk (both menus): checked keys of products no longer in the list stay stored.


### l10n (`lib/l10n`)
- `app_en.arb` (template) / `app_ru.arb` → generated `app_localizations*.dart` (config in `l10n.yaml`, `generate: true` in pubspec).
- `l10n_helpers.dart`: `context.l10n`, `resolveAppLocale()` (primary device locale `ru` → ru, else en; secondary languages ignored; wired in `main.dart`
  via `localeListResolutionCallback`), and `AppLocalizationsX` for **stored data**, which stays in Russian so saved
  recipes/menus don't depend on locale: `categoryLabel(stored)`, `unitLabel(stored)`, `amountLabel(stored)`
  ("по вкусу"…), `quantity(amount, unit)`, `mealTitle(MealType)`, `weekDay(index)`. These map Russian values to
  ASCII ids used by ARB `select` messages (`categoryName`, `unitName`, `amountPhrase`). Plurals: `dishCount`.
- Domain classes hold no display strings (`MealType` has only `preferredCategories`; `daysInWeek = 7`;
  `ShoppingItem.amountText` + `unit` are combined in UI with `quantity`). Internal value `'Все'` for "all
  categories" is still used by the bloc; only its chip label is localized.
- The edit form shows ingredients with localized units; `IngredientParser` accepts English units/phrases too
  and always stores the Russian ones. Tests: `test/l10n_test.dart`.

### Other
- `lib/core/constants/app_strings.dart` — recipe categories, category → SVG map (`assets/icons/categories/`), common strings. Note: «Закуски» has no SVG mapping (falls back to «Другое»).
- `lib/services/` — `ocr_service.dart` (Google ML Kit), `local_recipe_parser_service.dart` (clipboard text → Recipe: first line = title, sections by headers «Ингредиенты»/«Приготовление» or heuristics; unrecognized lines go to description; if no ingredients recognized, the whole text goes to the ingredients field; covered by `test/local_recipe_parser_service_test.dart`), Groq/DeepSeek LLM parsers (currently commented out in the scan flow).
- `lib/main.dart` — `MaterialApp` with the deepOrange theme; `RecipesScreen` also creates its own `RecipesBloc`.

## Commands

```sh
flutter pub get
flutter analyze lib/feature/menu
flutter run
flutter test test/ingredient_parser_test.dart test/local_recipe_parser_service_test.dart test/shopping_list_test.dart test/l10n_test.dart  # widget_test.dart is the stale counter template and fails
```

## Android

- Release builds use R8: `android/app/proguard-rules.pro` has `-dontwarn` rules for the optional ML Kit recognizers
  (Chinese/Devanagari/Japanese/Korean) referenced by `google_mlkit_text_recognition`; without them
  `flutter build apk --release` fails with "Missing classes detected while running R8".
- Release is still signed with the debug key (see TODO in `android/app/build.gradle.kts`).

## iOS

- Minimum iOS **15.5** (required by Google ML Kit): set in `ios/Podfile` (`platform :ios, '15.5'`, `$iOSVersion`) and `IPHONEOS_DEPLOYMENT_TARGET` in `ios/Runner.xcodeproj/project.pbxproj`. Keep them in sync.
- `ios/Podfile` post_install excludes `armv7` (ML Kit is 64-bit only) and raises pods' deployment target.
- Camera/photo permissions are declared in `ios/Runner/Info.plist`.
- Development happens on Windows, so iOS builds can't be verified locally — build on a Mac: `flutter pub get && cd ios && pod install && cd .. && flutter build ios`.

## Secrets

- **Never hardcode API keys.** Groq/DeepSeek keys are read via `String.fromEnvironment` and passed with
  `flutter run --dart-define-from-file=config/api_keys.json`. `config/api_keys.json` is gitignored;
  `config/api_keys.example.json` shows the format.
