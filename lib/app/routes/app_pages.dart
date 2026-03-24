import 'package:get/get.dart';
import '../ui/pages/splash/splash_page.dart';
import '../ui/pages/language/language_selection_page.dart';
import '../ui/pages/auth/auth_page.dart';
import '../ui/pages/module_selection/module_selection_page.dart';
import '../ui/pages/waiting/waiting_page.dart';
import '../ui/pages/home/home_page.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.language, page: () => const LanguageSelectionPage()),
    GetPage(name: AppRoutes.auth, page: () => const AuthPage()),
    GetPage(name: AppRoutes.moduleSelection, page: () => const ModuleSelectionPage()),
    GetPage(name: AppRoutes.waiting, page: () => const WaitingPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePage()),
  ];
}
