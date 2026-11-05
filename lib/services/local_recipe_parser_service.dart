import '../feature/recipes/domain/entities/recipe.dart';

class RecipeEntity {
  final String title;
  final List<String> ingredients;
  final List<String> steps;

  RecipeEntity({
    required this.title,
    required this.ingredients,
    required this.steps,
  });
}

class LocalRecipeParserService {
  static Recipe? parse(String rawText) {
    // Очищаем текст от лишних пробелов и разбиваем по строкам
    final lines = rawText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return Recipe(title: 'Новый рецепт', ingredients: [], steps: [], id: '', description: '', imageUrl: '', cookingTimeMinutes: 10, category: '', calories: 0,);
    }

    String title = ""; // По умолчанию первая строка — название
    List<String> ingredients = [];
    List<String> steps = [];

    bool isIngredientsSection = false;
    bool isStepsSection = false;

    // Регулярка для поиска строк с граммовками/объемами (например: "Творог - 200 г", "Сахар 50г", "0.5 ч.л.")
    final ingredientRegExp = RegExp(r'(\d+[\.,]?\d*\s*(г|кг|мл|л|ст\.?\s*л\.?|ч\.?\s*л\.?|зубч\.|щепотк|шт|порц))', caseSensitive: false);

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String lowerLine = line.toLowerCase();

      // Улавливаем начало секций по ключевым словам
      if (lowerLine.contains('ингредиент') || lowerLine.contains('состав') || lowerLine.contains('продукты')) {
        isIngredientsSection = true;
        isStepsSection = false;
        continue;
      }
      if (lowerLine.contains('приготовление') || lowerLine.contains('как приготовить')  || lowerLine.contains('шаги')) {
        isIngredientsSection = false;
        isStepsSection = true;
        continue;
      }

      // Если строка похожа на ингредиент (содержит вес/объем или дефис с цифрой)
      if (ingredientRegExp.hasMatch(line) || (isIngredientsSection && !isStepsSection)) {
        if (!lowerLine.contains('каждый день') && !lowerLine.contains('меню')) { // фильтруем мусор с сайтов
          ingredients.add(line);
        }
      }
      // Если это шаги или текст идет после блока ингредиентов
      else if (isStepsSection || (i > 0 && ingredients.length > 2 && !ingredientRegExp.hasMatch(line))) {
        // Отсекаем явный мусор (адреса сайтов, рекламу)
        if (!lowerLine.contains('http') && !lowerLine.contains('.ru') && !lowerLine.contains('рецепты')) {
          steps.add(line);
        }
      }
    }

    return Recipe(
      title: title,
      ingredients: ingredients.map((line) {
        return IngredientEntity(
          name: line,
          amount: '',
          unit: '',
        );
      }).toList(),
      steps: steps,
      id: '',
      description: steps.isNotEmpty ? steps.join('\n') : '',
      imageUrl: '',
      cookingTimeMinutes: 10,
      category: '',
      calories: 0,
    );
  }
}