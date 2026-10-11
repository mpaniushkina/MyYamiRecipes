import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recipes_repository.dart';
import '../../domain/entities/recipe.dart';

part 'recipes_event.dart';
part 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepository _repository;

  RecipesBloc(this._repository) : super(RecipesInitial()) {
    // Подписываемся на события (как Intent в MVI)
    on<LoadRecipesEvent>(_onLoadRecipes);
    on<AddRecipeEvent>(_onAddRecipe);
    on<DeleteRecipeEvent>(_onDeleteRecipe);
    on<UpdateRecipeEvent>(_onUpdateRecipe);
  }

  Future<void> _onLoadRecipes(
      LoadRecipesEvent event,
      Emitter<RecipesState> emit,
      ) async {
    emit(RecipesLoading());
    try {
      final recipes = await _repository.getRecipes();
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> _onAddRecipe(
      AddRecipeEvent event,
      Emitter<RecipesState> emit,
      ) async {
    try {
      await _repository.addRecipe(event.recipe);
      // После добавления заново запрашиваем список
      final recipes = await _repository.getRecipes();
      emit(RecipesLoaded(recipes));
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
      final recipes = await _repository.getRecipes();
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(
      UpdateRecipeEvent event,
      Emitter<RecipesState> emit,
      ) async {
    try {
      await _repository.updateRecipe(event.recipe);
      final recipes = await _repository.getRecipes();
      emit(RecipesLoaded(recipes));
    } catch (e) {
      emit(RecipesError(e.toString()));
    }
  }
}