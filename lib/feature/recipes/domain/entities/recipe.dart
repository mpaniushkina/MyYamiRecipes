class Recipe {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final int? cookingTimeMinutes;
  final String? category;
  final int? calories;
  final List<IngredientEntity> ingredients;
  final List<String>? steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookingTimeMinutes,
    required this.category,
    required this.calories,
    required this.ingredients,
    required this.steps,
  });
}

class IngredientEntity {
  /// Product name only, e.g. "Творог 5%".
  final String name;

  /// Quantity as written: "400", "1,5", "1/2", "2-3", "по вкусу". Empty if unknown.
  final String amount;

  /// Normalized unit: "г", "мл", "ст. л.", "шт."... Empty if none.
  final String unit;

  const IngredientEntity({
    required this.name,
    required this.amount,
    required this.unit,
  });

  /// "400 г", "2", "по вкусу" or empty.
  String get quantityLabel => [amount, unit].where((e) => e.isNotEmpty).join(' ');

  /// One-line text used in the edit form and detail screen: "Творог 5% — 400 г".
  /// [IngredientParser.parse] turns it back into the same entity.
  String get displayText => quantityLabel.isEmpty ? name : '$name — $quantityLabel';
}
