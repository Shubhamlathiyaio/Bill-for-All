import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/tenant_service.dart';
import '../data/services/user_prefs_service.dart';
import '../utils/constants/supabase_constants.dart';
import '../routes/app_routes.dart';
import '../data/models/module_model.dart';
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

  Future<void> _fetchModules() async {
    isFetchingModules.value = true;
    error.value = null;
    try {
      // RPC now returns only modules that have supabase_url + anon_key set.
      final response =
          await Supabase.instance.client.rpc('get_active_modules');
      final fetched = (response as List)
          .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
          .toList();
      modules.assignAll(fetched);

      // Auto-select todo or first available module
      final todo = modules.firstWhereOrNull(
        (m) => m.id.toLowerCase().contains('todo'),
      );
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

      // ── Call the edge function to register the module selection ──────────
      final response = await supabase.functions.invoke(
        SupabaseConstants.submitModules,
        body: {'modules': selected.toList()},
      );
      if (response.status != 200) throw Exception('Failed to submit modules');

      // ── Wire up the tenant Supabase client for the selected module ───────
      final selectedId = selected.first;
      final selectedModule = modules.firstWhereOrNull((m) => m.id == selectedId);

      if (selectedModule != null && selectedModule.hasTenantCredentials) {
        await getIt<TenantService>().update(
          url: selectedModule.supabaseUrl!,
          anonKey: selectedModule.anonKey!,
        );
      }

      // ── Persist selection locally & refresh the shell ────────────────────
      final ids = selected.toList();
      await _prefs.saveActiveModules(ids);

      try {
        final shell = Get.find<MainShellController>();
        await shell.onModulesChanged(ids);
      } catch (_) {
        // Shell not yet initialised (first time) — normal
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
