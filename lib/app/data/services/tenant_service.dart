import 'package:bill_for_all/app/utils/constants/supabase_constants.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the tenant (module) Supabase client.
/// Each module uses a DIFFERENT Supabase project — this service
/// initialises & exposes that secondary client after login.
@lazySingleton
class TenantService {
  SupabaseClient? _client;

  SupabaseClient? get client => _client;

  bool get isReady => _client != null;

  /// Call this once after login / on app start if creds are cached.
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(SupabaseConstants.tenantSupabaseUrlKey);
    final anonKey = prefs.getString(SupabaseConstants.tenantAnonKeyKey);

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      return false;
    }

    try {
      // Use a named client so it doesn't clash with the main Supabase instance.
      _client = SupabaseClient(url, anonKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Store new credentials and re-initialise (called after provisioning).
  Future<void> update({required String url, required String anonKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SupabaseConstants.tenantSupabaseUrlKey, url);
    await prefs.setString(SupabaseConstants.tenantAnonKeyKey, anonKey);
    _client = SupabaseClient(url, anonKey);
  }

  void clear() {
    _client = null;
  }
}
