import 'package:flutter/material.dart';

import '../../domain/shopping_list.dart';
import 'summary_bar.dart';

/// Checklist of products with a "bought N of M" progress header.
/// Checked items move from the main list into the «Куплено» section at the bottom.
class ShoppingListView extends StatelessWidget {
  final List<ShoppingItem> items;
  final Set<String> checkedKeys;
  final void Function(String key, bool checked) onToggle;
  final VoidCallback onClearChecked;
  final String emptyText;

  const ShoppingListView({
    super.key,
    required this.items,
    required this.checkedKeys,
    required this.onToggle,
    required this.onClearChecked,
    this.emptyText = 'В выбранных рецептах нет ингредиентов',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyText, textAlign: TextAlign.center),
        ),
      );
    }

    final toBuy = items.where((i) => !checkedKeys.contains(i.key)).toList();
    final bought = items.where((i) => checkedKeys.contains(i.key)).toList();

    return Column(
      children: [
        SummaryBar(
          icon: Icons.shopping_basket,
          text: 'Куплено ${bought.length} из ${items.length}',
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
                      const Text(
                        'Всё куплено!',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                          'Куплено (${bought.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                      TextButton(onPressed: onClearChecked, child: const Text('Сбросить')),
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
        secondary: item.amountLabel.isEmpty
            ? null
            : Text(
                item.amountLabel,
                style: TextStyle(
                  color: checked ? colorScheme.outline : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
