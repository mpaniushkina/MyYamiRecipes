import 'entities/recipe.dart';

/// Splits a free-form ingredient line into product name, amount and unit.
///
/// Supported shapes:
///   "Творог 5% — 400 г", "Сахар: 2 ст. л.", "Мука 1,5 стакана",
///   "2 яйца", "200 г сыра", "Мука (2 стакана)", "Соль по вкусу".
/// If nothing matches, the whole line becomes the name with empty amount/unit.
class IngredientParser {
  IngredientParser._();

  /// Unit spellings (regex) → normalized (stored) unit. Order matters: longer/more
  /// specific forms first ("кг" before "г", "ст. л." before "стакан").
  /// English spellings are accepted too (the edit form shows localized units),
  /// but the stored unit is always the Russian one.
  static const List<(String, String)> _units = [
    (r'кг\.?|килограмм[а-яё]*|kg|kilograms?', 'кг'),
    (r'мг\.?|миллиграмм[а-яё]*|mg|milligrams?', 'мг'),
    (r'грамм[а-яё]*|гр\.?|г\.?|grams?|gr|g', 'г'),
    (r'мл\.?|миллилитр[а-яё]*|ml|millilit(?:er|re)s?', 'мл'),
    (r'литр[а-яё]*|л\.?|lit(?:er|re)s?|l', 'л'),
    (r'ст\.?\s*л\.?|столов[а-яё]*\s+ложк[а-яё]*|tbsp|tablespoons?', 'ст. л.'),
    (r'ч\.?\s*л\.?|чайн[а-яё]*\s+ложк[а-яё]*|tsp|teaspoons?', 'ч. л.'),
    (r'стакан[а-яё]*|стак\.?|cups?', 'стакан'),
    (r'штук[а-яё]*|шт\.?|pcs', 'шт.'),
    (r'зубч[а-яё]*|зуб\.?|cloves?', 'зубчик'),
    (r'щепот[а-яё]*|pinch(?:es)?', 'щепотка'),
    (r'пуч[а-яё]*|bunch(?:es)?', 'пучок'),
    (r'банк[а-яё]*|банок|cans?', 'банка'),
    (r'упаковк[а-яё]*|упак\.?|уп\.|packs?', 'уп.'),
    (r'пакетик[а-яё]*|пакет[а-яё]*|sachets?', 'пакетик'),
    (r'ломтик[а-яё]*|ломт[а-яё]*|slices?', 'ломтик'),
    (r'кусоч[а-яё]*|кус\.?|pieces?', 'кусочек'),
    (r'дольк[а-яё]*|долек|wedges?', 'долька'),
    (r'веточ[а-яё]*|веток|sprigs?', 'веточка'),
    (r'лист[а-яё]*|leaf|leaves', 'лист'),
    (r'головк[а-яё]*|голов[а-яё]*|heads?', 'головка'),
    (r'порци[а-яё]*|порц\.?|servings?', 'порция'),
  ];

  /// Non-numeric amounts: spelling → stored (Russian) phrase.
  static const Map<String, String> _phrases = {
    'по вкусу': 'по вкусу',
    'по желанию': 'по желанию',
    'для подачи': 'для подачи',
    'для жарки': 'для жарки',
    'на кончике ножа': 'на кончике ножа',
    'to taste': 'по вкусу',
    'optional': 'по желанию',
    'for serving': 'для подачи',
    'for frying': 'для жарки',
    'a pinch': 'на кончике ножа',
  };

  static final String _phraseAlternatives = _phrases.keys.join('|');

  /// "400", "1,5", "1/2", "2-3", "½".
  static const String _amount =
      r'(?:\d+(?:[.,]\d+)?(?:\s*/\s*\d+)?(?:\s*[-–]\s*\d+(?:[.,]\d+)?)?|[½¼¾⅓⅔])';

  static final String _unit = _units.map((u) => u.$1).join('|');

  /// Unit must not be followed by a letter: "2 груши" is not "2 г".
  static const String _unitEnd = r'(?![а-яёa-z])';

  static final RegExp _quantityOnly = RegExp(
    '^($_amount)?\\s*($_unit)?$_unitEnd\\.?\$',
    caseSensitive: false,
  );

  static final RegExp _toTaste = RegExp(
    '^(?:$_phraseAlternatives)\$',
    caseSensitive: false,
  );

  /// "Name — quantity", "Name - quantity", "Name: quantity".
  static final RegExp _separator = RegExp(r'\s+[—–-]\s+|\s*[—–]\s*|\s*:\s*');

  /// "Name (quantity)".
  static final RegExp _parens = RegExp(r'^(.+?)\s*\(([^()]+)\)\.?$');

  /// "Name quantity" at the end of the line.
  static final RegExp _trailing = RegExp(
    '^(.+?)[\\s,]+($_amount)\\s*($_unit)?$_unitEnd\\.?\$',
    caseSensitive: false,
  );

  /// "quantity Name" at the start of the line.
  static final RegExp _leading = RegExp(
    '^($_amount)\\s*(?:($_unit)$_unitEnd\\.?)?\\s+(.+)\$',
    caseSensitive: false,
  );

  static final RegExp _toTasteSuffix = RegExp(
    '^(.+?)[\\s,—–-]+($_phraseAlternatives)\\.?\$',
    caseSensitive: false,
  );

  static final RegExp _leadingSymbols = RegExp(r'^[^\p{L}\p{N}½¼¾⅓⅔]+', unicode: true);

  static IngredientEntity parse(String raw) {
    final line = raw.replaceFirst(_leadingSymbols, '').replaceAll(RegExp(r'[;,]+$'), '').trim();
    if (line.isEmpty) return IngredientEntity(name: raw.trim(), amount: '', unit: '');

    // 1. "Творог 5% — 400 г" / "Сахар: 2 ст. л." / "Соль — по вкусу".
    for (final match in _separator.allMatches(line)) {
      final name = line.substring(0, match.start);
      final quantity = _parseQuantity(line.substring(match.end));
      if (name.trim().isNotEmpty && quantity != null) return _build(name, quantity);
    }

    // 2. "Мука (2 стакана)".
    final parens = _parens.firstMatch(line);
    if (parens != null) {
      final quantity = _parseQuantity(parens.group(2)!);
      if (quantity != null) return _build(parens.group(1)!, quantity);
    }

    // 3. "Мука 1,5 стакана", "Яйцо 2 шт.".
    final trailing = _trailing.firstMatch(line);
    if (trailing != null) {
      return _build(trailing.group(1)!, (trailing.group(2)!, _normalizeUnit(trailing.group(3))));
    }

    // 4. "2 яйца", "200 г сыра".
    final leading = _leading.firstMatch(line);
    if (leading != null) {
      return _build(leading.group(3)!, (leading.group(1)!, _normalizeUnit(leading.group(2))));
    }

    // 5. "Соль по вкусу".
    final toTaste = _toTasteSuffix.firstMatch(line);
    if (toTaste != null) {
      return _build(toTaste.group(1)!, (_storedPhrase(toTaste.group(2)!), ''));
    }

    return IngredientEntity(name: _capitalize(line), amount: '', unit: '');
  }

  /// Parses a string that must be a quantity only: "400 г", "2", "стакан", "по вкусу".
  static (String, String)? _parseQuantity(String text) {
    final s = text.trim();
    if (s.isEmpty) return null;
    if (_toTaste.hasMatch(s)) return (_storedPhrase(s), '');

    final match = _quantityOnly.firstMatch(s);
    if (match == null) return null;
    final amount = match.group(1);
    final unit = match.group(2);
    if (amount == null && unit == null) return null;
    // "Мука — стакан" means one unit.
    return (amount ?? '1', _normalizeUnit(unit));
  }

  static String _storedPhrase(String phrase) =>
      _phrases[phrase.trim().toLowerCase()] ?? phrase.trim().toLowerCase();

  static String _normalizeUnit(String? unit) {
    if (unit == null || unit.trim().isEmpty) return '';
    final u = unit.trim().toLowerCase();
    for (final (pattern, normalized) in _units) {
      if (RegExp('^(?:$pattern)\$', caseSensitive: false).hasMatch(u)) return normalized;
    }
    return u;
  }

  static IngredientEntity _build(String name, (String, String) quantity) {
    final cleanName = name.trim().replaceAll(RegExp(r'[\s,:—–-]+$'), '').trim();
    return IngredientEntity(
      name: _capitalize(cleanName),
      amount: _normalizeAmount(quantity.$1),
      unit: quantity.$2,
    );
  }

  /// Unicode fractions → "1/2" so the shopping list can sum them; tidy spaces.
  static String _normalizeAmount(String amount) {
    const fractions = {'½': '1/2', '¼': '1/4', '¾': '3/4', '⅓': '1/3', '⅔': '2/3'};
    var a = amount.trim();
    fractions.forEach((k, v) => a = a.replaceAll(k, v));
    return a.replaceAll(RegExp(r'\s*/\s*'), '/').replaceAll(RegExp(r'\s*[-–]\s*'), '-');
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
