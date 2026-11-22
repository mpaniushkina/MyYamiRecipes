import '../entities/recipe.dart';

abstract class RecipesRepository {
  Future<List<Recipe>> getRecipes();
  Future<void> addRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
  Future<void> updateRecipe(Recipe recipe);

  /// Puts a previously deleted [recipe] back at [index] (used by "undo delete").
  Future<void> restoreRecipe(Recipe recipe, int index);
}