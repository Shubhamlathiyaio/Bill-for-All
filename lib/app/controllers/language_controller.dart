import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants/supabase_constants.dart';
import '../routes/app_routes.dart';

@lazySingleton
class LanguageController extends GetxController {
  LanguageController(this._storage);

  final GetStorage _storage;
  static const _kLang = 'selected_language';

  RxString selectedCode = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<String>(_kLang);
    if (saved != null) selectedCode.value = saved;
  }

  void selectLanguage(String code) {
    selectedCode.value = code;
  }

  Future<void> onContinue() async {
    _storage.write(_kLang, selectedCode.value);

    // 1. Save to SharedPreferences (for offline access)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SupabaseConstants.languageCodeKey, selectedCode.value);

    // 2. If user is already logged in, persist to their profile row
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'language_code': selectedCode.value})
          .eq('id', user.id);
    }

    Get.offAllNamed(AppRoutes.auth);
  }
}
