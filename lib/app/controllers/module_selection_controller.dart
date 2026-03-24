import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../routes/app_routes.dart';

@lazySingleton
class ModuleSelectionController extends GetxController {
  final selected = <String>{}.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  void toggleModule(String id) {
    error.value = null;
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
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

      final response = await supabase.functions.invoke(
        SupabaseConstants.submitModules,
        body: {'modules': selected.toList()},
      );
      if (response.status != 200) throw Exception('Failed to submit modules');

      Get.offAllNamed(AppRoutes.waiting);
    } catch (e) {
      error.value = e.toString(); // show real error temporarily
    } finally {
      isLoading.value = false;
    }
  }
}
