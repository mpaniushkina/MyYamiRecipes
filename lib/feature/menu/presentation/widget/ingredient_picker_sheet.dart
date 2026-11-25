import 'package:flutter/material.dart';

import '../../../../l10n/l10n_helpers.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/ingredient_search.dart';

/// Bottom sheet for building a menu from products: the user searches
/// ingredients across all recipes and picks up to [maxMenuIngredients] of them.
///
/// [pick] returns the selected ingredient names, or null if dismissed.
class IngredientPickerSheet extends StatefulWidget {
  final List<Recipe> recipes;

  const IngredientPickerSheet._({required this.recipes});

  static Future<List<String>?> pick(BuildContext context, {required List<Recipe> recipes}) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        // Lift the sheet above the keyboard while the user types in the search field.
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: IngredientPickerSheet._(recipes: recipes),
      ),
    );
  }

  @override
  State<IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<IngredientPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final List<String> _allNames = allIngredientNames(widget.recipes);
  final List<String> _selected = [];
  String _query = '';

  bool get _isFull => _selected.length >= maxMenuIngredients;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSelected(String name) {
    final key = normalizeIngredient(name);
    return _selected.any((s) => normalizeIngredient(s) == key);
  }

  void _add(String name) {
    final value = name.trim();
    if (value.isEmpty || _isSelected(value) || _isFull) return;
    setState(() {
      _selected.add(value);
      _query = '';
    });
    _searchController.clear();
  }

  void _remove(String name) => setState(() => _selected.remove(name));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = normalizeIngredient(_query);
    final suggestions = _allNames
        .where((n) => !_isSelected(n) && (query.isEmpty || normalizeIngredient(n).contains(query)))
        .toList();
    final matchCount = recipesWithAnyIngredient(widget.recipes, _selected).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(context.l10n.menuFromProducts, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              context.l10n.menuFromProductsHint(maxMenuIngredients),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              enabled: !_isFull,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: _isFull
                    ? context.l10n.ingredientLimitReached(maxMenuIngredients)
                    : context.l10n.searchByIngredient,
                prefixIcon: const Icon(Icons.search),
                // Lets the user add a typed product even if it isn't an exact ingredient name.
                suffixIcon: _query.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: context.l10n.addIngredient,
                        onPressed: () => _add(_query),
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: (value) => setState(() => _query = value),
              onSubmitted: _add,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.ingredientsSelected(_selected.length, maxMenuIngredients),
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final name in _selected)
                      InputChip(
                        label: Text(name),
                        onDeleted: () => _remove(name),
                      ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: suggestions.isEmpty
                ? Center(child: Text(context.l10n.ingredientsNotFound))
                : ListView.builder(
                    controller: controller,
                    itemCount: suggestions.length,
                    itemBuilder: (_, i) {
                      final name = suggestions[i];
                      return ListTile(
                        enabled: !_isFull,
                        leading: const Icon(Icons.shopping_basket_outlined),
                        title: Text(name),
                        trailing: const Icon(Icons.add),
                        onTap: () => _add(name),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(context.l10n.createMenuWithDishes(context.l10n.dishCount(matchCount))),
                  onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, List.of(_selected)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
