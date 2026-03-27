import 'package:flutter/material.dart';

/// Describes one tab that a module contributes to the bottom nav.
class ModuleTabConfig {
  const ModuleTabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;

  /// The page widget to display when this tab is active.
  final Widget page;
}

/// A module registers itself here with its list of tabs.
/// Dashboard (index 0) and Profile (last index) are always present.
/// Everything in between is filled dynamically from this registry.
class ModuleRegistry {
  ModuleRegistry._();

  static final Map<String, List<ModuleTabConfig>> _registry = {};

  static void register(String moduleId, List<ModuleTabConfig> tabs) {
    _registry[moduleId] = tabs;
  }

  static List<ModuleTabConfig> tabsFor(String moduleId) =>
      _registry[moduleId] ?? [];

  /// Returns all tabs for every active module id, in order.
  static List<ModuleTabConfig> tabsForModules(List<String> moduleIds) {
    final result = <ModuleTabConfig>[];
    for (final id in moduleIds) {
      result.addAll(tabsFor(id));
    }
    return result;
  }
}
