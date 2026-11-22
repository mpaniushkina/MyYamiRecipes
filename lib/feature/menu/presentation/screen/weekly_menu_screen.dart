import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../l10n/l10n_helpers.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/screen/recipe_detail_screen.dart';
import '../../data/weekly_menu_storage.dart';
import '../../domain/shopping_list.dart';
import '../../domain/weekly_menu.dart';
import '../widget/recipe_picker_sheet.dart';
import '../widget/shopping_list_view.dart';
import '../widget/summary_bar.dart';

class WeeklyMenuScreen extends StatefulWidget {
  final List<Recipe> recipes;

  const WeeklyMenuScreen({super.key, required this.recipes});

  @override
  State<WeeklyMenuScreen> createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  final WeeklyMenuGenerator _generator = WeeklyMenuGenerator();
  List<DayMenu> _menu = [];
  final Set<String> _checkedProducts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final saved = await WeeklyMenuStorage.load(widget.recipes);
    if (!mounted) return;

    if (saved == null) {
      _generate();
    } else {
      setState(() {
        _menu = saved.menu;
        _checkedProducts
          ..clear()
          ..addAll(saved.checkedProducts);
      });
    }
    setState(() => _isLoading = false);
  }

  void _save() => WeeklyMenuStorage.save(_menu, _checkedProducts);

  void _generate() {
    setState(() {
      _menu = _generator.generate(widget.recipes);
      _checkedProducts.clear();
    });
    _save();
  }

  void _setMeal(int dayIndex, MealType type, Recipe? recipe) {
    setState(() => _menu[dayIndex] = _menu[dayIndex].copyWith(type, recipe));
    _save();
  }

  void _setChecked(String key, bool checked) {
    setState(() {
      if (checked) {
        _checkedProducts.add(key);
      } else {
        _checkedProducts.remove(key);
      }
    });
    _save();
  }

  void _clearChecked() {
    setState(_checkedProducts.clear);
    _save();
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  // A plain tap only shows a hint, so the current menu can't be lost by accident.
  void _onRegenerateTap() {
    _showSnackBar(context.l10n.holdForNewMenu);
  }

  void _onRegenerateLongPress() {
    HapticFeedback.mediumImpact();
    _generate();
    _showSnackBar(context.l10n.newMenuCreated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.weeklyMenu),
          backgroundColor: colorScheme.inversePrimary,
          actions: [
            _RegenerateButton(
              enabled: !_isLoading && widget.recipes.isNotEmpty,
              onLongPress: _onRegenerateLongPress,
              onTap: _onRegenerateTap,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.calendar_month), text: context.l10n.tabMenu),
              Tab(icon: const Icon(Icons.shopping_cart), text: context.l10n.tabGroceries),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : widget.recipes.isEmpty
            ? const _EmptyState()
            : TabBarView(
                children: [
                  _buildMenuTab(context),
                  _buildShoppingTab(context),
                ],
              ),
      ),
    );
  }

  // ---------------- Menu ----------------

  Widget _buildMenuTab(BuildContext context) {
    final weekCalories = _menu.fold<int>(0, (s, d) => s + d.totalCalories);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        SummaryBar(
          icon: Icons.local_fire_department,
          text: context.l10n.weekCaloriesSummary(weekCalories, (weekCalories / daysInWeek).round()),
        ),
        for (var i = 0; i < _menu.length; i++) _buildDayCard(context, i),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, int dayIndex) {
    final day = _menu[dayIndex];
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  context.l10n.weekDay(dayIndex),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.local_fire_department, size: 16, color: Colors.deepOrange),
                const SizedBox(width: 4),
                Text(
                  context.l10n.kcalValue(day.totalCalories),
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          for (final type in MealType.values) _buildMealTile(context, dayIndex, type),
        ],
      ),
    );
  }

  Widget _buildMealTile(BuildContext context, int dayIndex, MealType type) {
    final recipe = _menu[dayIndex][type];
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: recipe == null
          ? CircleAvatar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.no_meals),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset(
                AppStrings.getSvgAssetForCategory(recipe.category),
                width: 40,
                height: 40,
              ),
            ),
      title: Text(
        context.l10n.mealTitle(type),
        style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        recipe?.title ?? context.l10n.notSelected,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: recipe == null ? colorScheme.outline : colorScheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.replaceRandom,
            onPressed: () => _setMeal(
              dayIndex,
              type,
              _generator.randomFor(type, widget.recipes, except: recipe),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: context.l10n.chooseRecipe,
            onPressed: () => _pickRecipe(context, dayIndex, type),
          ),
        ],
      ),
      onTap: recipe == null
          ? () => _pickRecipe(context, dayIndex, type)
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
              ),
    );
  }

  Future<void> _pickRecipe(BuildContext context, int dayIndex, MealType type) async {
    final current = _menu[dayIndex][type];
    final sorted = List.of(widget.recipes)
      ..sort((a, b) {
        final pa = type.preferredCategories.contains(a.category) ? 0 : 1;
        final pb = type.preferredCategories.contains(b.category) ? 0 : 1;
        return pa != pb ? pa - pb : a.title.compareTo(b.title);
      });

    final result = await RecipePickerSheet.pickOne(
      context,
      title: '${context.l10n.weekDay(dayIndex)} · ${context.l10n.mealTitle(type)}',
      recipes: sorted,
      selectedId: current?.id,
    );

    if (result != null) _setMeal(dayIndex, type, result.recipe);
  }

  // ---------------- Shopping list ----------------

  Widget _buildShoppingTab(BuildContext context) {
    return ShoppingListView(
      items: buildShoppingList(_menu.allRecipes),
      checkedKeys: _checkedProducts,
      onToggle: _setChecked,
      onClearChecked: _clearChecked,
    );
  }
}

/// Labeled AppBar action that regenerates the menu on long press only.
/// Intentionally not wrapped in a Tooltip: Tooltip also reacts to long press.
class _RegenerateButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _RegenerateButton({
    required this.enabled,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.casino, size: 22, color: color),
              Text(
                context.l10n.regenerateButton,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, height: 1.1, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              context.l10n.addRecipesForWeeklyMenu,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
