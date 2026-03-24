import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../themes/k_colors.dart';

class Loading {
  Loading._();

  static void show() => EasyLoading.show();
  static void dismiss() => EasyLoading.dismiss();

  static void configure() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = KColors.bg1
      ..indicatorColor = KColors.primary
      ..textColor = KColors.white
      ..maskColor = KColors.bg0.withValues(alpha: 0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
  }
}
