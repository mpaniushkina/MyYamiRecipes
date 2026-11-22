import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_yami_recipes/feature/recipes/presentation/screen/recipe_detail_screen.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../l10n/l10n_helpers.dart';
import '../../../menu/presentation/screen/special_menu_list_screen.dart';
import '../../../menu/presentation/screen/weekly_menu_screen.dart';
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
          title: Text(context.l10n.recipesTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.restaurant_menu),
              tooltip: context.l10n.weeklyMenu,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyMenuScreen(recipes: _recipesBloc.state.allRecipes),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.celebration),
              tooltip: context.l10n.specialMenu,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpecialMenuListScreen(recipes: _recipesBloc.state.allRecipes),
                  ),
                );
              },
            ),
            //TODO this feature isn't added yet to use AI
            // IconButton(
            //   icon: _isScanning
            //       ? const SizedBox(
            //     width: 20,
            //     height: 20,
            //     child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            //   )
            //       : const Icon(Icons.document_scanner),
            //   tooltip: 'Scan',
            //   onPressed: _isScanning ? null : _handleScanScreenshot,
            // ),
            IconButton(
              icon: _isScanning
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.add_box),
              tooltip: context.l10n.addRecipe,
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
                      labelText: context.l10n.searchByTitle,
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
                            ? context.l10n.caloriesAny
                            : context.l10n.caloriesUpTo(state.maxCalories!),
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
                          child: Text(context.l10n.resetCalories),
                        ),
                    ],
                  ),
                ),

                Slider(
                  value: (state.maxCalories ?? 100).toDouble(),
                  min: 100,
                  max: 3000, // Slider upper bound
                  divisions: 28, // Step of 100 kcal
                  label: context.l10n.kcalValue(state.maxCalories ?? 100),
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
                      // 'Все' is the internal "all categories" value understood by the bloc.
                      final bool isSelected = (categoryName == 'Все')
                          ? (state.selectedCategory == null || state.selectedCategory!.isEmpty)
                          : (state.selectedCategory == categoryName);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(categoryName == 'Все'
                              ? context.l10n.allCategories
                              : context.l10n.categoryLabel(categoryName)),
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
                      ? Center(child: Text(context.l10n.recipesNotFound))
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
                          final bloc = context.read<RecipesBloc>();
                          // Remember the position in the full list to restore it on undo.
                          final originalIndex =
                              bloc.state.allRecipes.indexWhere((r) => r.id == recipe.id);
                          bloc.add(DeleteRecipeEvent(recipe.id));

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(context.l10n.recipeDeleted(recipe.title)),
                                duration: const Duration(seconds: 5),
                                // SnackBars with an action persist by default; auto-hide after 5 s.
                                persist: false,
                                action: SnackBarAction(
                                  label: context.l10n.undo,
                                  onPressed: () => bloc.add(
                                    RestoreRecipeEvent(recipe, originalIndex < 0 ? 0 : originalIndex),
                                  ),
                                ),
                              ),
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
                            trailing: Text(context.l10n.minutesValue(recipe.cookingTimeMinutes ?? 0)),
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
      ),
    );
  }

  Recipe createRecipeFromOcr(String recognizedText) {
    // Split into lines to try to find the title.
    final lines = recognizedText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    // The first non-empty line is the title, otherwise a default one.
    final title = lines.isNotEmpty ? lines.first : context.l10n.recipeFromScreenshot;

    // The whole text goes to the description.
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

  /// Opens the add-recipe sheet. If the clipboard has text, it is parsed
  /// into a prefilled recipe; otherwise an empty form is shown.
  Future<void> onPasteButtonPressed() async {
    String? clipboardText;
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      clipboardText = data?.text?.trim();
    } catch (_) {
      // Clipboard may be unavailable on some platforms: fall back to an empty form.
    }
    if (!mounted) return;

    final Recipe? recipe = (clipboardText == null || clipboardText.isEmpty)
        ? null
        : LocalRecipeParserService.parse(clipboardText);

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
      // 1. Pick a screenshot and recognize its text.
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
              value: _recipesBloc, // pass the already created bloc
              child: AddRecipeBottomSheet(recipeToEdit: recipe),
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.scanError('$e'))),
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