import 'package:flutter/material.dart';
import '../data/models/module_tab_config.dart';
import '../ui/pages/todo/todo_module_page.dart';

/// Call this once at app startup (before MainShellPage is shown).
/// Each module registers ONE tab — its top-level module shell page.
/// Sub-pages (Tasks, Labels, etc.) live inside that shell's own nav.
void registerAllModules() {
  // ── Todo module ─────────────────────────────────────────────────────────
  // Single tab → TodoModulePage, which has its own inner bottom nav:
  //   Dashboard · Modules (Tasks / Labels) · Profile
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
