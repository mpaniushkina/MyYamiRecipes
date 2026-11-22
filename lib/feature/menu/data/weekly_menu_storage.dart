import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../recipes/domain/entities/recipe.dart';
import '../domain/weekly_menu.dart';

class SavedWeeklyMenu {
  final List<DayMenu> menu;
  final Set<String> checkedProducts;

  const SavedWeeklyMenu({required this.menu, required this.checkedProducts});
}

/// Persists the weekly menu in SharedPreferences.
/// Only recipe ids are stored, so loading picks up the latest recipe versions,
/// and deleted recipes turn into empty slots.
class WeeklyMenuStorage {
  static const String _storageKey = 'weekly_menu';

  static Future<SavedWeeklyMenu?> load(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final byId = {for (final r in recipes) r.id: r};

      final days = (data['days'] as List<dynamic>).map((day) {
        final map = day as Map<String, dynamic>;
        return DayMenu({
          for (final type in MealType.values) type: byId[map[type.name]],
        });
      }).toList();

      if (days.length != daysInWeek) return null;

      final checked = (data['checked'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toSet();

      return SavedWeeklyMenu(menu: days, checkedProducts: checked);
    } catch (e) {
      debugPrint('Error weekly menu reading: $e');
      return null;
    }
  }

  static Future<void> save(List<DayMenu> menu, Set<String> checkedProducts) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'days': [
        for (final day in menu)
          {for (final type in MealType.values) type.name: day[type]?.id},
      ],
      'checked': checkedProducts.toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
