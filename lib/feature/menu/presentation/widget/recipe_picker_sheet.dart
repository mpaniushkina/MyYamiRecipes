import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../recipes/domain/entities/recipe.dart';

/// Result of a single-choice pick. `recipe == null` means "no dish".
class RecipePickResult {
  final Recipe? recipe;
  const RecipePickResult(this.recipe);
}

/// Bottom sheet with title search for picking recipes.
///
/// Use [pickOne] for a single choice (returns [RecipePickResult]) or
/// [pickMany] for multi-select (returns the full set of selected recipe ids).
/// Both return null when the sheet is dismissed without confirming.
class RecipePickerSheet extends StatefulWidget {
  final String title;
  final List<Recipe> recipes;
  final Set<String> initialSelectedIds;
  final bool multiSelect;
  final bool allowEmpty;

  const RecipePickerSheet._({
    required this.title,
    required this.recipes,
    required this.initialSelectedIds,
    required this.multiSelect,
    required this.allowEmpty,
  });

  static Future<RecipePickResult?> pickOne(
    BuildContext context, {
    required String title,
    required List<Recipe> recipes,
    String? selectedId,
    bool allowEmpty = true,
  }) {
    return _show<RecipePickResult>(
      context,
      RecipePickerSheet._(
        title: title,
        recipes: recipes,
        initialSelectedIds: {?selectedId},
        multiSelect: false,
        allowEmpty: allowEmpty,
      ),
    );
  }

  static Future<Set<String>?> pickMany(
    BuildContext context, {
    required String title,
    required List<Recipe> recipes,
    Set<String> selectedIds = const {},
  }) {
    return _show<Set<String>>(
      context,
      RecipePickerSheet._(
        title: title,
        recipes: recipes,
        initialSelectedIds: selectedIds,
        multiSelect: true,
        allowEmpty: false,
      ),
    );
  }

  static Future<T?> _show<T>(BuildContext context, Widget sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        // Lift the sheet above the keyboard while the user types in the search field.
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: sheet,
      ),
    );
  }

  @override
  State<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<RecipePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<String> _selected = {...widget.initialSelectedIds};
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRecipeTap(Recipe recipe) {
    if (!widget.multiSelect) {
      Navigator.pop(context, RecipePickResult(recipe));
      return;
    }
    setState(() {
      if (!_selected.remove(recipe.id)) _selected.add(recipe.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.recipes
        : widget.recipes.where((r) => r.title.toLowerCase().contains(query)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск по названию',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Очистить',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (widget.allowEmpty && query.isEmpty)
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Без блюда'),
              onTap: () => Navigator.pop(context, const RecipePickResult(null)),
            ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Рецепты не найдены'))
                : ListView.builder(
                    controller: controller,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      final isSelected = _selected.contains(r.id);
                      return ListTile(
                        selected: isSelected,
                        leading: SvgPicture.asset(
                          AppStrings.getSvgAssetForCategory(r.category),
                          width: 36,
                          height: 36,
                        ),
                        title: Text(r.title),
                        subtitle: Text('${r.category ?? ''} · ${r.calories ?? 0} ккал'),
                        trailing: widget.multiSelect
                            ? Checkbox(value: isSelected, onChanged: (_) => _onRecipeTap(r))
                            : null,
                        onTap: () => _onRecipeTap(r),
                      );
                    },
                  ),
          ),
          if (widget.multiSelect)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text('Готово (${_selected.length})'),
                    onPressed: () => Navigator.pop(context, _selected),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
