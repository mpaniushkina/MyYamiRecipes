import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'feature/recipes/domain/repositories/recipes_repository_impl.dart';
import 'feature/recipes/presentation/bloc/recipes_bloc.dart';
import 'feature/recipes/presentation/screen/recipes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рецепты',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => RecipesBloc(RecipesRepositoryImpl())..add(LoadRecipesEvent()),
        child: const RecipesScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}