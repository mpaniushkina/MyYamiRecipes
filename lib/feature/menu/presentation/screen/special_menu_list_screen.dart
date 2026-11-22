import 'package:flutter/material.dart';

import '../../../../l10n/l10n_helpers.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../data/special_menu_storage.dart';
import '../../domain/special_menu.dart';
import '../widget/summary_bar.dart';
import 'special_menu_screen.dart';

/// List of saved special-occasion menus (at most [SpecialMenuStorage.maxMenus]).
/// To create a new one when the limit is reached, the user must delete one first.
class SpecialMenuListScreen extends StatefulWidget {
  final List<Recipe> recipes;

  const SpecialMenuListScreen({super.key, required this.recipes});

  @override
  State<SpecialMenuListScreen> createState() => _SpecialMenuListScreenState();
}

class _SpecialMenuListScreenState extends State<SpecialMenuListScreen> {
  List<SpecialMenu> _menus = [];
  bool _isLoading = true;

  late final Map<String, Recipe> _recipesById = {
    for (final r in widget.recipes) r.id: r,
  };

  bool get _isFull => _menus.length >= SpecialMenuStorage.maxMenus;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final menus = await SpecialMenuStorage.loadAll();
    if (!mounted) return;
    setState(() {
      _menus = menus;
      _isLoading = false;
    });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openMenu(SpecialMenu menu, {bool isNew = false}) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialMenuScreen(menu: menu, recipes: widget.recipes, isNew: isNew),
      ),
    );
    await _reload();
    if (deleted == true && mounted) _showSnackBar(context.l10n.menuDeleted);
  }

  void _createMenu() {
    if (_isFull) {
      _showSnackBar(
        context.l10n.menuLimitReached(SpecialMenuStorage.maxMenus),
      );
      return;
    }
    _openMenu(SpecialMenu.empty(), isNew: true);
  }

  Future<void> _deleteMenu(SpecialMenu menu) async {
    if (!await confirmDeleteSpecialMenu(context, menu)) return;
    await SpecialMenuStorage.delete(menu.id);
    await _reload();
    if (mounted) _showSnackBar(context.l10n.menuDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.specialMenus),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menus.isEmpty
              ? _buildEmpty(context)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    SummaryBar(
                      icon: Icons.celebration,
                      text: context.l10n.savedCount(_menus.length, SpecialMenuStorage.maxMenus),
                    ),
                    if (_isFull) _buildLimitHint(context),
                    for (final menu in _menus) _buildMenuCard(context, menu),
                  ],
                ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _createMenu,
              // Muted colors signal that the limit is reached; tap explains why.
              backgroundColor: _isFull ? colorScheme.surfaceContainerHighest : null,
              foregroundColor: _isFull ? colorScheme.outline : null,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.newMenu),
            ),
    );
  }

  Widget _buildLimitHint(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.secondaryContainer,
      child: ListTile(
        leading: Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
        title: Text(
          context.l10n.menuLimitHint(SpecialMenuStorage.maxMenus),
          style: TextStyle(color: colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, SpecialMenu menu) {
    final colorScheme = Theme.of(context).colorScheme;
    final dishes = menu.resolveRecipes(_recipesById);
    final calories = dishes.fold<int>(0, (s, r) => s + (r.calories ?? 0));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.celebration, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          menuDisplayName(context, menu),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          dishes.isEmpty
              ? context.l10n.noDishes
              : '${context.l10n.dishCount(dishes.length)} · ${context.l10n.kcalValue(calories)}\n'
                  '${dishes.map((r) => r.title).join(', ')}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: dishes.isNotEmpty,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: context.l10n.deleteMenu,
          onPressed: () => _deleteMenu(menu),
        ),
        onTap: () => _openMenu(menu),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              context.l10n.noSpecialMenus(SpecialMenuStorage.maxMenus),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
