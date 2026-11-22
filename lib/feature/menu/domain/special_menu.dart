import '../../recipes/domain/entities/recipe.dart';

/// A saved special-occasion (holiday) menu. Only recipe ids are stored.
class SpecialMenu {
  final String id;
  final String name;

  /// Selected recipe ids in the order they were added.
  final List<String> recipeIds;
  final Set<String> checkedProducts;

  const SpecialMenu({
    required this.id,
    required this.name,
    required this.recipeIds,
    required this.checkedProducts,
  });

  factory SpecialMenu.empty() => SpecialMenu(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: '',
        recipeIds: const [],
        checkedProducts: const {},
      );

  bool get isEmpty => name.trim().isEmpty && recipeIds.isEmpty;

  String get displayName => name.trim().isEmpty ? 'Без названия' : name.trim();

  /// Resolves ids against current recipes; deleted recipes are skipped.
  List<Recipe> resolveRecipes(Map<String, Recipe> recipesById) =>
      recipeIds.map((id) => recipesById[id]).whereType<Recipe>().toList();

  SpecialMenu copyWith({
    String? name,
    List<String>? recipeIds,
    Set<String>? checkedProducts,
  }) {
    return SpecialMenu(
      id: id,
      name: name ?? this.name,
      recipeIds: recipeIds ?? this.recipeIds,
      checkedProducts: checkedProducts ?? this.checkedProducts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'recipeIds': recipeIds,
        'checked': checkedProducts.toList(),
      };

  factory SpecialMenu.fromJson(Map<String, dynamic> json) => SpecialMenu(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: json['name'] as String? ?? '',
        recipeIds: (json['recipeIds'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        checkedProducts: (json['checked'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toSet(),
      );
}

/// Russian plural: 1 блюдо, 2 блюда, 5 блюд.
String dishCountLabel(int n) {
  final mod10 = n % 10, mod100 = n % 100;
  final word = (mod10 == 1 && mod100 != 11)
      ? 'блюдо'
      : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
          ? 'блюда'
          : 'блюд';
  return '$n $word';
}
