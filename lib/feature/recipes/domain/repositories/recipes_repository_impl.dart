import '../../data/datasources/recipes_remote_data_source.dart';
import '../../data/models/recipe_model.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  // Храним в памяти для примера
  // final List<Recipe> _recipes = [
  //   const Recipe(
  //     id: '1',
  //     title: 'Домашний борщ',
  //     description: 'Классический рецепт наваристого борща с пампушками.',
  //     imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd',
  //     cookingTimeMinutes: 90,
  //   ),
  //   const Recipe(
  //     id: '2',
  //     title: 'Паста Карбонара',
  //     description: 'Традиционная итальянская паста с беконом и сливочным соусом.',
  //     imageUrl: 'https://images.unsplash.com/photo-1612874742237-6526221588e3',
  //     cookingTimeMinutes: 30,
  //   ),
  //   const Recipe(
  //     id: '3',
  //     title: 'Греческий салат',
  //     description: 'Легкий летний салат со свежими овощами и сыром фета.',
  //     imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999',
  //     cookingTimeMinutes: 15,
  //   ),
  // ];

  // Хранилище в памяти для объединенного списка
  List<Recipe> _cachedRecipes = [];
  final RecipesRemoteDataSource _remoteDataSource = RecipesRemoteDataSource();

  @override
  Future<List<Recipe>> getRecipes() async {
    if (_cachedRecipes.isEmpty) {
      final remoteRecipes = await _remoteDataSource.fetchRecipes();
      _cachedRecipes = remoteRecipes;
    }
    return List.from(_cachedRecipes);
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedRecipes.insert(0, recipe);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _cachedRecipes.removeWhere((recipe) => recipe.id == id);
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cachedRecipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      // Превращаем в RecipeModel или оставляем базовым Recipe,
      // но лучше привести к тому типу, который хранится в списке:
      _cachedRecipes[index] = RecipeModel(
        id: updatedRecipe.id,
        title: updatedRecipe.title,
        description: updatedRecipe.description,
        imageUrl: updatedRecipe.imageUrl,
        cookingTimeMinutes: updatedRecipe.cookingTimeMinutes,
      );
    }
  }
}