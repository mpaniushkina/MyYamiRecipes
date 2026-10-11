import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_yami_recipes/feature/recipes/presentation/screen/recipe_detail_screen.dart';
import '../../domain/repositories/recipes_repository_impl.dart';
import '../bloc/recipes_bloc.dart';
import '../widget/add_recipe_bottom_sheet.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Внедряем зависимость и сразу кидаем событие загрузки
    return BlocProvider(
      create: (context) => RecipesBloc(RecipesRepositoryImpl())..add(LoadRecipesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Рецепты'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocBuilder<RecipesBloc, RecipesState>(
          builder: (context, state) {
            if (state is RecipesLoading || state is RecipesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RecipesError) {
              return Center(child: Text('Ошибка: ${state.message}'));
            } else if (state is RecipesLoaded) {
              final recipes = state.recipes;

              // Аналог LazyColumn / RecyclerView
              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];

                  return Dismissible(
                    // Уникальный ключ для каждого элемента обязателен
                      key: Key(recipe.id),
                      direction: DismissDirection.endToStart, // Свайп только справа налево
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // Пушим событие удаления в BLoC
                        context.read<RecipesBloc>().add(DeleteRecipeEvent(recipe.id));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Рецепт "${recipe.title}" удален')),
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
                          // Открываем ту же форму, но передаем туда текущий рецепт для изменения
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
                          // Заглушка под картинку из сети
                          child: Image.network(
                            recipe.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                          ),
                        ),
                        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(recipe.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text('${recipe.cookingTimeMinutes} мин'),
                      ),
                    ),
                  );
                  },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (innerContext) {
            return FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: innerContext,
                  isScrollControlled: true,
                  builder: (sheetContext) {
                    return BlocProvider.value(
                      value: BlocProvider.of<RecipesBloc>(innerContext),
                      child: const AddRecipeBottomSheet(recipeToEdit: null,),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}