import 'package:bill_for_all/app/data/models/module_model.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

/// Legacy stub — kept so injectable.config.dart compiles cleanly.
/// The real app shell is now MainShellController + MainShellPage.
@lazySingleton
class HomeController extends GetxController {
  final modules = <ModuleModel>[].obs;
  openModule(ModuleModel module) {
    

    
  }
}
