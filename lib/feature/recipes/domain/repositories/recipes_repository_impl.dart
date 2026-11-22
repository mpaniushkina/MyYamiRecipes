import '../../../../services/recipe_local_storage.dart';
import '../../data/models/recipe_model.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  // Singleton pattern to keep _cachedRecipes in memory across the app lifecycle
  static final RecipesRepositoryImpl _instance = RecipesRepositoryImpl._internal();
  factory RecipesRepositoryImpl() => _instance;
  RecipesRepositoryImpl._internal();

  List<Recipe> _cachedRecipes = [];
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final models = await RecipeLocalStorage.getRecipes();
      _cachedRecipes = models.map((model) => model.toEntity()).toList();
      _isInitialized = true;
      print('DEBUG: Initialized from storage. Loaded: ${_cachedRecipes.length} recipes');
    }
  }

  @override
  Future<List<Recipe>> getRecipes() async {
    await _ensureInitialized();
    return List.from(_cachedRecipes);
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    await _ensureInitialized();
    _cachedRecipes.insert(0, recipe);
    await _persistCurrentState();
    print('DEBUG: Recipe added. Current cache length: ${_cachedRecipes.length}');
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _ensureInitialized();
    _cachedRecipes.removeWhere((recipe) => recipe.id == id);
    await _persistCurrentState();
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _ensureInitialized();
    final index = _cachedRecipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _cachedRecipes[index] = updatedRecipe;
      await _persistCurrentState();
    }
  }

  @override
  Future<void> restoreRecipe(Recipe recipe, int index) async {
    await _ensureInitialized();
    if (_cachedRecipes.any((r) => r.id == recipe.id)) return;
    _cachedRecipes.insert(index.clamp(0, _cachedRecipes.length), recipe);
    await _persistCurrentState();
  }

  Future<void> _persistCurrentState() async {
    final models = _cachedRecipes.map((entity) => RecipeModel.fromEntity(entity)).toList();
    await RecipeLocalStorage.saveAll(models);
  }
}