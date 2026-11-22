import 'package:flutter/material.dart';

import '../../../../l10n/l10n_helpers.dart';
import '../../domain/shopping_list.dart';
import 'summary_bar.dart';

/// Checklist of products with a "bought N of M" progress header.
/// Checked items move from the main list into the «Куплено» section at the bottom.
class ShoppingListView extends StatelessWidget {
  final List<ShoppingItem> items;
  final Set<String> checkedKeys;
  final void Function(String key, bool checked) onToggle;
  final VoidCallback onClearChecked;
  /// Shown when there are no items; defaults to "no ingredients".
  final String? emptyText;

  const ShoppingListView({
    super.key,
    required this.items,
    required this.checkedKeys,
    required this.onToggle,
    required this.onClearChecked,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyText ?? context.l10n.noIngredientsInRecipes, textAlign: TextAlign.center),
        ),
      );
    }

    final toBuy = items.where((i) => !checkedKeys.contains(i.key)).toList();
    final bought = items.where((i) => checkedKeys.contains(i.key)).toList();

    return Column(
      children: [
        SummaryBar(
          icon: Icons.shopping_basket,
          text: context.l10n.boughtProgress(bought.length, items.length),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(
            value: bought.length / items.length,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (toBuy.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.allBought,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              for (final item in toBuy) _ShoppingItemTile(item: item, checked: false, onToggle: onToggle),
              if (bought.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.task_alt, size: 18, color: colorScheme.outline),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.l10n.boughtSection(bought.length),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      TextButton(onPressed: onClearChecked, child: Text(context.l10n.reset)),
                    ],
                  ),
                ),
                for (final item in bought) _ShoppingItemTile(item: item, checked: true, onToggle: onToggle),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final bool checked;
  final void Function(String key, bool checked) onToggle;

  const _ShoppingItemTile({required this.item, required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quantity = context.l10n.quantity(item.amountText, item.unit);

    return Card(
      // Keyed by product so Flutter doesn't reuse a tile's state across sections.
      key: ValueKey(item.key),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Bought items look muted so the remaining list stands out.
      color: checked ? colorScheme.surfaceContainerLow : null,
      elevation: checked ? 0 : null,
      child: CheckboxListTile(
        value: checked,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (v) => onToggle(item.key, v == true),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: checked ? TextDecoration.lineThrough : null,
            color: checked ? colorScheme.outline : null,
          ),
        ),
        secondary: quantity.isEmpty
            ? null
            : Text(
                quantity,
                style: TextStyle(
                  color: checked ? colorScheme.outline : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
