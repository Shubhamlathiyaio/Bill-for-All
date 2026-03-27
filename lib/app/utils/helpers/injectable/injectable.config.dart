// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bill_for_all/app/controllers/auth_controller.dart' as _i1;
import 'package:bill_for_all/app/controllers/dashboard_controller.dart' as _i2;
import 'package:bill_for_all/app/controllers/home_controller.dart' as _i3;
import 'package:bill_for_all/app/controllers/language_controller.dart' as _i4;
import 'package:bill_for_all/app/controllers/main_shell_controller.dart'
    as _i5;
import 'package:bill_for_all/app/controllers/module_selection_controller.dart'
    as _i6;
import 'package:bill_for_all/app/controllers/profile_controller.dart' as _i7;
import 'package:bill_for_all/app/controllers/splash_controller.dart' as _i8;
import 'package:bill_for_all/app/controllers/todo_controller.dart' as _i9;
import 'package:bill_for_all/app/data/services/tenant_service.dart' as _i11;
import 'package:bill_for_all/app/data/services/user_prefs_service.dart'
    as _i12;
import 'package:bill_for_all/app/utils/helpers/injectable/injectable_properties.dart'
    as _i100;
import 'package:dio/dio.dart' as _i200;
import 'package:get_it/get_it.dart' as _i300;
import 'package:get_storage/get_storage.dart' as _i400;
import 'package:injectable/injectable.dart' as _i500;

extension GetItInjectableX on _i300.GetIt {
  Future<_i300.GetIt> init({
    String? environment,
    _i500.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i500.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();

    // ── Infrastructure ───────────────────────────────────────────────────
    await gh.factoryAsync<_i400.GetStorage>(
      () => registerModule.storage(),
      preResolve: true,
    );
    gh.singleton<_i200.Dio>(() => registerModule.dio());

    // ── Services ─────────────────────────────────────────────────────────
    gh.lazySingleton<_i11.TenantService>(() => _i11.TenantService());
    gh.lazySingleton<_i12.UserPrefsService>(() => _i12.UserPrefsService());

    // ── Core controllers ─────────────────────────────────────────────────
    gh.lazySingleton<_i8.SplashController>(() => _i8.SplashController());
    gh.lazySingleton<_i4.LanguageController>(
      () => _i4.LanguageController(gh<_i400.GetStorage>()),
    );
    gh.lazySingleton<_i1.AuthController>(() => _i1.AuthController());

    // ── Module selection ─────────────────────────────────────────────────
    gh.lazySingleton<_i6.ModuleSelectionController>(
      () => _i6.ModuleSelectionController(gh<_i12.UserPrefsService>()),
    );

    // ── Shell & profile ──────────────────────────────────────────────────
    gh.lazySingleton<_i5.MainShellController>(
      () => _i5.MainShellController(gh<_i12.UserPrefsService>()),
    );
    gh.lazySingleton<_i7.ProfileController>(
      () => _i7.ProfileController(gh<_i5.MainShellController>()),
    );

    // ── Module: Todo ─────────────────────────────────────────────────────
    gh.lazySingleton<_i9.TodoController>(
      () => _i9.TodoController(gh<_i400.GetStorage>()),
    );
    gh.lazySingleton<_i2.DashboardController>(
      () => _i2.DashboardController(gh<_i9.TodoController>()),
    );

    // ── Legacy (kept for backward compat / waiting screen) ───────────────
    gh.lazySingleton<_i3.HomeController>(() => _i3.HomeController());

    return this;
  }
}

class _$RegisterModule extends _i100.RegisterModule {}
