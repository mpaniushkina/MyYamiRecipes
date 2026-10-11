import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.cookingTimeMinutes,
  });

  // Фабрика для парсинга JSON (аналог fromJson в Kotlin)
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      // В DummyJSON нет описания в списке, соберем солянку из ингредиентов или кухни для примера
      description: 'Кухня: ${json['cuisine'] ?? 'Общая'}. Калории: ${json['caloriesPerServing'] ?? 0} ккал.',
      imageUrl: json['image'] ?? '',
      cookingTimeMinutes: json['prepTimeMinutes'] != null
          ? (json['prepTimeMinutes'] as num).toInt()
          : 20,
    );
  }
}