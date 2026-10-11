import 'package:flutter/material.dart';
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
      home: const RecipesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}