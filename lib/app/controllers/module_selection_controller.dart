import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/module_model.dart';
import '../data/services/tenant_service.dart';
import '../data/services/user_prefs_service.dart';
import '../routes/app_routes.dart';
import '../utils/helpers/injectable/injectable.dart';
import 'main_shell_controller.dart';

@lazySingleton
class ModuleSelectionController extends GetxController {
  ModuleSelectionController(this._prefs);

  final UserPrefsService _prefs;

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

  /// Fetches available modules from the main Supabase.
  /// The modules table already contains supabase_url + anon_key per module
  /// — no edge function needed. We just read what's there.
  Future<void> _fetchModules() async {
    isFetchingModules.value = true;
    error.value = null;
    try {
      final response =
          await Supabase.instance.client.rpc('get_active_modules');

      final fetched = (response as List)
          .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
          .toList();

      modules.assignAll(fetched);

      // Auto-select the todo module or the first available one.
      final todo = modules
          .firstWhereOrNull((m) => m.id.toLowerCase().contains('todo'));
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
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final ids = selected.toList();

      // ── 1. Save module selection to main Supabase (single upsert with array) ──
      // This records the user's chosen modules in a single array column.
      error.value = 'Saving your module selection...';
      await supabase.from('user_module_selections').upsert({
        'user_id': userId,
        'modules': ids,
      }, onConflict: 'user_id');

      // ── 2. Check for an active workspace (One-off fetch instead of infinite stream) ──
      error.value = 'Checking workspace status...';
      
      final workspaceRes = await supabase
          .from('user_workspaces')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      String? globalUrl;
      String? globalAnonKey;

      if (workspaceRes != null && workspaceRes['status'] == 'active') {
        globalUrl = workspaceRes['supabase_url'] as String?;
        globalAnonKey = workspaceRes['supabase_anon_key'] as String?;
      }

      error.value = 'Connecting to modules...';

      // ── 3. Wire up the tenant Supabase client for all selected modules ────
      // If the user has a globally provisioned workspace, use its credentials.
      // Otherwise, fallback to the placeholder credentials from the `modules` table so the app doesn't hang!
      final credentials = <String, Map<String, String>>{};
      for (final id in ids) {
        final mod = modules.firstWhereOrNull((m) => m.id == id);
        if (mod != null) {
          final url = globalUrl ?? mod.supabaseUrl;
          final anonKey = globalAnonKey ?? mod.anonKey;
          
          if (url != null && anonKey != null && url.isNotEmpty) {
            credentials[id] = {
              'url': url,
              'anonKey': anonKey,
            };
          }
        }
      }

      if (credentials.isNotEmpty) {
        await getIt<TenantService>().updateAll(credentials);
        // await getIt<MainShellController>().activeModuleIds.upda
      } else {
        // If there are literally no credentials anywhere, log and proceed anyway so the user isn't stuck.
        print('Warning: No tenant credentials were found for the selected modules.');
      }

      // ── 4. Persist selection locally & refresh the shell ─────────────────
      await _prefs.saveActiveModules(ids);
      // getIt always has the lazySingleton ready — no try/catch needed.
      await getIt<MainShellController>().onModulesChanged(ids);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = 'Could not save your selection:\n$e';
    } finally {
      isLoading.value = false;
      // error.value = null; // Don't clear error if it failed, so user can see it
    }
  }
}
