part of 'recipes_bloc.dart';

// Базовый класс состояния (аналог sealed class в Kotlin для UI state)
abstract class RecipesState {}

class RecipesInitial extends RecipesState {}

class RecipesLoading extends RecipesState {}

class RecipesLoaded extends RecipesState {
  final List<Recipe> recipes;
  RecipesLoaded(this.recipes);
}

class RecipesError extends RecipesState {
  final String message;
  RecipesError(this.message);
}