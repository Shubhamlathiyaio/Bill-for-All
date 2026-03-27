import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_shell_controller.dart';

@lazySingleton
class ProfileController extends GetxController {
  ProfileController(this._shell);

  final MainShellController _shell;

  final isSigningOut = false.obs;

  String get userName =>
      Supabase.instance.client.auth.currentUser?.userMetadata?['full_name']
          as String? ??
      'User';

  String get userEmail =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  List<String> get activeModuleIds => _shell.activeModuleIds;

  void switchModules() => _shell.goToModuleSelection();

  Future<void> signOut() async {
    isSigningOut.value = true;
    try {
      await Supabase.instance.client.auth.signOut();
      await _shell.signOut();
    } catch (_) {
      // Even if signOut fails remotely, clear local state.
      await _shell.signOut();
    } finally {
      isSigningOut.value = false;
    }
  }
}
