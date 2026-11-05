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
            if (state is RecipesLoading || state is RecipesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecipesError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            } else if (state is RecipesLoaded) {
              final recipes = state.recipes;

              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];

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
}