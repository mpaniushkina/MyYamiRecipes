import 'package:flutter_test/flutter_test.dart';
import 'package:my_yami_recipes/feature/menu/domain/ingredient_search.dart';
import 'package:my_yami_recipes/feature/recipes/domain/entities/recipe.dart';

Recipe _recipe(String id, List<String> ingredientNames) => Recipe(
      id: id,
      title: id,
      description: '',
      imageUrl: '',
      cookingTimeMinutes: 0,
      category: '',
      calories: 0,
      ingredients: [
        for (final n in ingredientNames) IngredientEntity(name: n, amount: '', unit: ''),
      ],
      steps: const [],
    );

void main() {
  final recipes = [
    _recipe('borsch', ['Свёкла', 'Картофель', 'Капуста']),
    _recipe('pasta', ['Спагетти', 'Сыр пармезан']),
    _recipe('salad', ['Огурец', 'помидор']),
  ];

  test('allIngredientNames is unique and sorted', () {
    final names = allIngredientNames([
      ...recipes,
      _recipe('x', ['картофель ', 'Свекла', '']),
    ]);
    expect(names, ['Капуста', 'Картофель', 'Огурец', 'Помидор', 'Свёкла', 'Спагетти', 'Сыр пармезан']);
  });

  test('ingredientKeyword keeps only the product name', () {
    expect(ingredientKeyword('Творог 5% — 400 г'), 'Творог');
    expect(ingredientKeyword('Творог 5%'), 'Творог');
    expect(ingredientKeyword('Мука (пшеничная) в/с'), 'Мука');
    expect(ingredientKeyword('Сыр твердый, тертый'), 'Сыр твердый');
    expect(ingredientKeyword('- яйца С1'), 'Яйца');
    expect(ingredientKeyword('Сметана 20% жирности'), 'Сметана');
    expect(ingredientKeyword('2 ст. л. сахара'), 'Сахара');
    expect(ingredientKeyword('Соль по вкусу'), 'Соль');
    expect(ingredientKeyword('Чили-перец'), 'Чили-перец');
    expect(ingredientKeyword('*** 100'), '');
  });

  test('allIngredientNames strips amounts and dedupes', () {
    final names = allIngredientNames([
      _recipe('a', ['Творог 5%', 'творог 9%', 'Мука (в/с)']),
      _recipe('b', ['Мука 200 г', 'Яйцо, 2 шт.']),
    ]);
    expect(names, ['Мука', 'Творог', 'Яйцо']);
  });

  test('recipes with at least one ingredient, substring and ё-insensitive', () {
    expect(recipesWithAnyIngredient(recipes, ['сыр']).map((r) => r.id), ['pasta']);
    expect(recipesWithAnyIngredient(recipes, ['свекла', 'Помидор']).map((r) => r.id), ['borsch', 'salad']);
    expect(recipesWithAnyIngredient(recipes, ['тыква']), isEmpty);
    expect(recipesWithAnyIngredient(recipes, ['  ']), isEmpty);
  });
}
