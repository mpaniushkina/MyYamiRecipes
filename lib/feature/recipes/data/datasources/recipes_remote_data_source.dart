import 'package:dio/dio.dart';
import '../models/recipe_model.dart';

class RecipesRemoteDataSource {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  Future<List<RecipeModel>> fetchRecipes() async {
    try {
      final response = await _dio.get('/recipes');

      // DummyJSON возвращает обертку {"recipes": [...]}, достаем список
      final List recipesList = response.data['recipes'];

      return recipesList
          .map((json) => RecipeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки из сети: $e');
    }
  }
}