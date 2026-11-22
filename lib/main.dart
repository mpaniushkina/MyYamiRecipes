import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'feature/recipes/domain/repositories/recipes_repository_impl.dart';
import 'feature/recipes/presentation/bloc/recipes_bloc.dart';
import 'feature/recipes/presentation/screen/recipes_screen.dart';
import 'l10n/l10n_helpers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Russian device language → Russian UI, anything else → English.
      localeListResolutionCallback: resolveAppLocale,
      home: BlocProvider(
        create: (context) => RecipesBloc(RecipesRepositoryImpl())..add(LoadRecipesEvent()),
        child: const RecipesScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
