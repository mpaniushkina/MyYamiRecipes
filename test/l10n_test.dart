import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_yami_recipes/feature/menu/domain/weekly_menu.dart';
import 'package:my_yami_recipes/l10n/l10n_helpers.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ru = lookupAppLocalizations(const Locale('ru'));
  final supported = AppLocalizations.supportedLocales;

  test('Russian only when the primary device language is Russian', () {
    expect(resolveAppLocale([const Locale('ru', 'RU')], supported), const Locale('ru'));
    expect(resolveAppLocale([const Locale('en', 'US'), const Locale('ru', 'RU')], supported), const Locale('en'));
    expect(resolveAppLocale([const Locale('ru'), const Locale('en')], supported), const Locale('ru'));
    expect(resolveAppLocale([const Locale('de', 'DE')], supported), const Locale('en'));
    expect(resolveAppLocale([const Locale('uk')], supported), const Locale('en'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });

  test('stored categories are translated, custom ones kept', () {
    expect(en.categoryLabel('Основные блюда'), 'Main courses');
    expect(en.categoryLabel('Закуски'), 'Appetizers');
    expect(en.categoryLabel('Горячее'), 'Hot dishes');
    expect(ru.categoryLabel('Горячее'), 'Горячее');
    expect(en.categoryLabel(null), 'Other');
    expect(en.categoryLabel('Моя категория'), 'Моя категория');
    expect(ru.categoryLabel('Супы'), 'Супы');
  });

  test('units and amount phrases', () {
    expect(en.quantity('400', 'г'), '400 g');
    expect(en.quantity('2', 'ст. л.'), '2 tbsp');
    expect(en.quantity('по вкусу', ''), 'to taste');
    expect(en.quantity('по вкусу + 1', 'шт.'), 'to taste + 1 pcs');
    expect(ru.quantity('400', 'г'), '400 г');
    expect(en.quantity('', ''), '');
  });

  test('plurals, meals and week days', () {
    expect(en.dishCount(1), '1 dish');
    expect(en.dishCount(5), '5 dishes');
    expect(ru.dishCount(1), '1 блюдо');
    expect(ru.dishCount(3), '3 блюда');
    expect(ru.dishCount(5), '5 блюд');
    expect(ru.dishCount(21), '21 блюдо');
    expect(en.mealTitle(MealType.dinner), 'Dinner');
    expect(en.weekDay(0), 'Monday');
    expect(ru.weekDay(6), 'Воскресенье');
  });
}
