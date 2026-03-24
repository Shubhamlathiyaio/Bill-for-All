import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../routes/app_routes.dart';

@lazySingleton
class SplashController extends GetxController {
  void navigateAfterSplash() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      Get.offAllNamed(AppRoutes.language);
      return;
    }

    try {
      final rows = await supabase.rpc(SupabaseConstants.getMyWorkspace);
      final workspace = (rows as List).isNotEmpty ? rows[0] : null;
      final supabaseUrl = workspace?['supabase_url'];
      if (supabaseUrl != null && (supabaseUrl as String).isNotEmpty) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.waiting);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.waiting);
    }
  }
}
