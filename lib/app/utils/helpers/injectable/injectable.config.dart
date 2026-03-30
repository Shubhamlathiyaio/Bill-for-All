// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bill_for_all/app/controllers/auth_controller.dart' as _i1024;
import 'package:bill_for_all/app/controllers/dashboard_controller.dart'
    as _i753;
import 'package:bill_for_all/app/controllers/home_controller.dart' as _i843;
import 'package:bill_for_all/app/controllers/language_controller.dart' as _i418;
import 'package:bill_for_all/app/controllers/main_shell_controller.dart'
    as _i88;
import 'package:bill_for_all/app/controllers/module_selection_controller.dart'
    as _i997;
import 'package:bill_for_all/app/controllers/profile_controller.dart' as _i508;
import 'package:bill_for_all/app/controllers/splash_controller.dart' as _i560;
import 'package:bill_for_all/app/controllers/todo_controller.dart' as _i1043;
import 'package:bill_for_all/app/data/repositories/auth_repository.dart'
    as _i135;
import 'package:bill_for_all/app/data/repositories/module_migration_repository.dart'
    as _i816;
import 'package:bill_for_all/app/data/repositories/module_repository.dart'
    as _i306;
import 'package:bill_for_all/app/data/repositories/todo_repository.dart'
    as _i659;
import 'package:bill_for_all/app/data/services/tenant_service.dart' as _i144;
import 'package:bill_for_all/app/data/services/user_prefs_service.dart'
    as _i423;
import 'package:bill_for_all/app/utils/helpers/injectable/injectable_properties.dart'
    as _i210;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:get_storage/get_storage.dart' as _i792;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i792.GetStorage>(
      () => registerModule.storage(),
      preResolve: true,
    );
    gh.singleton<_i361.Dio>(() => registerModule.dio());
    gh.lazySingleton<_i843.HomeController>(() => _i843.HomeController());
    gh.lazySingleton<_i560.SplashController>(() => _i560.SplashController());
    gh.lazySingleton<_i135.AuthRepository>(() => _i135.AuthRepository());
    gh.lazySingleton<_i816.ModuleMigrationRepository>(
      () => _i816.ModuleMigrationRepository(),
    );
    gh.lazySingleton<_i306.ModuleRepository>(() => _i306.ModuleRepository());
    gh.lazySingleton<_i659.TodoRepository>(() => _i659.TodoRepository());
    gh.lazySingleton<_i144.TenantService>(() => _i144.TenantService());
    gh.lazySingleton<_i423.UserPrefsService>(() => _i423.UserPrefsService());
    gh.lazySingleton<_i88.MainShellController>(
      () => _i88.MainShellController(gh<_i423.UserPrefsService>()),
    );
    gh.lazySingleton<_i997.ModuleSelectionController>(
      () => _i997.ModuleSelectionController(
        gh<_i423.UserPrefsService>(),
        gh<_i306.ModuleRepository>(),
        gh<_i816.ModuleMigrationRepository>(),
      ),
    );
    gh.lazySingleton<_i1043.TodoController>(
      () => _i1043.TodoController(
        gh<_i792.GetStorage>(),
        gh<_i659.TodoRepository>(),
      ),
    );
    gh.lazySingleton<_i418.LanguageController>(
      () => _i418.LanguageController(gh<_i792.GetStorage>()),
    );
    gh.lazySingleton<_i1024.AuthController>(
      () => _i1024.AuthController(gh<_i135.AuthRepository>()),
    );
    gh.lazySingleton<_i508.ProfileController>(
      () => _i508.ProfileController(
        gh<_i88.MainShellController>(),
        gh<_i135.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i753.DashboardController>(
      () => _i753.DashboardController(gh<_i1043.TodoController>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i210.RegisterModule {}
