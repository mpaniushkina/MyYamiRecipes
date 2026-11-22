import 'dart:math';

import '../../recipes/domain/entities/recipe.dart';

enum MealType { breakfast, lunch, dinner }

extension MealTypeX on MealType {
  String get title => switch (this) {
        MealType.breakfast => 'Завтрак',
        MealType.lunch => 'Обед',
        MealType.dinner => 'Ужин',
      };

  /// Recipe categories suitable for this meal, in priority order.
  List<String> get preferredCategories => switch (this) {
        MealType.breakfast => const ['Завтраки', 'Выпечка'],
        MealType.lunch => const ['Супы', 'Основные блюда'],
        MealType.dinner => const ['Основные блюда', 'Салаты'],
      };
}

const List<String> weekDays = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

class DayMenu {
  final Map<MealType, Recipe?> meals;

  const DayMenu(this.meals);

  Recipe? operator [](MealType type) => meals[type];

  DayMenu copyWith(MealType type, Recipe? recipe) =>
      DayMenu({...meals, type: recipe});

  int get totalCalories =>
      meals.values.fold(0, (sum, r) => sum + (r?.calories ?? 0));
}

class WeeklyMenuGenerator {
  final Random _random;

  WeeklyMenuGenerator({Random? random}) : _random = random ?? Random();

  List<DayMenu> generate(List<Recipe> recipes) {
    final pools = {
      for (final type in MealType.values) type: _poolFor(type, recipes),
    };
    final queues = <MealType, List<Recipe>>{
      for (final type in MealType.values) type: [],
    };

    Recipe? next(MealType type) {
      final pool = pools[type]!;
      if (pool.isEmpty) return null;
      final queue = queues[type]!;
      // Shuffled queue so dishes repeat as rarely as possible.
      if (queue.isEmpty) queue.addAll(List.of(pool)..shuffle(_random));
      return queue.removeLast();
    }

    return List.generate(
      weekDays.length,
      (_) => DayMenu({for (final type in MealType.values) type: next(type)}),
    );
  }

  Recipe? randomFor(MealType type, List<Recipe> recipes, {Recipe? except}) {
    final pool = _poolFor(type, recipes).where((r) => r.id != except?.id).toList();
    if (pool.isEmpty) return except;
    return pool[_random.nextInt(pool.length)];
  }

  List<Recipe> _poolFor(MealType type, List<Recipe> recipes) {
    final matching = recipes
        .where((r) => type.preferredCategories.contains(r.category))
        .toList();
    if (matching.isNotEmpty) return matching;
    // No matching categories: use everything except drinks and desserts.
    final fallback = recipes
        .where((r) => r.category != 'Напитки' && r.category != 'Десерты')
        .toList();
    return fallback.isNotEmpty ? fallback : recipes;
  }
}

extension DayMenuListX on List<DayMenu> {
  /// All recipes of the week (with repeats), used to build the shopping list.
  Iterable<Recipe> get allRecipes => expand((d) => d.meals.values.whereType<Recipe>());
}
