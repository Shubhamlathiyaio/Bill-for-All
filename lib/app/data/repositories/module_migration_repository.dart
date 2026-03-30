import 'dart:developer';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class ModuleMigrationRepository {
  /// Runs the necessary SQL to provision a module's tables in a workspace project.
  /// This ensures that tables like 'todos' only exist when the module is enabled.
  Future<void> migrateModule(SupabaseClient client, String moduleId) async {
    log('--- ModuleMigrationRepository: Starting migration for [$moduleId] on ${client.rest.url}');
    
    switch (moduleId.toLowerCase()) {
      case 'todo':
        await _migrateTodo(client);
        break;
      // Add other modules here: case 'crm': ...
      default:
        log('--- ModuleMigrationRepository: No migration defined for [$moduleId]');
    }
  }

  Future<void> _migrateTodo(SupabaseClient client) async {
    // Note: We use RPC or direct SQL if allowed. 
    // Since we are using the anon key, direct DDL usually requires a specific function.
    // However, if the user has a 'exec_sql' RPC or similar, we use it.
    // For this implementation, we assume a standard 'provision_module' approach 
    // or we attempt to run the SQL directly if the key permits.
    
    const sql = '''
      -- 1. Create update_updated_at_column if missing
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS \$\$
      BEGIN
          NEW.updated_at = now();
          RETURN NEW;
      END;
      \$\$ language 'plpgsql';

      -- 2. Create todos table
      CREATE TABLE IF NOT EXISTS public.todos (
        id uuid NOT NULL DEFAULT gen_random_uuid (),
        user_id uuid NOT NULL,
        title text NOT NULL,
        is_done boolean NULL DEFAULT false,
        created_at timestamp with time zone NULL DEFAULT now(),
        updated_at timestamp with time zone NULL DEFAULT now(),
        description text NULL,
        status text NULL DEFAULT 'pending'::text,
        due_date timestamp with time zone NULL,
        category_id uuid NULL,
        CONSTRAINT todos_pkey PRIMARY KEY (id),
        CONSTRAINT todos_status_check CHECK (
          status = ANY (ARRAY['pending'::text, 'in-progress'::text, 'done'::text])
        )
      ) TABLESPACE pg_default;

      -- 3. Create indices
      CREATE INDEX IF NOT EXISTS idx_todos_user_id ON public.todos USING btree (user_id) TABLESPACE pg_default;
      CREATE INDEX IF NOT EXISTS idx_todos_category_id ON public.todos USING btree (category_id) TABLESPACE pg_default;
      CREATE INDEX IF NOT EXISTS idx_todos_status ON public.todos USING btree (status) TABLESPACE pg_default;
      CREATE INDEX IF NOT EXISTS idx_todos_due_date ON public.todos USING btree (due_date) TABLESPACE pg_default;

      -- 4. Trigger
      DROP TRIGGER IF EXISTS update_todos_updated_at ON public.todos;
      CREATE TRIGGER update_todos_updated_at BEFORE UPDATE ON public.todos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ''';

    try {
      // In a real app, you might call a backend endpoint. 
      // Here, we try to run it via the client if permitted, 
      // or we log that it needs to be run.
      // For the sake of this task, we will attempt to use a custom RPC 'exec_sql'
      // which is common in developing Supabase apps for runtime migrations.
      await client.rpc('exec_sql', params: {'query': sql});
      log('--- ModuleMigrationRepository: Todo migration successful');
    } catch (e) {
      log('--- ModuleMigrationRepository: Todo migration failed: $e');
      // If exec_sql doesn't exist, we fallback to a warning.
      // In this specific project, the user might need to create the RPC.
      rethrow;
    }
  }
}
