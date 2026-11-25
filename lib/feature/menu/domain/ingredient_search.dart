import '../../recipes/domain/entities/recipe.dart';
import '../../recipes/domain/ingredient_parser.dart';

/// Max number of ingredients the user can pick when building a menu from products.
const int maxMenuIngredients = 10;

/// Lowercases, trims, collapses spaces and treats "ё" as "е" so that
/// "Свёкла" and "свекла " match.
String normalizeIngredient(String value) =>
    value.trim().toLowerCase().replaceAll('ё', 'е').replaceAll(RegExp(r'\s+'), ' ');

/// Reduces an ingredient name to the bare product name for picking:
/// no amount/unit, no parentheses, no numbers/percentages, no symbols.
///   "Творог 5% — 400 г" → "Творог", "Мука (пшеничная) в/с" → "Мука",
///   "Сыр твердый, тертый" → "Сыр твердый", "- яйца С1" → "Яйца".
String ingredientKeyword(String raw) {
  // Strips the quantity if the name still holds one (e.g. legacy data).
  var s = IngredientParser.parse(raw).name;
  s = s.replaceAll(RegExp(r'\([^)]*\)?'), ' ');
  // Tokens like "в/с" are abbreviations, not product words.
  s = s.replaceAll(RegExp(r'\S*/\S*'), ' ');
  // Everything after a number, comma or separator is a detail ("20%", ", тертый").
  s = s.split(RegExp(r'[\d,;:—–]|\s-\s')).first;
  final words = s
      .replaceAll(RegExp(r'[^\p{L}\s-]', unicode: true), ' ')
      .split(RegExp(r'\s+'))
      .map((w) => w.replaceAll(RegExp(r'^-+|-+$'), ''))
      .where((w) => w.length > 1)
      .toList();
  if (words.isEmpty) return '';
  final result = words.join(' ').toLowerCase();
  return result[0].toUpperCase() + result.substring(1);
}

/// Unique bare product names (see [ingredientKeyword]) across [recipes], sorted alphabetically.
List<String> allIngredientNames(Iterable<Recipe> recipes) {
  final byKey = <String, String>{};
  for (final recipe in recipes) {
    for (final ingredient in recipe.ingredients) {
      final name = ingredientKeyword(ingredient.name);
      if (name.isEmpty) continue;
      byKey.putIfAbsent(normalizeIngredient(name), () => name);
    }
  }
  final names = byKey.values.toList()
    ..sort((a, b) => normalizeIngredient(a).compareTo(normalizeIngredient(b)));
  return names;
}

/// Whether [recipe] has an ingredient whose name contains any of [ingredients]
/// (case-insensitive, so "сыр" also matches "Сыр пармезан").
bool recipeHasAnyIngredient(Recipe recipe, Iterable<String> ingredients) {
  final wanted = ingredients.map(normalizeIngredient).where((s) => s.isNotEmpty).toList();
  if (wanted.isEmpty) return false;
  return recipe.ingredients.any((i) {
    final name = normalizeIngredient(i.name);
    return wanted.any(name.contains);
  });
}

/// Recipes that contain at least one of [ingredients], in the original order.
List<Recipe> recipesWithAnyIngredient(Iterable<Recipe> recipes, Iterable<String> ingredients) {
  final wanted = ingredients.toList();
  return recipes.where((r) => recipeHasAnyIngredient(r, wanted)).toList();
}
