import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_shell_controller.dart';
import '../../../data/models/module_tab_config.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';
import '../../../utils/themes/app_colors.dart';
import '../dashboard/dashboard_page.dart';
import '../profile/profile_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late final MainShellController _shell;

  @override
  void initState() {
    super.initState();
    _shell = getIt<MainShellController>();
    // GetIt does not trigger GetX lifecycle hooks, so onInit() (and therefore
    // _load()) would never be called.  We call it here manually — but only
    // once: guard against double-init on hot-reload by checking the flag.
    if (_shell.isLoadingPrefs.value) {
      _shell.onInit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Still reading saved modules from SharedPreferences — wait silently.
      if (_shell.isLoadingPrefs.value) {
        return Scaffold(
          backgroundColor: Theme.of(context).extension<AppColors>()?.bg0 ?? Colors.black,
        );
      }

      // Prefs loaded. No modules saved → first launch, go to module selection.
      if (_shell.hasNoModules) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoutes.moduleSelection);
        });
        return Scaffold(
          backgroundColor: Theme.of(context).extension<AppColors>()?.bg0 ?? Colors.black,
        );
      }

      // Modules exist — show the main shell directly.
      return _Shell(shell: _shell);
    });
  }
}

// ── Shell ────────────────────────────────────────────────────────────────────

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});
  final MainShellController shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final moduleTabs = shell.moduleTabs;
      final currentIndex = shell.currentIndex.value;

      final pages = <Widget>[const DashboardPage(), ...moduleTabs.map((t) => t.page), const ProfilePage()];

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: colors.bg1,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: colors.bg0,
          body: IndexedStack(index: currentIndex.clamp(0, pages.length - 1), children: pages),
          bottomNavigationBar: _BottomNav(shell: shell, moduleTabs: moduleTabs, currentIndex: currentIndex, colors: colors),
        ),
      );
    });
  }
}

// ── Bottom nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.shell, required this.moduleTabs, required this.currentIndex, required this.colors});

  final MainShellController shell;
  final List<ModuleTabConfig> moduleTabs;
  final int currentIndex;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      ...moduleTabs.map((t) => BottomNavigationBarItem(icon: Icon(t.icon), activeIcon: Icon(t.activeIcon), label: t.label)),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.bg1,
        border: Border(top: BorderSide(color: colors.textPrimary.changeOpacity(0.08))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, items.length - 1),
        onTap: shell.setIndex,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textPrimary.changeOpacity(0.35),
        selectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w400),
      ),
    );
  }
}
