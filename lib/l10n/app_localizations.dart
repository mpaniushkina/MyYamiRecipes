import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get appTitle;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @weeklyMenu.
  ///
  /// In en, this message translates to:
  /// **'Weekly menu'**
  String get weeklyMenu;

  /// No description provided for @specialMenu.
  ///
  /// In en, this message translates to:
  /// **'Holiday menu'**
  String get specialMenu;

  /// No description provided for @specialMenus.
  ///
  /// In en, this message translates to:
  /// **'Holiday menus'**
  String get specialMenus;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add recipe'**
  String get addRecipe;

  /// No description provided for @searchByTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by title'**
  String get searchByTitle;

  /// No description provided for @caloriesAny.
  ///
  /// In en, this message translates to:
  /// **'Calories: any'**
  String get caloriesAny;

  /// No description provided for @caloriesUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} kcal'**
  String caloriesUpTo(int count);

  /// No description provided for @resetCalories.
  ///
  /// In en, this message translates to:
  /// **'Reset calories'**
  String get resetCalories;

  /// No description provided for @kcalValue.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal'**
  String kcalValue(int count);

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesValue(int count);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @recipesNotFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get recipesNotFound;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe \"{title}\" deleted'**
  String recipeDeleted(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @recipeFromScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Recipe from screenshot'**
  String get recipeFromScreenshot;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan error: {error}'**
  String scanError(String error);

  /// No description provided for @newRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// No description provided for @dishTitle.
  ///
  /// In en, this message translates to:
  /// **'Dish name'**
  String get dishTitle;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterTitle;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @cookingTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Cooking time (minutes)'**
  String get cookingTimeMinutes;

  /// No description provided for @enterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumber;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @saveRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save recipe'**
  String get saveRecipe;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get tabGroceries;

  /// No description provided for @tabDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get tabDishes;

  /// No description provided for @holdForNewMenu.
  ///
  /// In en, this message translates to:
  /// **'Hold the button to create a new menu'**
  String get holdForNewMenu;

  /// No description provided for @newMenuCreated.
  ///
  /// In en, this message translates to:
  /// **'New menu created'**
  String get newMenuCreated;

  /// No description provided for @weekCaloriesSummary.
  ///
  /// In en, this message translates to:
  /// **'Week total: {total} kcal · average {average} kcal/day'**
  String weekCaloriesSummary(int total, int average);

  /// No description provided for @notSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// No description provided for @replaceRandom.
  ///
  /// In en, this message translates to:
  /// **'Replace with a random one'**
  String get replaceRandom;

  /// No description provided for @chooseRecipe.
  ///
  /// In en, this message translates to:
  /// **'Choose recipe'**
  String get chooseRecipe;

  /// No description provided for @regenerateButton.
  ///
  /// In en, this message translates to:
  /// **'New menu\n(hold)'**
  String get regenerateButton;

  /// No description provided for @addRecipesForWeeklyMenu.
  ///
  /// In en, this message translates to:
  /// **'Add recipes to create a weekly menu'**
  String get addRecipesForWeeklyMenu;

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

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @noDish.
  ///
  /// In en, this message translates to:
  /// **'No dish'**
  String get noDish;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @doneCount.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String doneCount(int count);

  /// No description provided for @noIngredientsInRecipes.
  ///
  /// In en, this message translates to:
  /// **'The selected recipes have no ingredients'**
  String get noIngredientsInRecipes;

  /// No description provided for @boughtProgress.
  ///
  /// In en, this message translates to:
  /// **'Bought {bought} of {total}'**
  String boughtProgress(int bought, int total);

  /// No description provided for @allBought.
  ///
  /// In en, this message translates to:
  /// **'Everything is bought!'**
  String get allBought;

  /// No description provided for @boughtSection.
  ///
  /// In en, this message translates to:
  /// **'Bought ({count})'**
  String boughtSection(int count);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @menuDeleted.
  ///
  /// In en, this message translates to:
  /// **'Menu deleted'**
  String get menuDeleted;

  /// No description provided for @menuLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can save up to {max} menus. Delete one of them to create a new one.'**
  String menuLimitReached(int max);

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} of {max}'**
  String savedCount(int count, int max);

  /// No description provided for @newMenu.
  ///
  /// In en, this message translates to:
  /// **'New menu'**
  String get newMenu;

  /// No description provided for @menuLimitHint.
  ///
  /// In en, this message translates to:
  /// **'The limit of {max} menus is reached. To create a new one, delete one of the saved menus.'**
  String menuLimitHint(int max);

  /// No description provided for @noDishes.
  ///
  /// In en, this message translates to:
  /// **'No dishes'**
  String get noDishes;

  /// No description provided for @deleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete menu'**
  String get deleteMenu;

  /// No description provided for @noSpecialMenus.
  ///
  /// In en, this message translates to:
  /// **'No holiday menus yet.\nYou can save up to {max} menus — tap “New menu” to start.'**
  String noSpecialMenus(int max);

  /// No description provided for @deleteMenuQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete menu?'**
  String get deleteMenuQuestion;

  /// No description provided for @deleteMenuContent.
  ///
  /// In en, this message translates to:
  /// **'“{name}” and its grocery list will be deleted.'**
  String deleteMenuContent(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dishesForMenu.
  ///
  /// In en, this message translates to:
  /// **'Dishes for the menu'**
  String get dishesForMenu;

  /// No description provided for @dishRemoved.
  ///
  /// In en, this message translates to:
  /// **'“{title}” removed from the menu'**
  String dishRemoved(String title);

  /// No description provided for @addDishesForGroceries.
  ///
  /// In en, this message translates to:
  /// **'Add dishes to the menu and the grocery list will appear here'**
  String get addDishesForGroceries;

  /// No description provided for @addDishes.
  ///
  /// In en, this message translates to:
  /// **'Add dishes'**
  String get addDishes;

  /// No description provided for @menuName.
  ///
  /// In en, this message translates to:
  /// **'Menu name'**
  String get menuName;

  /// No description provided for @menuNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, New Year'**
  String get menuNameHint;

  /// No description provided for @addRecipesFirst.
  ///
  /// In en, this message translates to:
  /// **'Add recipes on the main screen first'**
  String get addRecipesFirst;

  /// No description provided for @addDishesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap “Add dishes” and find the recipes you need by title'**
  String get addDishesEmptyHint;

  /// No description provided for @removeFromMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove from menu'**
  String get removeFromMenu;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @dishCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dish} other{{count} dishes}}'**
  String dishCount(int count);

  /// Recipe category by internal id
  ///
  /// In en, this message translates to:
  /// **'{category, select, breakfast{Breakfast} soups{Soups} mains{Main courses} salads{Salads} desserts{Desserts} bakery{Baking} drinks{Drinks} snacks{Appetizers} other{Other}}'**
  String categoryName(String category);

  /// Ingredient unit by internal id
  ///
  /// In en, this message translates to:
  /// **'{unit, select, g{g} kg{kg} mg{mg} ml{ml} l{l} tbsp{tbsp} tsp{tsp} pcs{pcs} cup{cup} clove{clove} pinch{pinch} bunch{bunch} can{can} pack{pack} sachet{sachet} slice{slice} piece{piece} wedge{wedge} sprig{sprig} leaf{leaf} head{head} serving{serving} other{}}'**
  String unitName(String unit);

  /// Non-numeric ingredient amount by internal id
  ///
  /// In en, this message translates to:
  /// **'{phrase, select, toTaste{to taste} optional{optional} forServing{for serving} forFrying{for frying} knifeTip{a pinch} other{}}'**
  String amountPhrase(String phrase);
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
