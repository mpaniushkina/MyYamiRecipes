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
  final String name;
  final String amount;
  final String unit;

  const IngredientEntity({
    required this.name,
    required this.amount,
    required this.unit,
  });
}