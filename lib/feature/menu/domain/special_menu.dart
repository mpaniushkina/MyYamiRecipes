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
