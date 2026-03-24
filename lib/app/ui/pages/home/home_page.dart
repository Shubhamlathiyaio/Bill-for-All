import 'package:flutter/material.dart';
import '../../../controllers/home_controller.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/system_ui_overlay.dart';
import '../../../utils/helpers/extensions.dart';

class HomePage extends GetItHook<HomeController> {
  const HomePage({super.key});

  @override
  bool get autoDispose => false;

  @override
  Widget build(BuildContext context) {
    return DarkSystemUiOverlayStyle(
      child: AppScaffold(
        showAppBar: false,
        body: (context) => Center(
          child: Text(
            'Home\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: context.styles.s18w700White
                .copyWith(color: context.colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
