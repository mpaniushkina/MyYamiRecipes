import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/ingredient_parser.dart';
import '../../../../l10n/l10n_helpers.dart';
import '../bloc/recipes_bloc.dart';

class AddRecipeBottomSheet extends StatefulWidget {
  final Recipe? recipeToEdit;
  final bool? createNewRecipe;

  const AddRecipeBottomSheet({super.key, this.recipeToEdit, this.createNewRecipe});

  @override
  State<AddRecipeBottomSheet> createState() => _AddRecipeBottomSheetState();
}

class _AddRecipeBottomSheetState extends State<AddRecipeBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _imageUrlController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _titleController.text = widget.recipeToEdit!.title;
      _descriptionController.text = widget.recipeToEdit!.description.toString();
      _timeController.text = (widget.recipeToEdit!.cookingTimeMinutes ?? 0).toString();
      _imageUrlController.text = widget.recipeToEdit!.imageUrl.toString();
      _caloriesController.text = (widget.recipeToEdit!.calories ?? 0).toString();
      final existingCategory = widget.recipeToEdit?.category;
      _selectedCategory = (existingCategory != null && AppStrings.recipeCategories.contains(existingCategory))
          ? existingCategory
          : AppStrings.recipeCategories.first;
    }
  }

  bool _ingredientsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localizations aren't available in initState, so fill ingredients here once.
    if (_ingredientsInitialized) return;
    _ingredientsInitialized = true;
    final recipe = widget.recipeToEdit;
    if (recipe == null) return;

    final l10n = context.l10n;
    // "Name — amount unit" per line with localized units;
    // IngredientParser understands both Russian and English units on save.
    _ingredientsController.text = recipe.ingredients.map((e) {
      final quantity = l10n.quantity(e.amount, e.unit);
      return quantity.isEmpty ? e.name : '${e.name} — $quantity';
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.newRecipe,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: context.l10n.dishTitle),
                validator: (value) => value == null || value.isEmpty ? context.l10n.enterTitle : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: AppStrings.recipeCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    // Stored value stays Russian; only the label is localized.
                    child: Text(context.l10n.categoryLabel(category)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: context.l10n.description),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(labelText: context.l10n.ingredients),
                maxLines: 10,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: context.l10n.cookingTimeMinutes),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return context.l10n.enterNumber;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(labelText: context.l10n.caloriesKcal),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return context.l10n.enterNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.createNewRecipe == true || widget.recipeToEdit == null) {
                        final newRecipe = Recipe(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text,
                          description: _descriptionController.text,
                          cookingTimeMinutes: int.parse(_timeController.text),
                          imageUrl: _imageUrlController.text,
                          category: _selectedCategory.toString(),
                          calories: int.parse(_caloriesController.text),
                          ingredients: _ingredientsController.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .map(IngredientParser.parse).toList(),
                          steps: widget.recipeToEdit?.steps,
                        );

                        context.read<RecipesBloc>().add(AddRecipeEvent(newRecipe));
                      } else {
                        final updatedRecipe = Recipe(
                          id: widget.recipeToEdit!.id, // keep the original id
                          title: _titleController.text,
                          description: _descriptionController.text,
                          cookingTimeMinutes: int.parse(_timeController.text),
                          imageUrl: _imageUrlController.text,
                          category: _selectedCategory.toString(),
                          calories: int.parse(_caloriesController.text),
                          ingredients: _ingredientsController.text
                              .split('\n')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .map(IngredientParser.parse).toList(),
                          steps: widget.recipeToEdit?.steps,
                        );
                        context.read<RecipesBloc>().add(UpdateRecipeEvent(updatedRecipe));
                      }
                      Navigator.pop(context);
                    }
                  },
                child: Text(context.l10n.saveRecipe),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}