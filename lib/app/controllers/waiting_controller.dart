import 'dart:async';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../routes/app_routes.dart';

@lazySingleton
class WaitingController extends GetxController {
  Timer? _pollTimer;
  final isChecking = false.obs;

  static const _pollInterval = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    checkWorkspace();
    _pollTimer = Timer.periodic(_pollInterval, (_) => checkWorkspace());
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void reselectModules() {
    _pollTimer?.cancel();
    Get.offAllNamed(AppRoutes.moduleSelection);
  }


  Future<void> checkWorkspace() async {
    if (isChecking.value) return;
    isChecking.value = true;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase.functions.invoke(
        SupabaseConstants.checkWorkspace,
      );
      final responseData = response.data as Map<String, dynamic>;
      final isReady = responseData['ready'] == true;

      if (isReady) {
        _pollTimer?.cancel();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(SupabaseConstants.tenantSupabaseUrlKey, responseData['supabase_url']);
        await prefs.setString(SupabaseConstants.tenantAnonKeyKey, responseData['supabase_anon_key']);
        
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (_) {
      // Silently retry on next poll
    } finally {
      isChecking.value = false;
    }
  }
}
