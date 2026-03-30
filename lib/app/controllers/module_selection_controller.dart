import 'dart:developer';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/module_model.dart';
import '../data/repositories/module_migration_repository.dart';
import '../data/repositories/module_repository.dart';
import '../data/services/tenant_service.dart';
import '../data/services/user_prefs_service.dart';
import '../routes/app_routes.dart';
import '../utils/helpers/injectable/injectable.dart';
import 'main_shell_controller.dart';

@lazySingleton
class ModuleSelectionController extends GetxController {
  ModuleSelectionController(this._prefs, this._repo, this._migrationRepo);

  final UserPrefsService _prefs;
  final ModuleRepository _repo;
  final ModuleMigrationRepository _migrationRepo;

  final selected = <String>{}.obs;
  final isLoading = false.obs;
  final isFetchingModules = true.obs;
  final modules = <ModuleModel>[].obs;
  final error = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _fetchModules();
  }

  Future<void> retryFetch() => _fetchModules();

  Future<void> _fetchModules() async {
    isFetchingModules.value = true;
    error.value = null;
    try {
      final fetched = await _repo.getActiveModules();
      modules.assignAll(fetched);

      // Auto-select the todo module or the first available one.
      final todo = modules.firstWhereOrNull((m) => m.id.toLowerCase().contains('todo'));
      if (todo != null) {
        toggleModule(todo.id);
      } else if (modules.isNotEmpty) {
        toggleModule(modules.first.id);
      }
    } catch (e) {
      error.value = 'Failed to load modules. Please check your connection.';
    } finally {
      isFetchingModules.value = false;
    }
  }

  void toggleModule(String id) {
    error.value = null;
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.clear();
      selected.add(id);
    }
  }

  bool isSelected(String id) => selected.contains(id);

  Future<void> submit() async {
    if (selected.isEmpty) {
      error.value = 'Please select at least one module.';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final ids = selected.toList();

      // ── 1. Save module selection ──────────────────────────────────────────
      error.value = 'Saving your module selection...';
      await _repo.saveUserModuleSelection(userId, ids);

      // ── 2. Check for an active workspace ──────────────────────────────────
      error.value = 'Checking workspace status...';
      final workspaceRes = await _repo.getUserWorkspace(userId);

      String? globalUrl;
      String? globalAnonKey;

      if (workspaceRes != null && workspaceRes['status'] == 'active') {
        globalUrl = workspaceRes['supabase_url'] as String?;
        globalAnonKey = workspaceRes['supabase_anon_key'] as String?;
      }

      error.value = 'Connecting to modules...';

      // ── 3. Wire up the tenant Supabase client for all selected modules ────
      final credentials = <String, Map<String, String>>{};
      for (final id in ids) {
        final mod = modules.firstWhereOrNull((m) => m.id == id);
        if (mod != null) {
          // Prioritize module-specific credentials (from main DB modules table)
          final url = mod.supabaseUrl ?? globalUrl;
          final anonKey = mod.anonKey ?? globalAnonKey;

          if (url != null && anonKey != null && url.isNotEmpty) {
            credentials[id] = {'url': url, 'anonKey': anonKey};
            log('--- ModuleSelectionController: Mapping module [$id] to $url');
          }
        }
      }

      if (credentials.isNotEmpty) {
        await getIt<TenantService>().updateAll(credentials);
      }

      // ── 4. Run migrations for newly activated modules ───────────────────
      final currentIds = getIt<MainShellController>().activeModuleIds;
      for (final id in ids) {
        if (!currentIds.contains(id)) {
          error.value = 'Preparing module: ${id.toUpperCase()}...';
          final client = getIt<TenantService>().getClient(id);
          if (client != null) {
            try {
              await _migrationRepo.migrateModule(client, id);
            } catch (e) {
              // We log but don't block navigation, as the tables might already exist.
              // We can refine this later with better "table exists" checks.
              log('Migration failed for $id, continuing: $e');
            }
          }
        }
      }

      // ── 5. Persist selection locally & refresh the shell ─────────────────
      await _prefs.saveActiveModules(ids);
      await getIt<MainShellController>().onModulesChanged(ids);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = 'Could not save your selection:\n$e';
    } finally {
      isLoading.value = false;
    }
  }
}
