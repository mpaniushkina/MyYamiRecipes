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