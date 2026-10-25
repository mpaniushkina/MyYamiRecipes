import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_yami_recipes/feature/recipes/presentation/screen/recipe_detail_screen.dart';
import '../../../../services/ocr_service.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipes_repository_impl.dart';
import '../bloc/recipes_bloc.dart';
import '../widget/add_recipe_bottom_sheet.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final OcrService _ocrService = OcrService();
  late final recipesBloc = context.read<RecipesBloc>();
  bool _isScanning = false;

  Future<void> _handleScanScreenshot() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // 1. Выбираем скриншот и распознаем текст
      final String? recognizedText = await _ocrService.pickAndRecognizeText();

      if (recognizedText != null && recognizedText.isNotEmpty) {
        if (!mounted) return;

        final universalText = universalNormalizeOcr(recognizedText);
        final recipe = createRecipeFromOcr(universalText);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return BlocProvider.value(
              value: recipesBloc, // передаем уже пойманный блок
              child: AddRecipeBottomSheet(recipeToEdit: recipe),
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сканирования: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ocrService.dispose(); // Не забываем закрыть сканнер при уничтожении экрана
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Внедряем зависимость и сразу кидаем событие загрузки
    return BlocProvider(
      create: (context) => RecipesBloc(RecipesRepositoryImpl())..add(LoadRecipesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Рецепты'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Кнопка сканирования скриншота в AppBar
            IconButton(
              icon: _isScanning
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.document_scanner),
              tooltip: 'Сканировать',
              onPressed: _isScanning ? null : _handleScanScreenshot,
            ),
          ],
        ),
        body: BlocBuilder<RecipesBloc, RecipesState>(
          builder: (context, state) {
            if (state is RecipesLoading || state is RecipesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecipesError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            } else if (state is RecipesLoaded) {
              final recipes = state.recipes;

              // Аналог LazyColumn / RecyclerView
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];

                  return Dismissible(
                    // Уникальный ключ для каждого элемента обязателен
                    key: Key(recipe.id),
                    direction: DismissDirection.endToStart, // Свайп только справа налево
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      // Пушим событие удаления в BLoC
                      context.read<RecipesBloc>().add(DeleteRecipeEvent(recipe.id));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Рецепт "${recipe.title}" удален')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                        onLongPress: () {
                          // Открываем ту же форму, но передаем туда текущий рецепт для изменения
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (sheetContext) {
                              return BlocProvider.value(
                                value: BlocProvider.of<RecipesBloc>(context),
                                child: AddRecipeBottomSheet(recipeToEdit: recipe),
                              );
                            },
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // Заглушка под картинку из сети
                          child: Image.network(
                            recipe.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                          ),
                        ),
                        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(recipe.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text('${recipe.cookingTimeMinutes} мин'),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (innerContext) {
            return FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: innerContext,
                  isScrollControlled: true,
                  builder: (sheetContext) {
                    return BlocProvider.value(
                      value: BlocProvider.of<RecipesBloc>(innerContext),
                      child: const AddRecipeBottomSheet(recipeToEdit: null,),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  Recipe createRecipeFromOcr(String recognizedText) {
    // Разбиваем текст на строки, чтобы попробовать найти название
    final lines = recognizedText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // Берем первую непустую строку как заголовок (если текст есть), иначе дефолт
    final title = lines.isNotEmpty ? lines.first : 'Рецепт со скриншота';

    // Остальной текст (или весь текст целиком) пустим в описание
    final description = recognizedText;

    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // простейший уникальный id
      title: title,
      description: description,
      imageUrl: '', // пока нет картинки или можно сохранить путь к скриншоту
      cookingTimeMinutes: 30, // дефолтное время, которое пользователь потом поправит
    );
  }

  String universalNormalizeOcr(String text) {
    // Словарь визуально похожих латинских и русских букв
    const Map<String, String> latinToCyrillic = {
      'a': 'а',
      'e': 'е',
      'o': 'о',
      'p': 'р',
      'c': 'с',
      'y': 'у',
      'x': 'х',
      'i': 'і', // иногда встречается в украинском/белорусском контексте или специфичных шрифтах
      'A': 'А',
      'B': 'В',
      'E': 'Е',
      'K': 'К',
      'M': 'М',
      'H': 'Н',
      'O': 'О',
      'P': 'Р',
      'C': 'С',
      'T': 'Т',
      'X': 'Х',
    };

    // Разбиваем текст на слова или обрабатываем посимвольно
    // Простой подход: заменяем символы в словах, где уже есть кириллица,
    // либо делаем общую замену для заведомо «сломанных» слов.

    List<String> words = text.split(RegExp(r'\s+'));
    List<String> normalizedWords = words.map((word) {
      // Проверяем, есть ли в слове хоть одна русская буква
      bool hasCyrillic = RegExp(r'[а-яА-ЯёЁ]').hasMatch(word);

      if (hasCyrillic) {
        // Если слово смешанное (например, "canaTMK" -> есть кириллица или намек),
        // заменяем латинские аналоги на кириллицу
        return word.split('').map((char) {
          return latinToCyrillic[char] ?? char;
        }).join('');
      }

      return word;
    }).toList();

    return normalizedWords.join(' ');
  }
}