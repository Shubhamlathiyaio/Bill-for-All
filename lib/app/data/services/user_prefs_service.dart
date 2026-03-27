import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores lightweight user preferences in SharedPreferences.
@lazySingleton
class UserPrefsService {
  static const _kActiveModules = 'active_module_ids';

  Future<void> saveActiveModules(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kActiveModules, ids);
  }

  Future<List<String>> loadActiveModules() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kActiveModules) ?? [];
  }

  Future<void> clearActiveModules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActiveModules);
  }
}
