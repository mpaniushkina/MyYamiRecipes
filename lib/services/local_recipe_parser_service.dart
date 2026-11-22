import '../feature/recipes/domain/entities/recipe.dart';
import '../feature/recipes/domain/ingredient_parser.dart';

class RecipeEntity {
  final String title;
  final List<String> ingredients;
  final List<String> steps;

  RecipeEntity({
    required this.title,
    required this.ingredients,
    required this.steps,
  });
}

/// Parses free-form recipe text (e.g. copied from a website) into a [Recipe].
///
/// Sections are detected by headers like «Ингредиенты» / «Приготовление».
/// Without headers, ingredient lines are guessed by amounts/units, bullets and
/// short list-like lines. Nothing is silently dropped: unrecognized lines go to
/// the description, and if no ingredients are recognized at all, the whole
/// text is put into the ingredients field so the user can fix it manually.
class LocalRecipeParserService {
  static const _ingredientHeaders = [
    'ингредиент',
    'состав',
    'продукты',
    'вам понадобится',
    'нам понадобится',
    'понадобится',
    'что нужно',
  ];

  static const _stepsHeaders = [
    'приготовление',
    'способ приготовления',
    'как приготовить',
    'рецепт приготовления',
    'пошагов',
    'шаги',
    'инструкция',
  ];

  /// Amount + unit, e.g. "200 г", "0,5 ч. л.", "1/2 стакана", "2-3 зубчика".
  static final _amountWithUnit = RegExp(
    r'(\d+([.,/]\d+)?|[½¼¾⅓⅔])\s*(-\s*\d+\s*)?'
    r'(г(?![а-яё])|гр|кг|мг|мл|л(?![а-яё])|ст\.?\s*л|ч\.?\s*л|стак|шт|зуб|щеп|пуч|бан|упак|лом|кус|дол|вет|лист|голов|порц)',
    caseSensitive: false,
  );

  /// "Яйца — 2", "Соль - 1".
  static final _dashAmount = RegExp(r'[—–-]\s*(\d|[½¼¾⅓⅔])');

  /// Line starting with a number followed by a word: "2 яйца".
  static final _leadingCount = RegExp(r'^(\d+([.,/]\d+)?|[½¼¾⅓⅔])\s+[а-яёa-z]', caseSensitive: false);

  static final _toTaste = RegExp(r'по вкусу|щепотк|для подачи|по желанию', caseSensitive: false);

  /// Leading bullets, dashes, emoji etc.
  static final _leadingSymbols = RegExp(r'^[^\p{L}\p{N}]+', unicode: true);

  static final _url = RegExp(r'^(https?://|www\.)\S+$', caseSensitive: false);

  static Recipe? parse(String rawText) {
    final lines = rawText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) return _recipe(title: '', ingredients: [], steps: [], description: '');

    // The first line is the title unless it is already a section header.
    var start = 0;
    var title = '';
    if (_header(lines.first) == null && lines.first.length <= 100) {
      title = lines.first;
      start = 1;
    }

    final intro = <String>[];
    final ingredients = <String>[];
    final steps = <String>[];
    _Section section = _Section.none;
    var previousWasIngredient = false;

    for (final line in lines.skip(start)) {
      final header = _header(line);
      if (header != null) {
        section = header.section;
        previousWasIngredient = false;
        // "Ингредиенты: мука, сахар" — keep the text after the colon.
        if (header.rest.isNotEmpty) {
          (section == _Section.ingredients ? ingredients : steps).add(header.rest);
        }
        continue;
      }
      if (_url.hasMatch(line)) continue;

      switch (section) {
        case _Section.ingredients:
          // Skip sub-headers like "Для теста:", keep everything else.
          if (line.endsWith(':') && !line.contains(RegExp(r'\d'))) continue;
          ingredients.add(_clean(line));
        case _Section.steps:
          steps.add(line);
        case _Section.none:
          if (_looksLikeIngredient(line, previousWasIngredient)) {
            ingredients.add(_clean(line));
            previousWasIngredient = true;
          } else {
            (ingredients.isEmpty ? intro : steps).add(line);
            previousWasIngredient = false;
          }
      }
    }

    // Fallback: nothing recognized — keep the whole text in the ingredients field.
    if (ingredients.isEmpty) {
      return _recipe(
        title: title,
        ingredients: lines.skip(start).toList(),
        steps: const [],
        description: '',
      );
    }

    return _recipe(
      title: title,
      ingredients: ingredients,
      steps: steps,
      description: [...intro, ...steps].join('\n'),
    );
  }

  static bool _looksLikeIngredient(String line, bool previousWasIngredient) {
    if (_amountWithUnit.hasMatch(line) || _dashAmount.hasMatch(line) || _toTaste.hasMatch(line)) {
      return true;
    }
    final isShort = line.length <= 40 && !line.endsWith('.');
    // Bulleted short lines ("- мука", "• соль") are list items, i.e. ingredients.
    if (isShort && RegExp(r'^[-–—•*·▪]').hasMatch(line)) return true;
    if (isShort && _leadingCount.hasMatch(line)) return true;
    // A short line right after an ingredient is most likely the next ingredient.
    return isShort && previousWasIngredient;
  }

  static ({_Section section, String rest})? _header(String line) {
    if (line.length > 50) return null;
    final normalized = line.replaceFirst(_leadingSymbols, '').toLowerCase();
    final colon = line.indexOf(':');
    final rest = colon == -1 ? '' : line.substring(colon + 1).trim();

    if (_ingredientHeaders.any(normalized.startsWith)) {
      return (section: _Section.ingredients, rest: rest);
    }
    if (_stepsHeaders.any(normalized.startsWith)) {
      return (section: _Section.steps, rest: rest);
    }
    return null;
  }

  static String _clean(String line) {
    final cleaned = line.replaceFirst(_leadingSymbols, '').trim();
    return cleaned.isEmpty ? line : cleaned;
  }

  static Recipe _recipe({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    required String description,
  }) {
    return Recipe(
      id: '',
      title: title,
      description: description,
      imageUrl: '',
      cookingTimeMinutes: 10,
      category: '',
      calories: 0,
      ingredients: ingredients
          .map(IngredientParser.parse)
          .toList(),
      steps: steps,
    );
  }
}

enum _Section { none, ingredients, steps }
