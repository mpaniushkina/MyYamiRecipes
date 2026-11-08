part of 'recipes_bloc.dart';

class RecipesState {
  final List<Recipe> allRecipes;
  final List<Recipe> filteredRecipes;
  final String searchQuery;
  final String? selectedCategory;
  final int? maxCalories;
  final bool isLoading;

  RecipesState({
    this.allRecipes = const [],
    this.filteredRecipes = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.maxCalories,
    this.isLoading = false,
  });

  RecipesState copyWith({
    List<Recipe>? allRecipes,
    List<Recipe>? filteredRecipes,
    String? searchQuery,
    String? selectedCategory,
    int? maxCalories,
    bool clearCalories = false,
    bool? isLoading,
    bool clearCategory = false,
  }) {
    return RecipesState(
      allRecipes: allRecipes ?? this.allRecipes,
      filteredRecipes: filteredRecipes ?? this.filteredRecipes,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      maxCalories: clearCalories ? null : (maxCalories ?? this.maxCalories),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

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