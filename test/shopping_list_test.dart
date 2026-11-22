import 'package:flutter_test/flutter_test.dart';
import 'package:my_yami_recipes/feature/menu/domain/shopping_list.dart';
import 'package:my_yami_recipes/feature/recipes/domain/entities/recipe.dart';

Recipe _recipe(List<IngredientEntity> ingredients) => Recipe(
      id: '1',
      title: 't',
      description: '',
      imageUrl: '',
      cookingTimeMinutes: 0,
      category: '',
      calories: 0,
      ingredients: ingredients,
      steps: const [],
    );

IngredientEntity _ing(String name, String amount, String unit) =>
    IngredientEntity(name: name, amount: amount, unit: unit);

void main() {
  test('toBaseUnit converts kg/mg to g and l to ml', () {
    expect(toBaseUnit('1', 'кг'), ('1000', 'г'));
    expect(toBaseUnit('0,3', 'кг'), ('300', 'г'));
    expect(toBaseUnit('1/2', 'л'), ('500', 'мл'));
    expect(toBaseUnit('1,5', 'л'), ('1500', 'мл'));
    expect(toBaseUnit('1-2', 'кг'), ('1000-2000', 'г'));
    expect(toBaseUnit('500', 'мг'), ('0.5', 'г'));
    expect(toBaseUnit('2', 'ст. л.'), ('2', 'ст. л.'));
  });

  test('different units of one product are merged', () {
    final items = buildShoppingList([
      _recipe([_ing('Мука', '1', 'кг'), _ing('Молоко', '0,5', 'л')]),
      _recipe([_ing('мука', '500', 'г'), _ing('Молоко', '200', 'мл')]),
    ]);
    expect(items.map((i) => '${i.name}: ${i.amountLabel}'), [
      'Молоко: 700 мл',
      'Мука: 1500 г',
    ]);
  });
}
