import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_yami_recipes/feature/recipes/presentation/screen/recipe_detail_screen.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../services/local_recipe_parser_service.dart';
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
  late final RecipesBloc _recipesBloc;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _recipesBloc = RecipesBloc(RecipesRepositoryImpl())..add(LoadRecipesEvent());
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _recipesBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Рецепты'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
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
            IconButton(
              icon: _isScanning
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.add_box),
              tooltip: 'Добавить из буфера',
              onPressed: _isScanning ? null : onPasteButtonPressed,
            ),
          ],
        ),
        body: BlocBuilder<RecipesBloc, RecipesState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Поиск по названию',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onChanged: (value) {
                      context.read<RecipesBloc>().add(FilterRecipesEvent(searchQuery: value));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 18, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text(
                        state.maxCalories == null
                            ? 'Калории: любые'
                            : 'До ${state.maxCalories} ккал',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (state.maxCalories != null)
                        TextButton(
                          onPressed: () {
                            context.read<RecipesBloc>().add(
                              FilterRecipesEvent(clearCalories: true),
                            );
                          },
                          child: const Text('Сбросить калории'),
                        ),
                    ],
                  ),
                ),

                Slider(
                  value: (state.maxCalories ?? 100).toDouble(),
                  min: 100,
                  max: 3000, // Верхняя граница слайдера
                  divisions: 28, // Шаг деления (каждые 50 ккал)
                  label: '${state.maxCalories ?? 100} ккал',
                  onChanged: (double value) {
                    context.read<RecipesBloc>().add(
                      FilterRecipesEvent(maxCalories: value.toInt()),
                    );
                  },
                ),

                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      'Все',
                      ...AppStrings.recipeCategories,
                    ].map((categoryName) {
                      // 1. Четкое вычисление подсветки для каждого чипа
                      final bool isSelected = (categoryName == 'Все')
                          ? (state.selectedCategory == null || state.selectedCategory!.isEmpty)
                          : (state.selectedCategory == categoryName);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(categoryName),
                          selected: isSelected,
                          onSelected: (selected) {
                            context.read<RecipesBloc>().add(
                              FilterRecipesEvent(category: categoryName),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: state.filteredRecipes.isEmpty
                      ? const Center(child: Text('Рецепты не найдены'))
                      : ListView.builder(
                    itemCount: state.filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.filteredRecipes[index];

                      return Dismissible(
                        key: Key(recipe.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
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
                              child: SvgPicture.asset(
                                AppStrings.getSvgAssetForCategory(recipe.category),
                                width: 48,
                                height: 48,
                              ),
                            ),
                            title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(recipe.description.toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: Text('${recipe.cookingTimeMinutes} мин'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      imageUrl: '',
      cookingTimeMinutes: 30,
      category: '',
      calories: 0,
      ingredients: [],
      steps: [],
    );
  }

  Future<void> onPasteButtonPressed() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) return;

    // Парсим сырой скопированный текст в структурированный объект
    Recipe? recipe = LocalRecipeParserService.parse(data.text!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: _recipesBloc,
          child: AddRecipeBottomSheet(recipeToEdit: recipe, createNewRecipe: true),
        );
      },
    );
  }

  Future<void> _handleScanScreenshot() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // 1. Выбираем скриншот и распознаем текст
      final String? recognizedText = await _ocrService.pickAndRecognizeText();
      // final String? recognizedText = await TesseractOcrService().pickAndRecognizeText();
      if (recognizedText != null && recognizedText.isNotEmpty) {
        if (!mounted) return;

        // final universalText = universalNormalizeOcr(recognizedText);
        final recipe = createRecipeFromOcr(recognizedText);
        // final recipe = await GroqRecipeParserService.parseRecipe(recognizedText);
        // final recipe = await DeepSeekRecipeParserService.parseRecipe(recognizedText);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) {
            return BlocProvider.value(
              value: _recipesBloc, // передаем уже пойманный блок
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
}