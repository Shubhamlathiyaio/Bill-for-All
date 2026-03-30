import 'package:flutter/material.dart';
import '../data/models/module_tab_config.dart';
import '../ui/pages/todo/todo_module_page.dart';

/// Call this once at app startup (before MainShellPage is shown).
/// Each sub-module of a module registers as a separate flat tab in the
/// outer shell nav:  [Dashboard]  [...sub-tabs...]  [Profile]
void registerAllModules() {
  // ── Todo module ─────────────────────────────────────────────────────────
  // Single flat tab — simplified for starting:
  //   · "To-Do"  → TodoModulePage  (Stats + filterable task list)
  ModuleRegistry.register('todo', [
    const ModuleTabConfig(
      label: 'To-Do',
      icon: Icons.check_circle_outline_rounded,
      activeIcon: Icons.check_circle_rounded,
      page: TodoModulePage(),
    ),
  ]);

  // ── Future modules register here ────────────────────────────────────────
  // ModuleRegistry.register('invoice', [ ... ]);
}
