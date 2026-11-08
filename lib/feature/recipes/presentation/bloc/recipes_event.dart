part of 'recipes_bloc.dart';

abstract class RecipesEvent {}

class LoadRecipesEvent extends RecipesEvent {}

class AddRecipeEvent extends RecipesEvent {
  final Recipe recipe;
  AddRecipeEvent(this.recipe);
}

class DeleteRecipeEvent extends RecipesEvent {
  final String id;
  DeleteRecipeEvent(this.id);
}

class UpdateRecipeEvent extends RecipesEvent {
  final Recipe recipe;
  UpdateRecipeEvent(this.recipe);
}

class FilterRecipesEvent extends RecipesEvent {
  final String? searchQuery;
  final String? category;
  final int? maxCalories;
  final bool clearCategory;
  final bool clearCalories;

  FilterRecipesEvent({
    this.searchQuery,
    this.category,
    this.maxCalories,
    this.clearCategory = false,
    this.clearCalories = false,
  });
}