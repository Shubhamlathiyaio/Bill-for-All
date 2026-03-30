import 'package:bill_for_all/app/utils/constants/supabase_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../loading.dart';
import '../../../data/services/tenant_service.dart';
import 'injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configuration({required Widget myApp}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
      url: 'https://fymjvddpstywkpzqjrro.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5bWp2ZGRwc3R5d2twenFqcnJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MDM3MTYsImV4cCI6MjA5MDE3OTcxNn0.-jS0mTMjR0H_eeDY1UZVNKcRzsuj5o9No8x0HoAmuSE',

    // url: SupabaseConstants.supabaseUrl,
    // anonKey: SupabaseConstants.supabaseAnonKey,
  );

  // Initialize GetIt dependency injection
  await getIt.init();

  // Initialize Tenant Service to load cached module clients
  await getIt<TenantService>().init();

  // Configure EasyLoading
  Loading.configure();

  if (kDebugMode) {
    runApp(myApp);
  } else {
    runApp(myApp);
  }
}
