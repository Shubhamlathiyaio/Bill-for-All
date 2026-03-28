import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import '../data/models/module_tab_config.dart';
import '../data/services/user_prefs_service.dart';
import '../routes/app_routes.dart';

/// Controls the main shell: which bottom-nav tab is active,
/// and which module tabs are currently shown.
///
/// Nav structure:
///   [0] Dashboard
///   [1..n] Module tabs (dynamic — one or more per active module)
///   [n+1] Profile
@lazySingleton
class MainShellController extends GetxController {
  MainShellController(this._prefs);

  final UserPrefsService _prefs;

  final currentIndex = 0.obs;

  /// True while we are reading saved module IDs from SharedPreferences.
  /// The shell must NOT make routing decisions until this is false.
  final isLoadingPrefs = true.obs;

  /// Active module ids loaded from prefs (e.g. ['todo'])
  final activeModuleIds = <String>[].obs;

  /// Resolved tabs for all active modules (between Dashboard and Profile)
  final moduleTabs = <ModuleTabConfig>[].obs;

  /// Total tab count = 1 (dashboard) + module tabs + 1 (profile)
  int get totalTabs => 1 + moduleTabs.length + 1;

  int get profileIndex => totalTabs - 1;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoadingPrefs.value = true;
    final ids = await _prefs.loadActiveModules();
    activeModuleIds.assignAll(ids);
    _rebuildTabs();
    isLoadingPrefs.value = false;
  }

  void _rebuildTabs() {
    // Normalise to lowercase so IDs from Supabase (e.g. 'Todo') match the
    // registry keys (e.g. 'todo').
    moduleTabs.assignAll(
      ModuleRegistry.tabsForModules(
        activeModuleIds.map((id) => id.toLowerCase()).toList(),
      ),
    );
  }

  void setIndex(int i) => currentIndex.value = i;

  /// Called after user changes modules in Profile.
  Future<void> onModulesChanged(List<String> newIds) async {
    await _prefs.saveActiveModules(newIds);
    activeModuleIds.assignAll(newIds);
    _rebuildTabs();
    currentIndex.value = 0;
  }

  /// True when no modules have been selected yet (checks saved IDs, not
  /// resolved tabs, so a casing mismatch in the registry doesn't trigger
  /// a redirect back to module selection).
  bool get hasNoModules => activeModuleIds.isEmpty;

  /// Navigate to module selection (used from Profile).
  void goToModuleSelection() {
    Get.offAllNamed(AppRoutes.moduleSelection);
  }

  /// Sign out — clear state and go to language screen.
  Future<void> signOut() async {
    await _prefs.clearActiveModules();
    activeModuleIds.clear();
    moduleTabs.clear();
    currentIndex.value = 0;
    Get.offAllNamed(AppRoutes.language);
  }
}
