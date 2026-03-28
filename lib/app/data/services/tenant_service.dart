import 'dart:convert';
import 'package:bill_for_all/app/utils/constants/supabase_constants.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the tenant (module) Supabase clients.
/// Each module uses a DIFFERENT Supabase project — this service
/// initialises & exposes those secondary clients after login.
@lazySingleton
class TenantService {
  final Map<String, SupabaseClient> _clients = {};

  /// Retrieves the Supabase client for a specific module by its ID.
  SupabaseClient? getClient(String moduleId) => _clients[moduleId];

  bool isReady(String moduleId) => _clients.containsKey(moduleId);

  /// Call this once after login / on app start if creds are cached.
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final credsJson = prefs.getString('${SupabaseConstants.tenantSupabaseUrlKey}_map'); // Using a new key for the map
    
    if (credsJson == null || credsJson.isEmpty) {
      // Fallback for older single-client cache if needed, or simply return false
      return false;
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(credsJson);
      _clients.clear();
      
      for (final entry in decoded.entries) {
        final moduleId = entry.key;
        final data = entry.value as Map<String, dynamic>;
        final url = data['url'] as String?;
        final anonKey = data['anonKey'] as String?;
        
        if (url != null && url.isNotEmpty && anonKey != null && anonKey.isNotEmpty) {
           // Provide a unique anonKey across instances or handle differently if needed.
           // Since Flutter Supabase plugin uses a singleton pattern internally sometimes for named instances, 
           // be cautious not to create millions, but one per active module is fine.
          _clients[moduleId] = SupabaseClient(url, anonKey);
        }
      }
      return _clients.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Store new credentials map and re-initialise (called after provisioning).
  Future<void> updateAll(Map<String, Map<String, String>> moduleSpecs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${SupabaseConstants.tenantSupabaseUrlKey}_map', jsonEncode(moduleSpecs));
    
    _clients.clear();
    for (final entry in moduleSpecs.entries) {
      final moduleId = entry.key;
      final url = entry.value['url']!;
      final anonKey = entry.value['anonKey']!;
      _clients[moduleId] = SupabaseClient(url, anonKey);
    }
  }

  void clear() {
    _clients.clear();
  }
}
