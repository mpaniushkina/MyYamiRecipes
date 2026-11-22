import 'package:flutter/widgets.dart';

import '../feature/menu/domain/weekly_menu.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

/// Russian is used only when the device language is Russian; English otherwise.
Locale resolveAppLocale(List<Locale>? deviceLocales, Iterable<Locale> supported) {
  final isRussian = deviceLocales?.any((l) => l.languageCode == 'ru') ?? false;
  return isRussian ? const Locale('ru') : const Locale('en');
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Recipe data (categories, units, "по вкусу") is stored in Russian, so stored
// values stay stable across locales. The maps below translate them for display.

/// Stored category → id used by the `categoryName` ARB select.
const Map<String, String> _categoryIds = {
  'Завтраки': 'breakfast',
  'Супы': 'soups',
  'Основные блюда': 'mains',
  'Салаты': 'salads',
  'Десерты': 'desserts',
  'Выпечка': 'bakery',
  'Напитки': 'drinks',
  'Закуски': 'snacks',
  'Другое': 'other',
};

/// Normalized unit (see IngredientParser) → id used by the `unitName` ARB select.
const Map<String, String> _unitIds = {
  'г': 'g',
  'кг': 'kg',
  'мг': 'mg',
  'мл': 'ml',
  'л': 'l',
  'ст. л.': 'tbsp',
  'ч. л.': 'tsp',
  'шт.': 'pcs',
  'стакан': 'cup',
  'зубчик': 'clove',
  'щепотка': 'pinch',
  'пучок': 'bunch',
  'банка': 'can',
  'уп.': 'pack',
  'пакетик': 'sachet',
  'ломтик': 'slice',
  'кусочек': 'piece',
  'долька': 'wedge',
  'веточка': 'sprig',
  'лист': 'leaf',
  'головка': 'head',
  'порция': 'serving',
};

/// Non-numeric amount → id used by the `amountPhrase` ARB select.
const Map<String, String> _amountPhraseIds = {
  'по вкусу': 'toTaste',
  'по желанию': 'optional',
  'для подачи': 'forServing',
  'для жарки': 'forFrying',
  'на кончике ножа': 'knifeTip',
};

extension AppLocalizationsX on AppLocalizations {
  /// Display name of a stored category; unknown/custom categories are shown as is.
  String categoryLabel(String? stored) {
    if (stored == null || stored.isEmpty) return categoryName('other');
    final id = _categoryIds[stored];
    return id == null ? stored : categoryName(id);
  }

  String unitLabel(String stored) {
    final id = _unitIds[stored.trim().toLowerCase()];
    return id == null ? stored : unitName(id);
  }

  /// Translates known phrases ("по вкусу") inside an amount; numbers are kept.
  String amountLabel(String stored) {
    var result = stored;
    _amountPhraseIds.forEach((phrase, id) {
      result = result.replaceAll(phrase, amountPhrase(id));
    });
    return result;
  }

  /// "400 g", "to taste", "2" — empty when both parts are empty.
  String quantity(String amountText, String unitText) =>
      [amountLabel(amountText.trim()), unitLabel(unitText.trim())].where((e) => e.isNotEmpty).join(' ');

  String mealTitle(MealType type) => switch (type) {
        MealType.breakfast => breakfast,
        MealType.lunch => lunch,
        MealType.dinner => dinner,
      };

  /// [index] 0 = Monday.
  String weekDay(int index) => [
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
        saturday,
        sunday,
      ][index];
}
