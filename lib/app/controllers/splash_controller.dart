import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/tenant_service.dart';
import '../data/services/user_prefs_service.dart';
import '../routes/app_routes.dart';
import '../utils/helpers/injectable/injectable.dart';

@lazySingleton
class SplashController extends GetxController {
  Future<void> navigateAfterSplash() async {
    final session = Supabase.instance.client.auth.currentSession;

    // No session → start from language selection (full onboarding)
    if (session == null) {
      Get.offAllNamed(AppRoutes.language);
      return;
    }

    // Session exists → try to restore tenant client from cached creds
    await getIt<TenantService>().init();

    // Check if user already selected modules locally
    final savedModules = await getIt<UserPrefsService>().loadActiveModules();

    if (savedModules.isEmpty) {
      // Logged in but no module selected yet → go pick a module
      Get.offAllNamed(AppRoutes.moduleSelection);
    } else {
      // Fully set up → go straight to home shell
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
