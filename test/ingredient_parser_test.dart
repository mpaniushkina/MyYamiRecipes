import 'package:flutter_test/flutter_test.dart';
import 'package:my_yami_recipes/feature/recipes/domain/ingredient_parser.dart';

void main() {
  void check(String line, String name, String amount, String unit) {
    final i = IngredientParser.parse(line);
    expect([i.name, i.amount, i.unit], [name, amount, unit], reason: line);
  }

  test('separator forms', () {
    check('Творог 5% — 400 г', 'Творог 5%', '400', 'г');
    check('Яйцо — 1 шт.', 'Яйцо', '1', 'шт.');
    check('Сахар: 2 ст. л.', 'Сахар', '2', 'ст. л.');
    check('Яйца - 2', 'Яйца', '2', '');
    check('Соль, перец — по вкусу', 'Соль, перец', 'по вкусу', '');
    check('Мука — стакан', 'Мука', '1', 'стакан');
  });

  test('quantity at the end', () {
    check('Сахар 2 ст. л.', 'Сахар', '2', 'ст. л.');
    check('Мука 1,5 стакана', 'Мука', '1,5', 'стакан');
    check('Молоко 100 мл', 'Молоко', '100', 'мл');
    check('Чеснок 2-3 зубчика', 'Чеснок', '2-3', 'зубчик');
    check('Масло сливочное 50гр', 'Масло сливочное', '50', 'г');
    check('Сода ½ ч.л.', 'Сода', '1/2', 'ч. л.');
    check('Картофель 1 кг', 'Картофель', '1', 'кг');
  });

  test('quantity at the start', () {
    check('2 яйца', 'Яйца', '2', '');
    check('200 г сыра', 'Сыра', '200', 'г');
    check('2 груши', 'Груши', '2', '');
    check('3 столовые ложки сметаны', 'Сметаны', '3', 'ст. л.');
  });

  test('parentheses, to taste, bullets and plain names', () {
    check('Мука (2 стакана)', 'Мука', '2', 'стакан');
    check('Соль по вкусу', 'Соль', 'по вкусу', '');
    check('• Ваниль', 'Ваниль', '', '');
    check('Соль, перец', 'Соль, перец', '', '');
    check('Иван-чай', 'Иван-чай', '', '');
  });

  test('English spellings are stored as Russian units', () {
    check('Flour — 400 g', 'Flour', '400', 'г');
    check('Milk — 1,5 l', 'Milk', '1,5', 'л');
    check('Sugar — 2 tbsp', 'Sugar', '2', 'ст. л.');
    check('Garlic 3 cloves', 'Garlic', '3', 'зубчик');
    check('Salt — to taste', 'Salt', 'по вкусу', '');
    check('2 cups flour', 'Flour', '2', 'стакан');
    check('2 garlic', 'Garlic', '2', '');
    check('Bay — 2 leaves', 'Bay', '2', 'лист');
  });

  test('displayText round-trips', () {
    for (final line in ['Творог 5% — 400 г', 'Соль — по вкусу', 'Ваниль', 'Чеснок — 2-3 зубчик']) {
      final first = IngredientParser.parse(line);
      final second = IngredientParser.parse(first.displayText);
      expect([second.name, second.amount, second.unit], [first.name, first.amount, first.unit],
          reason: line);
    }
  });
}
