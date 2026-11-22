import 'package:flutter_test/flutter_test.dart';
import 'package:my_yami_recipes/services/local_recipe_parser_service.dart';

List<String> _names(String text) =>
    LocalRecipeParserService.parse(text)!.ingredients.map((e) => e.displayText).toList();

void main() {
  test('sections with headers: keeps every ingredient, incl. ones without units', () {
    const text = '''
Сырники
Ингредиенты:
- Творог 5% — 400 г
- Яйцо — 1 шт.
• Сахар 2 ст. л.
Соль по вкусу
Ваниль
Молочные продукты лучше брать свежие
Приготовление:
1. Смешайте творог с яйцом.
2. Обжарьте на сковороде. Рецепты на каждый день.
''';
    final recipe = LocalRecipeParserService.parse(text)!;
    expect(recipe.title, 'Сырники');
    expect(_names(text), [
      'Творог 5% — 400 г',
      'Яйцо — 1 шт.',
      'Сахар — 2 ст. л.',
      'Соль — по вкусу',
      'Ваниль',
      'Молочные продукты лучше брать свежие',
    ]);
    expect(recipe.steps, hasLength(2));
    expect(recipe.description, contains('Рецепты на каждый день'));
  });

  test('no headers: guesses ingredients, keeps short lines after them', () {
    const text = '''
Омлет
2 яйца
Молоко 100 мл
Соль, перец
Взбейте яйца с молоком и вылейте на разогретую сковороду, жарьте 5 минут.
''';
    expect(_names(text), ['Яйца — 2', 'Молоко — 100 мл', 'Соль, перец']);
    expect(
      LocalRecipeParserService.parse(text)!.description,
      startsWith('Взбейте яйца'),
    );
  });

  test('inline header and sub-headers', () {
    const text = '''
Пирог
Ингредиенты: мука, сахар
Для теста:
Масло 100 г
Приготовление: смешать и испечь.
''';
    expect(_names(text), ['Мука, сахар', 'Масло — 100 г']);
    expect(LocalRecipeParserService.parse(text)!.steps, ['смешать и испечь.']);
  });

  test('fallback: nothing recognized -> whole text goes to ingredients', () {
    const text = '''
Бабушкин суп
Берём всё, что есть в холодильнике, и варим примерно час на медленном огне.
Подаём горячим со сметаной и свежим хлебом, очень вкусно получается.
''';
    final recipe = LocalRecipeParserService.parse(text)!;
    expect(recipe.title, 'Бабушкин суп');
    expect(recipe.ingredients, hasLength(2));
    expect(recipe.ingredients.first.displayText, startsWith('Берём всё'));
  });
}
