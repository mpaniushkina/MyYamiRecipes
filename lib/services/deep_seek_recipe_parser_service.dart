import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feature/recipes/data/models/recipe_model.dart';
import '../feature/recipes/domain/entities/recipe.dart';

class DeepSeekRecipeParserService {
  static const String _apiKey = 'ВАШ_DEEPSEEK_API_KEY';
  static const String _url = 'https://api.deepseek.com/chat/completions';

  static Future<Map<String, dynamic>?> parseOcrText(String rawOcrText) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat', // или deepseek-flash
          'messages': [
            {
              'role': 'system',
              'content': 'Ты умный ассистент, который извлекает рецепты из текста и возвращает их строго в формате JSON со следующими полями: '
                  'title (string), description (string), cooking_time_minutes (integer), category (string), '
                  'ingredients (массив объектов с полями name, amount, unit), steps (массив строк с шагами приготовления).'
            },
            {
              'role': 'user',
              'content': rawOcrText
            }
          ],
          'response_format': {'type': 'json_object'},
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
        final contentString = decodedBody['choices'][0]['message']['content'];
        return jsonDecode(contentString) as Map<String, dynamic>;
      } else {
        print('Ошибка DeepSeek API: ${response.statusCode} — ${response.body}');
        return null;
      }
    } catch (e) {
      print('Исключение при запросе к DeepSeek API: $e');
      return null;
    }
  }

  static Future<Recipe?> parseRecipe(String rawOcrText) async {
    final jsonMap = await parseOcrText(rawOcrText);
    if (jsonMap == null) return null;

    try {
      final recipeModel = RecipeModel.fromJson(jsonMap);
      return recipeModel.toEntity();
    } catch (e) {
      print('Ошибка маппинга JSON в Recipe: $e');
      return null;
    }
  }
}