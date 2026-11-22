import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recipes_repository.dart';
import '../../domain/entities/recipe.dart';

part 'recipes_event.dart';
part 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepository _repository;

  RecipesBloc(this._repository) : super(RecipesInitial()) {
    on<LoadRecipesEvent>(_onLoadRecipes);
    on<AddRecipeEvent>(_onAddRecipe);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
    on<RestoreRecipeEvent>(_onRestoreRecipe);
    on<UpdateRecipeEvent>(_onUpdateRecipe);
    on<FilterRecipesEvent>(_onFilterRecipes);
  }

  Future<void> _onLoadRecipes(
      LoadRecipesEvent event,
      Emitter<RecipesState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final recipes = await _repository.getRecipes();

      emit(state.copyWith(
        allRecipes: recipes,
        filteredRecipes: recipes,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  Future<void> _onAddRecipe(
      AddRecipeEvent event,
      Emitter<RecipesState> emit,
      ) async {
    try {
      await _repository.addRecipe(event.recipe);

      final recipes = await _repository.getRecipes();

      List<Recipe> tempRecipes = List.from(recipes);

      if (state.searchQuery.isNotEmpty) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.title.toLowerCase().contains(state.searchQuery.toLowerCase());
        }).toList();
      }

      if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.category == state.selectedCategory;
        }).toList();
      }

      if (state.maxCalories != null && state.maxCalories! > 0) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.calories! <= state.maxCalories!;
        }).toList();
      }

      emit(state.copyWith(
        allRecipes: recipes,
        filteredRecipes: tempRecipes,
      ));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(
      DeleteRecipeEvent event,
      Emitter<RecipesState> emit,
      ) async {
    try {
      await _repository.deleteRecipe(event.id);
      final updatedAllRecipes = List<Recipe>.from(state.allRecipes)
        ..removeWhere((recipe) => recipe.id == event.id);

      emit(state.copyWith(
        allRecipes: updatedAllRecipes,
        // Keep the active search/category/calorie filters after deletion.
        filteredRecipes: _applyCurrentFilters(updatedAllRecipes),
      ));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> _onRestoreRecipe(
      RestoreRecipeEvent event,
      Emitter<RecipesState> emit,
      ) async {
    try {
      await _repository.restoreRecipe(event.recipe, event.index);
      final recipes = await _repository.getRecipes();

      emit(state.copyWith(
        allRecipes: recipes,
        filteredRecipes: _applyCurrentFilters(recipes),
      ));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  /// Applies the filters stored in the current state (same rules as [_onFilterRecipes]).
  List<Recipe> _applyCurrentFilters(List<Recipe> recipes) {
    final query = state.searchQuery.toLowerCase();
    final category = state.selectedCategory;
    final maxCalories = state.maxCalories;

    return recipes.where((recipe) {
      if (query.isNotEmpty && !recipe.title.toLowerCase().contains(query)) return false;
      if (category != null && category.isNotEmpty && recipe.category != category) return false;
      if (maxCalories != null && maxCalories > 0) {
        final calories = recipe.calories ?? 0;
        if (calories <= 0 || calories > maxCalories) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _onUpdateRecipe(UpdateRecipeEvent event, Emitter<RecipesState> emit,) async {
    try {
      await _repository.updateRecipe(event.recipe);

      final recipes = await _repository.getRecipes();

      List<Recipe> tempRecipes = List.from(recipes);

      if (state.searchQuery.isNotEmpty) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.title.toLowerCase().contains(state.searchQuery.toLowerCase());
        }).toList();
      }

      if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.category == state.selectedCategory;
        }).toList();
      }

      if (state.maxCalories != null && state.maxCalories! > 0) {
        tempRecipes = tempRecipes.where((recipe) {
          return recipe.calories! <= state.maxCalories!;
        }).toList();
      }

      emit(state.copyWith(
        allRecipes: recipes,
        filteredRecipes: tempRecipes,
      ));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  void _onFilterRecipes(FilterRecipesEvent event, Emitter<RecipesState> emit) {
    final query = event.searchQuery ?? state.searchQuery;

    final bool shouldClearCategory = event.category == 'Все' || (event.category != null && event.category!.isEmpty);
    final String? category = shouldClearCategory
        ? null
        : (event.category ?? state.selectedCategory);

    final bool shouldClearCalories = event.clearCalories;
    final int? maxCalories = shouldClearCalories
        ? null
        : (event.maxCalories ?? state.maxCalories);

    List<Recipe> tempRecipes = List.from(state.allRecipes);

    if (query.isNotEmpty) {
      tempRecipes = tempRecipes.where((recipe) =>
          recipe.title.toLowerCase().contains(query.toLowerCase())).toList();
    }

    if (category != null && category.isNotEmpty) {
      tempRecipes = tempRecipes.where((recipe) => recipe.category == category).toList();
    }

    if (maxCalories != null && maxCalories > 0) {
      tempRecipes = tempRecipes.where((recipe) {
        return recipe.calories! <= maxCalories && recipe.calories! > 0;
      }).toList();
    }

    emit(state.copyWith(
      filteredRecipes: tempRecipes,
      searchQuery: query,
      selectedCategory: category,
      clearCategory: shouldClearCategory,
      maxCalories: maxCalories,
      clearCalories: shouldClearCalories,
    ));
  }
}