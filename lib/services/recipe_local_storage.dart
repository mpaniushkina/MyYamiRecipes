import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/recipes/data/models/recipe_model.dart';

class RecipeLocalStorage {
  static const String _storageKey = 'saved_recipes_list';

  static Future<List<RecipeModel>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => RecipeModel.fromJson(item)).toList();
    } catch (e) {
      print('Error recipes reading: $e');
      return [];
    }
  }

  static Future<void> saveRecipe(RecipeModel newRecipe) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRecipes = await getRecipes();

    currentRecipes.insert(0, newRecipe);

    final String encodedList = jsonEncode(
      currentRecipes.map((recipe) => recipe.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encodedList);
  }

  static Future<void> deleteRecipe(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final currentRecipes = await getRecipes();

    currentRecipes.removeWhere((recipe) => recipe.id == id);

    final String encodedList = jsonEncode(
      currentRecipes.map((recipe) => recipe.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encodedList);
  }

  static Future<void> saveAll(List<RecipeModel> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      recipes.map((recipe) => recipe.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }
}