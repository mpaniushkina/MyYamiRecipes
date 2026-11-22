import '../../recipes/domain/entities/recipe.dart';

class ShoppingItem {
  final String name;
  final String unit;
  final double? amount;
  final List<String> rawAmounts;

  const ShoppingItem({
    required this.name,
    required this.unit,
    required this.amount,
    required this.rawAmounts,
  });

  /// Stable key used to persist the "bought" checkmark.
  String get key => shoppingKey(name, unit);

  String get amountLabel {
    if (amount != null) {
      final a = amount!;
      final text = a == a.roundToDouble()
          ? a.toInt().toString()
          : a.toStringAsFixed(1).replaceAll('.', ',');
      return unit.isEmpty ? text : '$text $unit';
    }
    final values = rawAmounts.where((e) => e.trim().isNotEmpty).toSet();
    if (values.isEmpty) return unit;
    return values.join(' + ') + (unit.isEmpty ? '' : ' $unit');
  }
}

String shoppingKey(String name, String unit) =>
    '${name.trim().toLowerCase()}|${unit.trim().toLowerCase()}';

/// Merges ingredients of all [recipes] into one alphabetical shopping list.
/// Weights are converted to grams and volumes to millilitres first, so
/// "Мука 1 кг" + "Мука 500 г" become one item "Мука 1500 г".
/// Items with the same name and unit are grouped; numeric amounts are summed.
List<ShoppingItem> buildShoppingList(Iterable<Recipe> recipes) {
  final grouped = <String, _Accumulator>{};

  for (final recipe in recipes) {
    for (final ing in recipe.ingredients) {
      final name = ing.name.trim();
      if (name.isEmpty) continue;
      final (amount, unit) = toBaseUnit(ing.amount.trim(), ing.unit.trim());
      grouped
          .putIfAbsent(shoppingKey(name, unit), () => _Accumulator(name, unit))
          .add(amount);
    }
  }

  return grouped.values.map((a) => a.toItem()).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

/// Unit → (base unit, multiplier).
const Map<String, (String, double)> _baseUnits = {
  'кг': ('г', 1000),
  'мг': ('г', 0.001),
  'л': ('мл', 1000),
};

final RegExp _range = RegExp(r'^(\d+(?:[.,]\d+)?)\s*-\s*(\d+(?:[.,]\d+)?)$');

/// Converts kg/mg → g and l → ml. Numbers, fractions ("1/2") and ranges
/// ("1-2") are converted; other amounts ("по вкусу") are kept as is.
(String, String) toBaseUnit(String amount, String unit) {
  final base = _baseUnits[unit.toLowerCase()];
  if (base == null) return (amount, unit);
  final (baseUnit, factor) = base;

  final value = _Accumulator._parseAmount(amount);
  if (value != null) return (_formatNumber(value * factor), baseUnit);

  final range = _range.firstMatch(amount);
  if (range != null) {
    final from = double.parse(range.group(1)!.replaceAll(',', '.')) * factor;
    final to = double.parse(range.group(2)!.replaceAll(',', '.')) * factor;
    return ('${_formatNumber(from)}-${_formatNumber(to)}', baseUnit);
  }
  return (amount, baseUnit);
}

/// "1500", "2.5"; rounds away float noise like 300.00000000000006.
String _formatNumber(double value) {
  final rounded = double.parse(value.toStringAsFixed(3));
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
}

class _Accumulator {
  final String name;
  final String unit;
  final List<String> raw = [];
  double sum = 0;
  bool allNumeric = true;

  _Accumulator(this.name, this.unit);

  void add(String amount) {
    raw.add(amount);
    final value = _parseAmount(amount);
    if (value == null) {
      allNumeric = false;
    } else {
      sum += value;
    }
  }

  ShoppingItem toItem() => ShoppingItem(
        name: name,
        unit: unit,
        amount: allNumeric && raw.isNotEmpty ? sum : null,
        rawAmounts: raw,
      );

  /// Parses "200", "0,5", "1.5" and simple fractions like "1/2".
  static double? _parseAmount(String input) {
    final s = input.trim().replaceAll(',', '.');
    if (s.isEmpty) return null;
    final fraction = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(s);
    if (fraction != null) {
      final d = double.parse(fraction.group(2)!);
      return d == 0 ? null : double.parse(fraction.group(1)!) / d;
    }
    return double.tryParse(s);
  }
}
