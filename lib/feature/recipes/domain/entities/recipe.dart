class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int cookingTimeMinutes;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookingTimeMinutes,
  });
}