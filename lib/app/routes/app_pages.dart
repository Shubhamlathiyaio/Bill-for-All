import 'package:get/get.dart';
import '../ui/pages/splash/splash_page.dart';
import '../ui/pages/language/language_selection_page.dart';
import '../ui/pages/auth/auth_page.dart';
import '../ui/pages/module_selection/module_selection_page.dart';
import '../ui/pages/shell/main_shell_page.dart';
import '../ui/pages/todo/todo_add_edit_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = [
    // ── Onboarding ────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.language, page: () => const LanguageSelectionPage()),
    GetPage(name: AppRoutes.auth, page: () => const AuthPage()),
    GetPage(name: AppRoutes.moduleSelection, page: () => const ModuleSelectionPage()),

    // ── Main app shell ────────────────────────────────────────────────────
    // Dashboard + dynamic module tabs + Profile all live inside this shell.
    GetPage(name: AppRoutes.home, page: () => const MainShellPage()),

    // ── Modal/push routes (outside shell) ─────────────────────────────────
    GetPage(name: AppRoutes.todoAddEdit, page: () => const TodoAddEditPage()),
  ];
}
