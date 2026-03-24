import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/utils/helpers/injectable/injectable.dart';
import 'app/utils/themes/app_theme.dart';

Future<void> main() async {
  await configuration(myApp: const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bill For All',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      builder: EasyLoading.init(),
    );
  }
}
