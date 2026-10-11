import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/recipe_model.dart';
import '../../domain/entities/recipe.dart';
import '../bloc/recipes_bloc.dart';

class AddRecipeBottomSheet extends StatefulWidget {
  final Recipe? recipeToEdit; // Если передан — это режим редактирования

  const AddRecipeBottomSheet({super.key, this.recipeToEdit});

  @override
  State<AddRecipeBottomSheet> createState() => _AddRecipeBottomSheetState();
}

class _AddRecipeBottomSheetState extends State<AddRecipeBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Если передали рецепт, заполняем инпуты старыми данными
    if (widget.recipeToEdit != null) {
      _titleController.text = widget.recipeToEdit!.title;
      _descriptionController.text = widget.recipeToEdit!.description;
      _timeController.text = widget.recipeToEdit!.cookingTimeMinutes.toString();
      _imageUrlController.text = widget.recipeToEdit!.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Поднимаем форму выше клавиатуры
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
                // validator: (value) => value == null || value.isEmpty ? 'Введите описание' : null,
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL картинки (необязательно)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.recipeToEdit == null) {
                        // Создание нового
                        final newRecipe = RecipeModel(
                          id: widget.recipeToEdit!.id,
                          title: _titleController.text,
                          description: _descriptionController.text,
                          cookingTimeMinutes: int.parse(_timeController.text),
                          imageUrl: _imageUrlController.text,
                        );

                        context.read<RecipesBloc>().add(AddRecipeEvent(newRecipe));
                      } else {
                        // Обновление существующего
                        final updatedRecipe = Recipe(
                          id: widget.recipeToEdit!.id, // сохраняем старый ID
                          title: _titleController.text,
                          description: _descriptionController.text,
                          cookingTimeMinutes: int.parse(_timeController.text),
                          imageUrl: _imageUrlController.text,
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