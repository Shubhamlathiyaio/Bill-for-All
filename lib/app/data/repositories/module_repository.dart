import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module_model.dart';

@lazySingleton
class ModuleRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ModuleModel>> getActiveModules() async {
    final response = await _client.rpc('get_active_modules');
    return (response as List)
        .map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveUserModuleSelection(String userId, List<String> moduleIds) async {
    await _client.from('user_module_selections').upsert(
      {'user_id': userId, 'modules': moduleIds},
      onConflict: 'user_id',
    );
  }

  Future<Map<String, dynamic>?> getUserWorkspace(String userId) async {
    return await _client
        .from('user_workspaces')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }
}
