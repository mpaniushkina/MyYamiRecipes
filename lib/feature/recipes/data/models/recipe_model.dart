import '../../domain/entities/recipe.dart';

class IngredientModel {
  final String? name;
  final String? amount;
  final String? unit;

  const IngredientModel({
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] as String?,
      amount: json['amount'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'unit': unit,
  };

  IngredientEntity toEntity() {
    return IngredientEntity(name: name.toString(), amount: amount.toString(), unit: unit.toString());
  }

  factory IngredientModel.fromEntity(IngredientEntity entity) {
    return IngredientModel(
      name: entity.name,
      amount: entity.amount,
      unit: entity.unit,
    );
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final int? cookingTimeMinutes;
  final String? category;
  final int? calories;
  final List<IngredientModel> ingredients;
  final List<String>? steps;

  const RecipeModel({
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

  // Создание модели из JSON
  factory RecipeModel.fromJson(Map<String, dynamic> json, {String? id, String? imageUrl}) {
    return RecipeModel(
      id: id ?? json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: imageUrl ?? json['imageUrl'] as String?,
      cookingTimeMinutes: json['prepTimeMinutes'] != null
          ? (json['prepTimeMinutes'] as num).toInt() : 20,
      category: json['category'] as String?,
      calories: json['calories'] != null
          ? (json['calories'] as num).toInt() : 0,
      ingredients: (json['ingredients'] as List<dynamic>?)
          !.map((item) => IngredientModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'cookingTimeMinutes': cookingTimeMinutes,
    'category': category,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'steps': steps,
  };

  Recipe toEntity() {
    return Recipe(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      cookingTimeMinutes: cookingTimeMinutes,
      category: category,
      calories: calories,
      ingredients: ingredients.map((i) => i.toEntity()).toList(),
      steps: steps,
    );
  }

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      title: entity.title,
      ingredients: entity.ingredients.map((e) => IngredientModel.fromEntity(e)).toList(),
      steps: entity.steps,
      description: entity.description,
      imageUrl: entity.imageUrl,
      cookingTimeMinutes: entity.cookingTimeMinutes,
      category: entity.category,
      calories: entity.calories,
    );
  }
}