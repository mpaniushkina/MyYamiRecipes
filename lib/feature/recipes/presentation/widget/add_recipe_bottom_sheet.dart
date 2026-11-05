import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/recipe.dart';
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
      _ingredientsController.text = widget.recipeToEdit!.ingredients
          .map((e) => e.name).toList().join('\n');
      _timeController.text = (widget.recipeToEdit!.cookingTimeMinutes ?? 0).toString();
      _imageUrlController.text = widget.recipeToEdit!.imageUrl.toString();
      _caloriesController.text = (widget.recipeToEdit!.calories ?? 0).toString();
      final existingCategory = widget.recipeToEdit?.category;
      _selectedCategory = (existingCategory != null && AppStrings.recipeCategories.contains(existingCategory))
          ? existingCategory
          : AppStrings.recipeCategories.first;
    }
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
                'Новый рецепт',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название блюда'),
                validator: (value) => value == null || value.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: InputDecoration(
                  labelText: AppStrings.categoryLabel,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: AppStrings.recipeCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
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
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(labelText: 'Ингридиенты'),
                maxLines: 10,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Время приготовления (минут)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Введите число';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Каллории (ккал)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Введите число';
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
                              .map((line) => IngredientEntity(
                                name: line,
                                amount: '',
                                unit: '',
                              )).toList(),
                          steps: widget.recipeToEdit?.steps,
                        );

                        context.read<RecipesBloc>().add(AddRecipeEvent(newRecipe));
                      } else {
                        final updatedRecipe = Recipe(
                          id: widget.recipeToEdit!.id, // сохраняем старый ID
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
                              .map((line) => IngredientEntity(
                                name: line,
                                amount: '',
                                unit: '',
                              )).toList(),
                          steps: widget.recipeToEdit?.steps,
                        );
                        context.read<RecipesBloc>().add(UpdateRecipeEvent(updatedRecipe));
                      }
                      Navigator.pop(context);
                    }
                  },
                child: const Text('Сохранить рецепт'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}