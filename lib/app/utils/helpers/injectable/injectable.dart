import 'package:bill_for_all/app/utils/constants/supabase_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../loading.dart';
import 'injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configuration({required Widget myApp}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  // Initialize GetIt dependency injection
  await getIt.init();

  // Configure EasyLoading
  Loading.configure();

  if (kDebugMode) {
    runApp(myApp);
  } else {
    runApp(myApp);
  }
}
