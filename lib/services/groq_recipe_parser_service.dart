import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../feature/recipes/data/models/recipe_model.dart';
import '../feature/recipes/domain/entities/recipe.dart';

class GroqRecipeParserService {
  // Groq API key (free at console.groq.com). Never hardcode it: it is passed at build time via
  // `flutter run --dart-define-from-file=config/api_keys.json` (that file is gitignored).
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<Map<String, dynamic>?> parseOcrText(String rawOcrText) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          // Используем актуальную быструю открытую модель, например llama-3.3-70b-versatile или llama-3.1-8b-instant
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'Ты — профессиональный кулинарный ассистент. Твоя задача — проанализировать грязный OCR-текст с экрана (в нем могут быть перепутаны кириллица и латиница из-за шрифтов, опечатки), исправить его, распознать состав, определить категорию блюда (Супы, Салаты, Второе, Выпечка, Десерты и т.д.) и вернуть строго валидный JSON-объект следующего формата: '
                  '{"title": "Название рецепта", "category": "Категория", "ingredients": [{"name": "Название ингредиента", "amount": "Количество", "unit": "Ед. изм."}], "steps": ["Шаг 1", "Шаг 2"]}. Не пиши ничего, кроме JSON.'
            },
            {
              'role': 'user',
              'content': rawOcrText,
            }
          ],
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content) as Map<String, dynamic>;
      } else {
        print('Ошибка Groq API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Исключение при запросе к Groq: $e');
      return null;
    }
  }

  static Future<Recipe?> parseRecipe(String rawOcrText) async {
    // Получаем JSON-карту от ИИ
    final jsonMap = await parseOcrText(rawOcrText);

    if (jsonMap == null) return null;

    try {
      // Превращаем JSON в RecipeModel, а затем в чистый Recipe (Entity)
      final recipeModel = RecipeModel.fromJson(jsonMap);
      return recipeModel.toEntity();
    } catch (e) {
      print('Ошибка маппинга JSON в Recipe: $e');
      return null;
    }
  }
}