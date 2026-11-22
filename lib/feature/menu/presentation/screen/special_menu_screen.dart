import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/screen/recipe_detail_screen.dart';
import '../../data/special_menu_storage.dart';
import '../../domain/shopping_list.dart';
import '../../domain/special_menu.dart';
import '../widget/recipe_picker_sheet.dart';
import '../widget/shopping_list_view.dart';
import '../widget/summary_bar.dart';

/// Asks the user to confirm deleting [menu]. Returns true if confirmed.
Future<bool> confirmDeleteSpecialMenu(BuildContext context, SpecialMenu menu) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.delete_outline),
      title: const Text('Удалить меню?'),
      content: Text('«${menu.displayName}» и его список продуктов будут удалены.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

/// Editor of one special-occasion menu: the user hand-picks any dishes
/// (snacks, salads, desserts, drinks...) via search and gets a shopping list.
///
/// A brand-new menu ([isNew]) is not persisted until it gets a name or a dish,
/// so opening and leaving it doesn't occupy one of the limited slots.
/// Pops with `true` if the menu was deleted.
class SpecialMenuScreen extends StatefulWidget {
  final SpecialMenu menu;
  final List<Recipe> recipes;
  final bool isNew;

  const SpecialMenuScreen({
    super.key,
    required this.menu,
    required this.recipes,
    this.isNew = false,
  });

  @override
  State<SpecialMenuScreen> createState() => _SpecialMenuScreenState();
}

class _SpecialMenuScreenState extends State<SpecialMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final TextEditingController _nameController =
      TextEditingController(text: widget.menu.name);

  late final Map<String, Recipe> _recipesById = {
    for (final r in widget.recipes) r.id: r,
  };

  late SpecialMenu _menu = widget.menu.copyWith(
    // Drop ids of recipes that were deleted since the menu was saved.
    recipeIds: widget.menu.recipeIds.where(_recipesById.containsKey).toList(),
  );
  late bool _isPersisted = !widget.isNew;

  List<Recipe> get _selectedRecipes => _menu.resolveRecipes(_recipesById);

  @override
  void initState() {
    super.initState();
    // Rebuild to show the FAB only on the dishes tab.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _update(SpecialMenu menu) {
    setState(() => _menu = menu);
    if (!_isPersisted && menu.isEmpty) return;
    _isPersisted = true;
    SpecialMenuStorage.save(menu);
  }

  Future<void> _addDishes() async {
    final sorted = List.of(widget.recipes)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    final selected = await RecipePickerSheet.pickMany(
      context,
      title: 'Блюда для меню',
      recipes: sorted,
      selectedIds: _menu.recipeIds.toSet(),
    );
    if (selected == null) return;

    final current = _menu.recipeIds;
    _update(_menu.copyWith(
      // Keep the existing order, append newly selected dishes at the end.
      recipeIds: [
        ...current.where(selected.contains),
        ...selected.where((id) => !current.contains(id)),
      ],
    ));
  }

  void _removeDish(Recipe recipe) {
    _update(_menu.copyWith(
      recipeIds: _menu.recipeIds.where((id) => id != recipe.id).toList(),
    ));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('«${recipe.title}» убрано из меню')));
  }

  void _setChecked(String key, bool checked) {
    final keys = {..._menu.checkedProducts};
    checked ? keys.add(key) : keys.remove(key);
    _update(_menu.copyWith(checkedProducts: keys));
  }

  void _clearChecked() => _update(_menu.copyWith(checkedProducts: {}));

  Future<void> _deleteMenu() async {
    if (!await confirmDeleteSpecialMenu(context, _menu)) return;
    if (_isPersisted) await SpecialMenuStorage.delete(_menu.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_menu.name.trim().isEmpty ? 'Новое меню' : _menu.name.trim()),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить меню',
            onPressed: _deleteMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.celebration), text: 'Блюда'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Продукты'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDishesTab(context),
          ShoppingListView(
            items: buildShoppingList(_selectedRecipes),
            checkedKeys: _menu.checkedProducts,
            onToggle: _setChecked,
            onClearChecked: _clearChecked,
            emptyText: _menu.recipeIds.isEmpty
                ? 'Добавьте блюда в меню, и здесь появится список продуктов'
                : 'В выбранных рецептах нет ингредиентов',
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 && widget.recipes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addDishes,
              icon: const Icon(Icons.add),
              label: const Text('Добавить блюда'),
            )
          : null,
    );
  }

  // ---------------- Dishes ----------------

  Widget _buildDishesTab(BuildContext context) {
    final dishes = _selectedRecipes;
    final totalCalories = dishes.fold<int>(0, (s, r) => s + (r.calories ?? 0));

    return ListView(
      // Bottom padding keeps the last card above the extended FAB.
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _nameController,
            autofocus: widget.isNew,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Название меню',
              hintText: 'Например, Новый год',
              prefixIcon: const Icon(Icons.edit_note),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) => _update(_menu.copyWith(name: value)),
          ),
        ),
        if (widget.recipes.isEmpty)
          const _EmptyHint(
            icon: Icons.menu_book,
            text: 'Сначала добавьте рецепты на главном экране',
          )
        else if (dishes.isEmpty)
          const _EmptyHint(
            icon: Icons.celebration,
            text: 'Нажмите «Добавить блюда» и найдите нужные рецепты по названию',
          )
        else ...[
          SummaryBar(
            icon: Icons.local_fire_department,
            text: '${dishCountLabel(dishes.length)} · $totalCalories ккал',
          ),
          ..._buildGroupedDishes(context, dishes),
        ],
      ],
    );
  }

  /// Dishes grouped by category, in the same order as [AppStrings.recipeCategories].
  List<Widget> _buildGroupedDishes(BuildContext context, List<Recipe> dishes) {
    final colorScheme = Theme.of(context).colorScheme;
    final order = AppStrings.recipeCategories;
    int rank(String c) {
      final i = order.indexOf(c);
      return i == -1 ? order.length : i;
    }

    final groups = <String, List<Recipe>>{};
    for (final r in dishes) {
      final category = (r.category == null || r.category!.isEmpty) ? 'Другое' : r.category!;
      groups.putIfAbsent(category, () => []).add(r);
    }
    final categories = groups.keys.toList()..sort((a, b) => rank(a).compareTo(rank(b)));

    return [
      for (final category in categories) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            category,
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ),
        for (final recipe in groups[category]!)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  AppStrings.getSvgAssetForCategory(recipe.category),
                  width: 40,
                  height: 40,
                ),
              ),
              title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${recipe.calories ?? 0} ккал · ${recipe.cookingTimeMinutes ?? 0} мин'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: 'Убрать из меню',
                onPressed: () => _removeDish(recipe),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
              ),
            ),
          ),
      ],
    ];
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
