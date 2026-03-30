import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import '../data/repositories/auth_repository.dart';
import 'main_shell_controller.dart';

@lazySingleton
class ProfileController extends GetxController {
  ProfileController(this._shell, this._authRepo);

  final MainShellController _shell;
  final AuthRepository _authRepo;

  final isSigningOut = false.obs;

  String get userName =>
      _authRepo.currentUser?.userMetadata?['full_name'] as String? ?? 'User';

  String get userEmail => _authRepo.currentUser?.email ?? '';

  List<String> get activeModuleIds => _shell.activeModuleIds;

  void switchModules() => _shell.goToModuleSelection();

  Future<void> signOut() async {
    isSigningOut.value = true;
    try {
      await _authRepo.signOut();
      await _shell.signOut();
    } catch (_) {
      // Even if signOut fails remotely, clear local state.
      await _shell.signOut();
    } finally {
      isSigningOut.value = false;
    }
  }
}
