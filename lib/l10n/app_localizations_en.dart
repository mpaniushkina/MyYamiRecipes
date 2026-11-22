// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Recipes';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get weeklyMenu => 'Weekly menu';

  @override
  String get specialMenu => 'Holiday menu';

  @override
  String get specialMenus => 'Holiday menus';

  @override
  String get addRecipe => 'Add recipe';

  @override
  String get searchByTitle => 'Search by title';

  @override
  String get caloriesAny => 'Calories: any';

  @override
  String caloriesUpTo(int count) {
    return 'Up to $count kcal';
  }

  @override
  String get resetCalories => 'Reset calories';

  @override
  String kcalValue(int count) {
    return '$count kcal';
  }

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String get allCategories => 'All';

  @override
  String get recipesNotFound => 'No recipes found';

  @override
  String recipeDeleted(String title) {
    return 'Recipe \"$title\" deleted';
  }

  @override
  String get undo => 'Undo';

  @override
  String get recipeFromScreenshot => 'Recipe from screenshot';

  @override
  String scanError(String error) {
    return 'Scan error: $error';
  }

  @override
  String get newRecipe => 'New recipe';

  @override
  String get dishTitle => 'Dish name';

  @override
  String get enterTitle => 'Enter a name';

  @override
  String get category => 'Category';

  @override
  String get description => 'Description';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get cookingTimeMinutes => 'Cooking time (minutes)';

  @override
  String get enterNumber => 'Enter a number';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get saveRecipe => 'Save recipe';

  @override
  String get steps => 'Steps';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabGroceries => 'Groceries';

  @override
  String get tabDishes => 'Dishes';

  @override
  String get holdForNewMenu => 'Hold the button to create a new menu';

  @override
  String get newMenuCreated => 'New menu created';

  @override
  String weekCaloriesSummary(int total, int average) {
    return 'Week total: $total kcal · average $average kcal/day';
  }

  @override
  String get notSelected => 'Not selected';

  @override
  String get replaceRandom => 'Replace with a random one';

  @override
  String get chooseRecipe => 'Choose recipe';

  @override
  String get regenerateButton => 'New menu\n(hold)';

  @override
  String get addRecipesForWeeklyMenu => 'Add recipes to create a weekly menu';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get noDish => 'No dish';

  @override
  String get clear => 'Clear';

  @override
  String doneCount(int count) {
    return 'Done ($count)';
  }

  @override
  String get noIngredientsInRecipes =>
      'The selected recipes have no ingredients';

  @override
  String boughtProgress(int bought, int total) {
    return 'Bought $bought of $total';
  }

  @override
  String get allBought => 'Everything is bought!';

  @override
  String boughtSection(int count) {
    return 'Bought ($count)';
  }

  @override
  String get reset => 'Reset';

  @override
  String get menuDeleted => 'Menu deleted';

  @override
  String menuLimitReached(int max) {
    return 'You can save up to $max menus. Delete one of them to create a new one.';
  }

  @override
  String savedCount(int count, int max) {
    return 'Saved $count of $max';
  }

  @override
  String get newMenu => 'New menu';

  @override
  String menuLimitHint(int max) {
    return 'The limit of $max menus is reached. To create a new one, delete one of the saved menus.';
  }

  @override
  String get noDishes => 'No dishes';

  @override
  String get deleteMenu => 'Delete menu';

  @override
  String noSpecialMenus(int max) {
    return 'No holiday menus yet.\nYou can save up to $max menus — tap “New menu” to start.';
  }

  @override
  String get deleteMenuQuestion => 'Delete menu?';

  @override
  String deleteMenuContent(String name) {
    return '“$name” and its grocery list will be deleted.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get dishesForMenu => 'Dishes for the menu';

  @override
  String dishRemoved(String title) {
    return '“$title” removed from the menu';
  }

  @override
  String get addDishesForGroceries =>
      'Add dishes to the menu and the grocery list will appear here';

  @override
  String get addDishes => 'Add dishes';

  @override
  String get menuName => 'Menu name';

  @override
  String get menuNameHint => 'For example, New Year';

  @override
  String get addRecipesFirst => 'Add recipes on the main screen first';

  @override
  String get addDishesEmptyHint =>
      'Tap “Add dishes” and find the recipes you need by title';

  @override
  String get removeFromMenu => 'Remove from menu';

  @override
  String get untitled => 'Untitled';

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
    );
    return '$_temp0';
  }

  @override
  String categoryName(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'breakfast': 'Breakfast',
      'soups': 'Soups',
      'mains': 'Main courses',
      'salads': 'Salads',
      'desserts': 'Desserts',
      'bakery': 'Baking',
      'drinks': 'Drinks',
      'snacks': 'Appetizers',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'g': 'g',
      'kg': 'kg',
      'mg': 'mg',
      'ml': 'ml',
      'l': 'l',
      'tbsp': 'tbsp',
      'tsp': 'tsp',
      'pcs': 'pcs',
      'cup': 'cup',
      'clove': 'clove',
      'pinch': 'pinch',
      'bunch': 'bunch',
      'can': 'can',
      'pack': 'pack',
      'sachet': 'sachet',
      'slice': 'slice',
      'piece': 'piece',
      'wedge': 'wedge',
      'sprig': 'sprig',
      'leaf': 'leaf',
      'head': 'head',
      'serving': 'serving',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String amountPhrase(String phrase) {
    String _temp0 = intl.Intl.selectLogic(phrase, {
      'toTaste': 'to taste',
      'optional': 'optional',
      'forServing': 'for serving',
      'forFrying': 'for frying',
      'knifeTip': 'a pinch',
      'other': '',
    });
    return '$_temp0';
  }
}
