import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'app/global/module_registrar.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/utils/helpers/injectable/injectable.dart';
import 'app/utils/themes/app_theme.dart';

const String kAppName = 'Bill For All';

Future<void> main() async {
  // Register all module tabs before the app starts.
  registerAllModules();

  await configuration(myApp: const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    );
  }
}
