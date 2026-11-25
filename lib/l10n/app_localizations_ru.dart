// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Рецепты';

  @override
  String get recipesTitle => 'Рецепты';

  @override
  String get weeklyMenu => 'Меню на неделю';

  @override
  String get specialMenu => 'Праздничное меню';

  @override
  String get specialMenus => 'Праздничные меню';

  @override
  String get addRecipe => 'Добавить рецепт';

  @override
  String get searchByTitle => 'Поиск по названию';

  @override
  String get caloriesAny => 'Калории: любые';

  @override
  String caloriesUpTo(int count) {
    return 'До $count ккал';
  }

  @override
  String get resetCalories => 'Сбросить калории';

  @override
  String kcalValue(int count) {
    return '$count ккал';
  }

  @override
  String minutesValue(int count) {
    return '$count мин';
  }

  @override
  String get allCategories => 'Все';

  @override
  String get recipesNotFound => 'Рецепты не найдены';

  @override
  String recipeDeleted(String title) {
    return 'Рецепт \"$title\" удален';
  }

  @override
  String get undo => 'Отменить';

  @override
  String get recipeFromScreenshot => 'Рецепт со скриншота';

  @override
  String scanError(String error) {
    return 'Ошибка сканирования: $error';
  }

  @override
  String get newRecipe => 'Новый рецепт';

  @override
  String get dishTitle => 'Название блюда';

  @override
  String get enterTitle => 'Введите название';

  @override
  String get category => 'Категория';

  @override
  String get description => 'Описание';

  @override
  String get ingredients => 'Ингредиенты';

  @override
  String get cookingTimeMinutes => 'Время приготовления (минут)';

  @override
  String get enterNumber => 'Введите число';

  @override
  String get caloriesKcal => 'Калории (ккал)';

  @override
  String get saveRecipe => 'Сохранить рецепт';

  @override
  String get steps => 'Шаги';

  @override
  String get tabMenu => 'Меню';

  @override
  String get tabGroceries => 'Продукты';

  @override
  String get tabDishes => 'Блюда';

  @override
  String get holdForNewMenu => 'Удерживайте кнопку, чтобы составить новое меню';

  @override
  String get newMenuCreated => 'Новое меню составлено';

  @override
  String weekCaloriesSummary(int total, int average) {
    return 'Всего за неделю: $total ккал · в среднем $average ккал/день';
  }

  @override
  String get notSelected => 'Не выбрано';

  @override
  String get replaceRandom => 'Заменить случайным';

  @override
  String get chooseRecipe => 'Выбрать рецепт';

  @override
  String get regenerateButton => 'Новое меню\n(удерживать)';

  @override
  String get addRecipesForWeeklyMenu =>
      'Добавьте рецепты, чтобы составить меню на неделю';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get noDish => 'Без блюда';

  @override
  String get clear => 'Очистить';

  @override
  String doneCount(int count) {
    return 'Готово ($count)';
  }

  @override
  String get noIngredientsInRecipes => 'В выбранных рецептах нет ингредиентов';

  @override
  String boughtProgress(int bought, int total) {
    return 'Куплено $bought из $total';
  }

  @override
  String get allBought => 'Всё куплено!';

  @override
  String boughtSection(int count) {
    return 'Куплено ($count)';
  }

  @override
  String get reset => 'Сбросить';

  @override
  String get menuDeleted => 'Меню удалено';

  @override
  String menuLimitReached(int max) {
    return 'Можно сохранить не больше $max меню. Удалите одно из сохранённых, чтобы создать новое.';
  }

  @override
  String savedCount(int count, int max) {
    return 'Сохранено $count из $max';
  }

  @override
  String get newMenu => 'Новое меню';

  @override
  String menuLimitHint(int max) {
    return 'Достигнут лимит в $max меню. Чтобы создать новое, удалите одно из сохранённых.';
  }

  @override
  String get noDishes => 'Нет блюд';

  @override
  String get deleteMenu => 'Удалить меню';

  @override
  String noSpecialMenus(int max) {
    return 'Пока нет праздничных меню.\nМожно сохранить до $max меню — нажмите «Новое меню», чтобы начать.';
  }

  @override
  String get deleteMenuQuestion => 'Удалить меню?';

  @override
  String deleteMenuContent(String name) {
    return '«$name» и его список продуктов будут удалены.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get dishesForMenu => 'Блюда для меню';

  @override
  String dishRemoved(String title) {
    return '«$title» убрано из меню';
  }

  @override
  String get addDishesForGroceries =>
      'Добавьте блюда в меню, и здесь появится список продуктов';

  @override
  String get addDishes => 'Добавить блюда';

  @override
  String get menuName => 'Название меню';

  @override
  String get menuNameHint => 'Например, Новый год';

  @override
  String get addRecipesFirst => 'Сначала добавьте рецепты на главном экране';

  @override
  String get addDishesEmptyHint =>
      'Нажмите «Добавить блюда» и найдите нужные рецепты по названию';

  @override
  String get removeFromMenu => 'Убрать из меню';

  @override
  String get untitled => 'Без названия';

  @override
  String dishCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count блюда',
      many: '$count блюд',
      few: '$count блюда',
      one: '$count блюдо',
    );
    return '$_temp0';
  }

  @override
  String categoryName(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'breakfast': 'Завтраки',
      'soups': 'Супы',
      'mains': 'Основные блюда',
      'hot': 'Горячее',
      'salads': 'Салаты',
      'desserts': 'Десерты',
      'bakery': 'Выпечка',
      'drinks': 'Напитки',
      'snacks': 'Закуски',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'g': 'г',
      'kg': 'кг',
      'mg': 'мг',
      'ml': 'мл',
      'l': 'л',
      'tbsp': 'ст. л.',
      'tsp': 'ч. л.',
      'pcs': 'шт.',
      'cup': 'стакан',
      'clove': 'зубчик',
      'pinch': 'щепотка',
      'bunch': 'пучок',
      'can': 'банка',
      'pack': 'уп.',
      'sachet': 'пакетик',
      'slice': 'ломтик',
      'piece': 'кусочек',
      'wedge': 'долька',
      'sprig': 'веточка',
      'leaf': 'лист',
      'head': 'головка',
      'serving': 'порция',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String amountPhrase(String phrase) {
    String _temp0 = intl.Intl.selectLogic(phrase, {
      'toTaste': 'по вкусу',
      'optional': 'по желанию',
      'forServing': 'для подачи',
      'forFrying': 'для жарки',
      'knifeTip': 'на кончике ножа',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get byProducts => 'По продуктам';

  @override
  String get menuFromProducts => 'Меню из продуктов';

  @override
  String menuFromProductsHint(int max) {
    return 'Выберите до $max продуктов — в меню попадут все блюда, где есть хотя бы один из них';
  }

  @override
  String get searchByIngredient => 'Поиск по ингредиенту';

  @override
  String get addIngredient => 'Добавить';

  @override
  String ingredientsSelected(int count, int max) {
    return 'Выбрано $count из $max';
  }

  @override
  String ingredientLimitReached(int max) {
    return 'Можно выбрать не больше $max продуктов';
  }

  @override
  String get ingredientsNotFound => 'Таких ингредиентов нет в ваших рецептах';

  @override
  String createMenuWithDishes(String dishes) {
    return 'Готово · $dishes';
  }

  @override
  String dishesAddedToMenu(String dishes) {
    return 'Добавлено в меню: $dishes';
  }

  @override
  String get noDishesWithProducts => 'Нет блюд с выбранными продуктами';

  @override
  String get matchingDishesAlreadyInMenu => 'Все подходящие блюда уже в меню';

  @override
  String weeklyMenuFromProductsCreated(String dishes) {
    return 'Меню на неделю составлено из: $dishes';
  }

  @override
  String get replace => 'Заменить';

  @override
  String get replaceWeeklyMenuQuestion => 'Заменить меню на неделю?';

  @override
  String replaceWeeklyMenuContent(String dishes) {
    return 'Текущая неделя будет заменена новым меню из блюд с выбранными продуктами (подходит: $dishes). Отметки в списке продуктов сбросятся.';
  }
}
