class AppStrings {
  // Список категорий для рецептов
  static const List<String> recipeCategories = [
    'Завтраки',
    'Супы',
    'Основные блюда',
    'Салаты',
    'Десерты',
    'Выпечка',
    'Напитки',
    'Закуски',
    'Другое',
  ];

  static const Map<String, String> categorySvgAssets = {
    'Завтраки': 'assets/icons/categories/breakfast.svg',
    'Супы': 'assets/icons/categories/soup.svg',
    'Основные блюда': 'assets/icons/categories/main_course.svg',
    'Салаты': 'assets/icons/categories/salad.svg',
    'Десерты': 'assets/icons/categories/dessert.svg',
    'Выпечка': 'assets/icons/categories/bakery.svg',
    'Напитки': 'assets/icons/categories/drinks.svg',
    'Другое': 'assets/icons/categories/other.svg',
  };

  static String getSvgAssetForCategory(String? category) {
    return categorySvgAssets[category] ?? categorySvgAssets['Другое']!;
  }

  static const String appTitle = 'My Yami Recipes';
  static const String saveButton = 'Сохранить';
  static const String categoryLabel = 'Категория';
}