import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/special_menu.dart';

/// Persists up to [maxMenus] special-occasion menus in SharedPreferences.
class SpecialMenuStorage {
  static const int maxMenus = 3;

  static const String _storageKey = 'special_menus';

  /// Key of the old single-menu format; migrated into the list on first load.
  static const String _legacyKey = 'special_menu';

  static Future<List<SpecialMenu>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacy(prefs);

    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      return (jsonDecode(jsonString) as List<dynamic>)
          .map((e) => SpecialMenu.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error special menus reading: $e');
      return [];
    }
  }

  /// Inserts or updates [menu]. Returns false if this would exceed [maxMenus].
  static Future<bool> save(SpecialMenu menu) async {
    final menus = await loadAll();
    final index = menus.indexWhere((m) => m.id == menu.id);
    if (index == -1) {
      if (menus.length >= maxMenus) return false;
      menus.add(menu);
    } else {
      menus[index] = menu;
    }
    await _writeAll(menus);
    return true;
  }

  static Future<void> delete(String id) async {
    final menus = await loadAll();
    menus.removeWhere((m) => m.id == id);
    await _writeAll(menus);
  }

  static Future<void> _writeAll(List<SpecialMenu> menus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(menus.map((m) => m.toJson()).toList()));
  }

  static Future<void> _migrateLegacy(SharedPreferences prefs) async {
    final legacy = prefs.getString(_legacyKey);
    if (legacy == null) return;

    try {
      final data = jsonDecode(legacy) as Map<String, dynamic>;
      final menu = SpecialMenu.fromJson(data);
      if (!menu.isEmpty && (prefs.getString(_storageKey) ?? '').isEmpty) {
        await prefs.setString(_storageKey, jsonEncode([menu.toJson()]));
      }
    } catch (e) {
      debugPrint('Error special menu migration: $e');
    }
    await prefs.remove(_legacyKey);
  }
}
