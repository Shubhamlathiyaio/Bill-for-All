import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injectable/injectable.dart';
import '../../../global/app_config.dart';

@module
abstract class RegisterModule {
  @singleton
  Dio dio() => Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )..interceptors.addAll([
          if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
        ]);

  @preResolve
  Future<GetStorage> storage() async {
    await GetStorage.init();
    return GetStorage();
  }
}
